import 'dart:async';

import 'package:supabase/supabase.dart' hide User;

import '../../domain/user.dart';
import '../../domain/user_relations.dart';
import '../../errors/points_connection_error.dart';
import '../../constants/table_names.dart' as tables;
import '../../constants/relations_function_names.dart' as functions;

part 'api_contract.dart';

class _RelationsUpdateEvent {
  final Map<String, dynamic>? oldRecord;
  final Map<String, dynamic>? newRecord;

  _RelationsUpdateEvent({
    required this.oldRecord,
    required this.newRecord,
  });
}

class PointsRelationsRepository extends IPointsRelationsRepository {
  late final String userId;
  final SupabaseClient _client;
  late final RealtimeSubscription _sub;

  final StreamController<UserRelations> _relationsStreamController;
  late final StreamController<_RelationsUpdateEvent> _updateStreamController;

  late final Map<String, List<User>> _currentRelations;
  UserRelations? currentUserRelations;

  @override
  Stream<UserRelations> get relationsStream =>
      _relationsStreamController.stream;

  PointsRelationsRepository({required SupabaseClient client})
      : _client = client,
        _relationsStreamController = StreamController.broadcast() {
    _startStreaming();
    userId = _client.auth.user()!.id;
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

    final response = await _client
        .from(tables.relations)
        .select()
        .eq("id", userId)
        .execute();

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

    for (final relationships in relationIds.values) {
      allRelationIds.addAll(relationships);
    }

    assert(
      allRelationIds.toSet().length == allRelationIds.length,
      "allRelationIds contains duplicates",
    );

    final Map<String, List<User>> relations = {};

    final response = await _client
        .from(tables.profiles)
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

  void _startStreaming() async {
    try {
      final relationIds = await _getRelationUserIds();
      final relations = await _fillRelationsWithUsers(relationIds);
      _currentRelations = relations;
      _updateRelations();
    } on PointsConnectionError catch (e) {
      _relationsStreamController.addError(e);
      return;
    }
    // fill the ids with users

    final searchParam = "${tables.relations}:id=eq.$userId";
    // TODO: Make more performant by only listening to the inserts, updates and removes instead of every item
    _updateStreamController = new StreamController<_RelationsUpdateEvent>();
    _sub = _client.from(searchParam).on(SupabaseEventTypes.all, (payload) {
      final updateEvent = _RelationsUpdateEvent(
        newRecord: payload.newRecord,
        oldRecord: payload.oldRecord,
      );
      _updateStreamController.add(updateEvent);
    }).subscribe((String msg, {String? errorMsg}) {
      if (errorMsg != null) {
        _relationsStreamController.addError(PointsConnectionError());
      }
    });
    await for (final event in _updateStreamController.stream) {
      await _handleRelationsUpdateEvent(event);
    }
  }

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
          .from(tables.profiles)
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
  void accept(String id) {
    _invoke(id, functions.accept);
  }

  @override
  void block(String id) {
    _invoke(id, functions.block);
  }

  @override
  void reject(String id) {
    _invoke(id, functions.reject);
  }

  @override
  void request(String id) {
    _invoke(id, functions.request);
  }

  @override
  void takeBackRequest(String id) {
    _invoke(id, functions.takeBackRequest);
  }

  @override
  void unblock(String id) {
    _invoke(id, functions.unblock);
  }

  @override
  void unfriend(String id) {
    _invoke(id, functions.unfriend);
  }

  void _invoke(String id, String function) async {
    final response = await _client.rpc(function, params: {"_id": id}).execute();
    if (response.error != null) {
      switch (response.error!.message) {
        default:
          throw PointsConnectionError();
      }
    }
  }

  @override
  void close() {
    _relationsStreamController.close();
    _updateStreamController.close();
    _client.removeSubscription(_sub);
    // TODO: cancel friend subs
    // TODO: do this on errors
  }
}
