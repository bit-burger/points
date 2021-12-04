import 'dart:async';

import 'package:supabase/supabase.dart' hide User;

import '../../domain_shared/user.dart';
import '../../errors_shared/points_connection_error.dart';
import '../../errors_shared/points_error.dart';
import '../domain/user_relations.dart';
import '../errors/points_illegal_relation_error.dart';
import '../relations_function_names.dart' as functions;
import 'relations_repository_contract.dart';

/// Represents one change in supabase realtime
abstract class _UpdateEvent {}

class _RelationsUpdateEvent extends _UpdateEvent {
  final Map<String, dynamic>? oldRecord;
  final Map<String, dynamic>? newRecord;

  _RelationsUpdateEvent({
    required this.oldRecord,
    required this.newRecord,
  });
}

class _ProfileUpdateEvent extends _UpdateEvent {
  final User profile;

  _ProfileUpdateEvent({required this.profile});
}

/// Supabase implementation of [IRelationsRepository]
class RelationsRepository extends IRelationsRepository {
  /// How many relations profiles are max. allowed to be listened to
  final int realtimeLimit;
  late final String _userId;
  final SupabaseClient _client;

  /// The [RealtimeSubscription] of the relations of the user
  RealtimeSubscription? _relationsSub;

  /// All relations which profiles are currently being listend to
  final Map<String, RealtimeSubscription> _friendsProfilesSubs = Map();

  /// All relations that could
  /// not be fit inside the [_relationsProfileSubs]
  ///
  /// The user id is mapped to the [User]
  final Set<String> _friendsProfilesSubsExcess = Set();

  late final StreamController<UserRelations> _relationsStreamController;
  StreamController<_UpdateEvent>? _updateEventQueue;

  late final Map<String, List<User>> _currentRelations;

  UserRelations? currentUserRelations;

  @override
  Stream<UserRelations> get relationsStream =>
      _relationsStreamController.stream;

  RelationsRepository({this.realtimeLimit = 50, required SupabaseClient client})
      : _client = client,
        _relationsStreamController = StreamController.broadcast(),
        assert(realtimeLimit > 0) {
    _startStreaming();
    _userId = _client.auth.user()!.id;
  }

  Future<Map<String, Set<String>>> _getRelationUserIds() async {
    final userId = _client.auth.user()!.id;

    final Map<String, Set<String>> relationIds = {
      "friends": {},
      "blocked": {},
      "blocked_by": {},
      "requesting": {},
      "request_pending": {},
    };

    final response =
        await _client.from("relations").select().eq("id", userId).execute();

    if (response.error != null) {
      throw PointsConnectionError();
    }

    for (final rawRelation in response.data) {
      final relationId = rawRelation["other_id"];
      relationIds[rawRelation["state"]]!.add(relationId);
    }

    return relationIds;
  }

  Future<Map<String, List<User>>> _fillRelationsWithUsers(
    Map<String, Set<String>> relationIds,
  ) async {
    final allRelationIds = <String>[];

    for (final relations in relationIds.values) {
      allRelationIds.addAll(relations);
    }

    assert(
      allRelationIds.toSet().length == allRelationIds.length,
      "allRelationIds contains duplicates",
    );

    final Map<String, List<User>> relations = {};

    final response = await _client
        .from("profiles")
        .select()
        .in_("id", allRelationIds)
        .execute();

    if (response.error != null) {
      throw PointsConnectionError();
    }

    final rawUsers = response.data as List;
    final users = rawUsers.map<User>((rawUser) => User.fromJson(rawUser));

    relationIds.forEach((relationType, relationOfRelationTypeIds) {
      relations[relationType] = relationOfRelationTypeIds
          .map<User>((userId) => users.firstWhere((user) => user.id == userId))
          .toList();
    });

    return relations;
  }

