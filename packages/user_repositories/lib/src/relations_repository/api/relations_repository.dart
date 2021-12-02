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
class _RelationsUpdateEvent {
  final Map<String, dynamic>? oldRecord;
  final Map<String, dynamic>? newRecord;

  _RelationsUpdateEvent({
    required this.oldRecord,
    required this.newRecord,
  });
}

// TODO: Sub on updates for friends
/// Supabase implementation of [IRelationsRepository]
class RelationsRepository extends IRelationsRepository {
  late final String _userId;
  final SupabaseClient _client;
  RealtimeSubscription? _sub;

  final StreamController<UserRelations> _relationsStreamController;
  StreamController<_RelationsUpdateEvent>? _updateStreamController;

  late final Map<String, List<User>> _currentRelations;

  UserRelations? currentUserRelations;

  @override
  Stream<UserRelations> get relationsStream =>
      _relationsStreamController.stream;

  RelationsRepository({required SupabaseClient client})
      : _client = client,
        _relationsStreamController = StreamController.broadcast() {
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

    // Subscribe to the updates of the table and
    // broadcast them to the _updateStreamController
    final searchParam = "relations:id=eq.$_userId";
    _updateStreamController = new StreamController<_RelationsUpdateEvent>();
    _sub = _client.from(searchParam).on(SupabaseEventTypes.all, (payload) {
      final updateEvent = _RelationsUpdateEvent(
        newRecord: payload.newRecord,
        oldRecord: payload.oldRecord,
      );
      _updateStreamController?.add(updateEvent);
    }).subscribe((String msg, {String? errorMsg}) {
      if (errorMsg != null || errorMsg == "SUBSCRIPTION_ERROR") {
        _error(PointsConnectionError());
      }
    });

    await for (final event in _updateStreamController!.stream) {
      await _handleRelationsUpdateEvent(event);
    }
  }

  /// Find out which relation was changed
  Future<void> _handleRelationsUpdateEvent(_RelationsUpdateEvent event) async {
    final id = event.oldRecord?["other_id"] ?? event.newRecord?["other_id"];
    late final User user;
    if (event.oldRecord != null) {
      _currentRelations.values.forEach((relations) {
        relations.removeWhere((user_) {
          if (user_.id == id) {
            user = user_;
            return true;
          }
          return false;
        });
      });
    } else {
      final response = await _client
          .from("profiles")
          .select()
          .eq("id", id)
          .single()
          .execute();
      if (response.error != null) {
        _relationsStreamController.addError(PointsConnectionError());
      }
      user = User.fromJson(response.data);
    }
    if (event.newRecord != null) {
      final relationsType = event.newRecord!["state"]!;
      _currentRelations[relationsType]!.add(user);
    }
    _updateRelations();
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
    _updateStreamController?.close();
    if(_sub != null) {
      _client.removeSubscription(_sub!);
    }
  }
}
