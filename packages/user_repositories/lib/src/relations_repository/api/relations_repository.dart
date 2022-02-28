import 'dart:async';

import 'package:supabase/supabase.dart' hide User;

import '../../errors_shared/points_connection_error.dart';
import '../../errors_shared/points_error.dart';
import '../domain/relation_type.dart';
import '../domain/user_relations.dart';
import '../errors/points_illegal_relation_error.dart';
import '../relations_function_names.dart' as functions;
import '../domain/related_user.dart';
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
  final RelatedUser profile;

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

  /// All relations which profiles are currently being listened to
  final Map<String, RealtimeSubscription> _friendsProfilesSubs = Map();

  /// All relations that could
  /// not be fit inside the [_relationsProfileSubs]
  ///
  /// The user id is mapped to the [RelatedUser]
  final Set<String> _friendsProfilesSubsExcess = Set();

  late final StreamController<UserRelations> _relationsStreamController;
  StreamController<_UpdateEvent>? _updateEventQueue;

  late final Map<String, List<RelatedUser>> _currentRelations;

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

  Future<Map<String, List<RelatedUser>>> _fetchInitialRelations() async {
    final initialRelations = <String, List<RelatedUser>>{
      "friends": [],
      "blocked": [],
      "blocked_by": [],
      "requesting": [],
      "request_pending": [],
    };
    final response = await _client.rpc("get_relations").execute();
    if (response.error != null) {
      throw PointsConnectionError();
    }
    final rawRelatedUsers = response.data as List;
    for (final rawRelatedUser in rawRelatedUsers) {
      final relationState = rawRelatedUser["state"];
      initialRelations[relationState]!.add(
        RelatedUser.fromJson(rawRelatedUser),
      );
    }
    return initialRelations;
  }

  /// First fetch all data with
  /// [_getRelationUserIds] and [_fillRelationsWithUsers]
  void _startStreaming() async {
    try {
      _currentRelations = await _fetchInitialRelations();
      _updateRelations();
    } on PointsError catch (e) {
      _relationsStreamController.addError(e);
      return;
    }

    // Subscribe to friends, requests and pending profiles
    for (final user in _currentRelations["friends"]!) {
      _handlerAddFriendListener(user.id, user.chatId, user.relationType);
    }

    // Subscribe to the updates of the table and
    // broadcast them to the _updateEventQueue
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

    // handle each event of the _updateEventQueue and
    // update the relations after the handling
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
  Future<RelatedUser> fetchRelatedUser(
    String userId,
    String chatId,
    RelationType relationType,
  ) async {
    final response = await _client
        .from("profiles")
        .select()
        .eq("id", userId)
        .single()
        .execute();
    if (response.error != null) {
      throw PointsConnectionError();
    }
    return RelatedUser.fromJson(
      response.data,
      chatId: chatId,
      relationType: relationType,
    );
  }

  /// Handle the removal of a friend by trying to removing its listener,
  /// it also starts listening to the next friend in line,
  /// if there wasn't the capacity in the past (because of the [realtimeLimit])
  Future<void> _handleRemoveFriendListener(String id) async {
    if (_friendsProfilesSubs[id] != null) {
      _client.removeSubscription(_friendsProfilesSubs[id]!);
      _friendsProfilesSubs.remove(id);
      if (_friendsProfilesSubsExcess.length > 0) {
        // If there is excess that couldn't be listened to before,
        // fetch the user and then call _handlerAddUser
        final userId = _friendsProfilesSubsExcess.first;
        _friendsProfilesSubsExcess.remove(userId);
        try {
          final oldUser =
              currentUserRelations!.all.firstWhere((user) => user.id == userId);
          final user = await fetchRelatedUser(
            userId,
            oldUser.chatId,
            oldUser.relationType,
          );
          _updateEventQueue!.add(_ProfileUpdateEvent(profile: user));
          _handlerAddFriendListener(
            userId,
            oldUser.chatId,
            oldUser.relationType,
          );
        } on PointsError catch (e) {
          _error(e);
        }
      }
    }
  }

  /// Handle the adding of a friend by listening to its profile,
  /// if that is not possible, because the [realtimeLimit] would be broken,
  /// add it to the [_friendsProfilesSubsExcess]
  void _handlerAddFriendListener(
    String userId,
    String chatId,
    RelationType relationType,
  ) async {
    if (_friendsProfilesSubs.length < realtimeLimit) {
      _friendsProfilesSubs[userId] = _client.from("profiles:id=eq.$userId").on(
        SupabaseEventTypes.update,
        (payload) {
          final rawUser = payload.newRecord!;
          // TODO: Temp fix
          if (rawUser["color"] is String) {
            rawUser["color"] = int.parse(rawUser["color"]);
          }
          if (rawUser["icon"] is String) {
            rawUser["icon"] = int.parse(rawUser["icon"]);
          }
          if (rawUser["points"] is String) {
            rawUser["points"] = int.parse(rawUser["points"]);
          }
          if (rawUser["gives"] is String) {
            rawUser["gives"] = int.parse(rawUser["gives"]);
          }
          _updateEventQueue!.add(
            _ProfileUpdateEvent(
              profile: RelatedUser.fromJson(
                rawUser,
                chatId: chatId,
                relationType: relationType,
              ),
            ),
          );
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
    late RelatedUser user;
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
        user = await fetchRelatedUser(
          userId,
          event.newRecord!["chat_id"],
          relationTypeFromString(event.newRecord!["state"]),
        );
      } on PointsError catch (e) {
        _error(e);
      }
    }
    if (event.newRecord != null) {
      final rawRelationType = event.newRecord!["state"]!;
      user = user.copyWithNewRelationType(
        relationTypeFromString(rawRelationType),
      );
      _currentRelations[rawRelationType]!.add(user);
      if (rawRelationType == "friends") {
        _handlerAddFriendListener(userId, user.chatId, user.relationType);
      } else {
        await _handleRemoveFriendListener(userId);
      }
    } else {
      await _handleRemoveFriendListener(userId);
    }
  }

  /// Create a new [UserRelations] with the [_currentRelations] sorted
  void _updateRelations() {
    final userRelations = UserRelations(
      _sortFriendList(_currentRelations["friends"]!),
      _sortFriendList(_currentRelations["request_pending"]!),
      _sortFriendList(_currentRelations["requesting"]!),
      _sortFriendList(_currentRelations["blocked"]!),
      _sortFriendList(_currentRelations["blocked_by"]!),
    );
    currentUserRelations = userRelations;
    _relationsStreamController.add(userRelations);
  }

  /// Sort [User]s into a new list by name
  List<RelatedUser> _sortFriendList(List<RelatedUser> list) {
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

  @override
  void givePoints(String id, int amount) {
    _invokeBase(functions.givePoints, params: {"_id": id, "amount": amount});
  }

  /// Base method for invoking a RPC with error handling
  void _invoke(String id, String function) {
    _invokeBase(function, params: {"_id": id});
  }

  void _invokeBase(
    String function, {
    required Map<String, dynamic> params,
  }) async {
    final response = await _client.rpc(function, params: params).execute();
    if (response.error != null) {
      if (response.error!.message.startsWith("SocketException")) {
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