  /// First fetch all data with
  /// [_getRelationUserIds] and [_fillRelationsWithUsers]
  void _startStreaming() async {
    try {
      final relationIds = await _getRelationUserIds();
      final relations = await _fillRelationsWithUsers(relationIds);
      _currentRelations = relations;
      _updateRelations();
    } on PointsError catch (e) {
      _relationsStreamController.addError(e);
      return;
    }

    // Subscribe to friends, requests and pending profiles
    for (final user in _currentRelations["friends"]!) {
      _handlerAddFriend(user.id);
    }

    // Subscribe to the updates of the table and
    // broadcast them to the _updateStreamController
    final searchParam = "relations:id=eq.$_userId";
    _updateEventQueue = new StreamController();
    _relationsSub = _client.from(searchParam).on(
      SupabaseEventTypes.all,
      (payload) {
        final updateEvent = _RelationsUpdateEvent(
          newRecord: payload.newRecord,
          oldRecord: payload.oldRecord,
        );
        _updateEventQueue?.add(updateEvent);
      },
    ).subscribe((String msg, {String? errorMsg}) {
      if (errorMsg != null) {
        _error(PointsConnectionError());
      }
    });

    await for (final event in _updateEventQueue!.stream) {
      if (event is _RelationsUpdateEvent) {
        await _handleRelationsUpdateEvent(event);
      } else {
        _handleFriendProfileUpdateEvent(event as _ProfileUpdateEvent);
      }
      _updateRelations();
    }
  }

  /// fetch a user and handle the error appropriately
  Future<User> fetchUser(String userId) async {
    final response = await _client
        .from("profiles")
        .select()
        .eq("id", userId)
        .single()
        .execute();
    if (response.error != null) {
      throw PointsConnectionError();
    }
    return User.fromJson(response.data);
  }

  /// Handle the removal of a friend by trying to removing its listener,
  /// it also starts listening to the next friend in line,
  /// if there wasn't the capacity in the past (because of the [realtimeLimit])
  Future<void> _handleRemoveFriend(String id) async {
    if (_friendsProfilesSubs[id] != null) {
      _client.removeSubscription(_friendsProfilesSubs[id]!);
      _friendsProfilesSubs.remove(id);
      if (_friendsProfilesSubsExcess.length > 0) {
        // If there is excess that couldn't be listened to before,
        // fetch the user and then call _handlerAddUser
        final userId = _friendsProfilesSubsExcess.first;
        _friendsProfilesSubsExcess.remove(userId);
        try {
          final user = await fetchUser(userId);
          _updateEventQueue!.add(_ProfileUpdateEvent(profile: user));
          _handlerAddFriend(userId);
        } on PointsError catch (e) {
          _error(e);
        }
      }
    }
  }

  /// Handle the adding of a friend by listening to its profile,
  /// if that is not possible, because the [realtimeLimit] would be broken,
  /// add it to the [_friendsProfilesSubsExcess]
  void _handlerAddFriend(String userId) async {
    if (_friendsProfilesSubs.length < realtimeLimit) {
      _friendsProfilesSubs[userId] = _client.from("profiles:id=eq.$userId").on(
        SupabaseEventTypes.update,
        (payload) {
          final user = payload.newRecord!;
          // TODO: Temp fix
          if (user["color"] is String) {
            user["color"] = int.parse(user["color"]);
          }
          if (user["icon"] is String) {
            user["icon"] = int.parse(user["icon"]);
          }
          if (user["points"] is String) {
            user["points"] = int.parse(user["points"]);
          }
          if (user["gives"] is String) {
            user["gives"] = int.parse(user["gives"]);
          }
          _updateEventQueue!
              .add(_ProfileUpdateEvent(profile: User.fromJson(user)));
        },
      ).subscribe((String msg, {String? errorMsg}) {
        if (errorMsg != null) {
          _error(PointsConnectionError());
        }
      });
    } else {
      _friendsProfilesSubsExcess.add(userId);
    }
  }

