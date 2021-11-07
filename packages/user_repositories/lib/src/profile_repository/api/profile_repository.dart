import 'dart:async';

import 'package:supabase/supabase.dart';

import '../../domain_shared/root_user.dart';
import '../../errors_shared/points_connection_error.dart';
import '../../errors_shared/points_error.dart';

import '../profile_function_names.dart' as functions;

import 'profile_repository_contract.dart';

class ProfileRepository extends IProfileRepository {
  final SupabaseClient _client;

  late final StreamController<RootUser> _profileStreamController;
  late final StreamSubscription _sub;

  late final Stream<RootUser> _profileStream;
  RootUser? currentProfile;

  ProfileRepository({required SupabaseClient client}) : _client = client {
    _startListening();
  }

  Stream<RootUser?> get profileStream => _profileStream;

  void _startListening() {
    assert(_client.auth.user() != null,
        "PointsProfileRepository needs a logged in SupabaseClient");

    _profileStreamController = StreamController.broadcast();
    _profileStream = _profileStreamController.stream;

    final userId = _client.auth.user()!.id;

    final searchParam = "${"profiles"}:id=eq.$userId";
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
    _addToStream(RootUser.fromJson(users[0]));
  }

  void _addToStream(RootUser newProfile) {
    currentProfile = newProfile;
    _profileStreamController.add(newProfile);
  }

  @override
  Future<void> updateAccount({
    String? name,
    String? status,
    String? bio,
    int? color,
    int? icon,
  }) async {
    final current = currentProfile!;
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

  void _error(PointsError error) {
    _profileStreamController.addError(error);
    close();
  }

  void close() {
    _profileStreamController.close();
    _sub.cancel();
  }
}
