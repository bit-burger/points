import 'dart:async';

import 'package:supabase/supabase.dart';

import '../../constants/table_names.dart' as tables;
import '../../constants/profile_function_names.dart' as functions;

import '../../domain/root_user.dart';
import '../../errors/points_connection_error.dart';
import '../../errors/points_error.dart';

part 'api_contract.dart';

class PointsProfileRepository extends IPointsProfileRepository {
  final SupabaseClient _client;

  late final StreamController<RootUser?> _profileStreamController;
  late final StreamSubscription _sub;

  late final Stream<RootUser?> _profileStream;
  RootUser? _lastUpdatedProfile;

  PointsProfileRepository({required SupabaseClient client}) : _client = client {
    _startListening();
  }

  Stream<RootUser?> get profileStream => _profileStream;

  void _startListening() {
    assert(_client.auth.user() != null,
        "PointsProfileRepository needs a logged in SupabaseClient");

    _profileStreamController = StreamController.broadcast();
    _profileStream = _profileStreamController.stream;

    final userId = _client.auth.user()!.id;

    final searchParam = "${tables.profiles}:id=eq.$userId";
    _sub = _client
        .from(searchParam)
        .stream()
        .limit(1)
        .execute()
        .listen(_handleUpdate, onError: (_) {
      _error(PointsConnectionError());
    });
  }

  void _handleUpdate(final List<Map<String, dynamic>> users) async {
    late final RootUser? profile;
    if (users.isNotEmpty) {
      profile = RootUser.fromJson(users[0]);
    } else {
      profile = null;
    }
    _addToStream(profile);
  }

  void _addToStream(RootUser? newProfile) {
    _lastUpdatedProfile = newProfile;
    _profileStreamController.add(newProfile);
  }

  @override
  Future<void> createAccount(String name) async {
    final params = {
      "name": name,
    };
    final response = await _client
        .rpc(
          functions.createProfile,
          params: params,
        )
        .execute();
    if (response.error != null) {
      throw PointsConnectionError();
    }
  }

  @override
  Future<void> updateAccount({
    String? name,
    String? status,
    String? bio,
    int? color,
    int? icon,
  }) async {
    final current = _lastUpdatedProfile!;
    final params = {
      "new_name": name ?? current.name,
      "new_status": status ?? current.status,
      "new_bio": bio ?? current.bio,
      "new_color": color ?? current.color,
      "new_icon": icon ?? current.icon,
    };
    final response =
        await _client.rpc(functions.updateProfile, params: params).execute();
    if (response.error != null) {
      throw PointsConnectionError();
    }
  }

  @override
  Future<void> deleteAccount() async {
    final response = await _client
        .from(tables.profiles)
        .delete()
        .eq("id", _client.auth.user()!.id)
        .execute();
    if (response.error != null) {
      throw PointsConnectionError();
    }
  }

  void _error(PointsError error) {
    _profileStreamController.addError(error);
    close();
  }

  void close() {
    _profileStreamController.close();
    _sub.cancel();
  }
}