  /// Update a friends profile in [_currentRelations]
  void _handleFriendProfileUpdateEvent(_ProfileUpdateEvent event) {
    for (final users in _currentRelations.values) {
      final index = users.indexWhere((user) => user.id == event.profile.id);
      if (index != -1 && users[index] != event.profile) {
        users
          ..removeAt(index)
          ..insert(index, event.profile);
      }
    }
  }

  /// Handles relation change and finds out which relation was changed
  /// and sets the profile listeners and UserRelations accordingly
  Future<void> _handleRelationsUpdateEvent(_RelationsUpdateEvent event) async {
    final userId = event.oldRecord?["other_id"] ?? event.newRecord?["other_id"];
    // If the oldRecord is null remove the record and set it to the variable user,
    // if not (there has to be a newRecord),
    // so fetch the new user and set it to the variable user.

    // Now if newRecord exists,
    // add the user to the relations type of the newRecord.

    // If the newRecords relation type is of friends,
    // add a listener to its profile,
    // else remove it (if there is a listener)

    // If the newRecords does not exist,
    // try to remove a listener on the users profile
    late final User user;
    if (event.oldRecord != null) {
      _currentRelations.values.forEach((relations) {
        relations.removeWhere((user_) {
          if (user_.id == userId) {
            user = user_;
            return true;
          }
          return false;
        });
      });
    } else {
      try {
        user = await fetchUser(userId);
      } on PointsError catch (e) {
        _error(e);
      }
    }
    if (event.newRecord != null) {
      final relationsType = event.newRecord!["state"]!;
      _currentRelations[relationsType]!.add(user);
      if (relationsType == "friends") {
        _handlerAddFriend(userId);
      } else {
        await _handleRemoveFriend(userId);
      }
    } else {
      await _handleRemoveFriend(userId);
    }
  }

  /// Create a new [UserRelations] with the [_currentRelations] sorted
  void _updateRelations() {
    final userRelations = UserRelations(
      _sortUserList(_currentRelations["friends"]!),
      _sortUserList(_currentRelations["request_pending"]!),
      _sortUserList(_currentRelations["requesting"]!),
      _sortUserList(_currentRelations["blocked"]!),
      _sortUserList(_currentRelations["blocked_by"]!),
    );
    _relationsStreamController.add(userRelations);
    currentUserRelations = userRelations;
  }

  /// Sort [User]s into a new list by name
  List<User> _sortUserList(List<User> list) {
    return [...list]..sort((user1, user2) => user1.name.compareTo(user2.name));
  }

  @override
  void accept(String id) async {
    _invoke(id, functions.accept);
  }

  @override
  void block(String id) async {
    _invoke(id, functions.block);
  }

  @override
  void reject(String id) async {
    _invoke(id, functions.reject);
  }

  @override
  void request(String id) async {
    _invoke(id, functions.request);
  }

  @override
  void cancelRequest(String id) async {
    _invoke(id, functions.takeBackRequest);
  }

  @override
  void unblock(String id) async {
    _invoke(id, functions.unblock);
  }

  @override
  void unfriend(String id) async {
    _invoke(id, functions.unfriend);
  }

  /// Base method for invoking a RPC with error handling
  void _invoke(String id, String function) async {
    final response = await _client.rpc(function, params: {"_id": id}).execute();
    if (response.error != null) {
      if (response.error!.message.startsWith("4SocketException")) {
        _error(PointsConnectionError());
      }
      _error(PointsIllegalRelationError());
    }
  }

  void _error(PointsError error) {
    _relationsStreamController.addError(error);
  }

  /// Close streams
  @override
  void close() {
    _relationsStreamController.close();
    _updateEventQueue?.close();
    if (_relationsSub != null) {
      _client.removeSubscription(_relationsSub!);
      _friendsProfilesSubs.values.forEach((sub) {
        _client.removeSubscription(sub);
      });
    }
  }
}
