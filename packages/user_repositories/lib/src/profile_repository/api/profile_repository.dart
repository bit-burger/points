import 'dart:async';

import 'package:supabase/supabase.dart' hide User;

import '../../domain_shared/user.dart';
import '../../errors_shared/points_connection_error.dart';
import '../../errors_shared/points_error.dart';
import '../profile_function_names.dart' as functions;
import 'profile_repository_contract.dart';

/// Supabase implementation of [IProfileRepository]
class ProfileRepository extends IProfileRepository {
  final SupabaseClient _client;

  late final StreamController<User> _profileStreamController;
  late final StreamSubscription _sub;

  late final Stream<User> _profileStream;
  User? currentProfile;

  ProfileRepository({required SupabaseClient client}) : _client = client {
    _startListening();
  }

  Stream<User> get profileStream => _profileStream;

  /// Start listening to supabase realtime
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
      _error(
        PointsConnectionError(),
      );
    });
  }

  // TODO: Handle with error, when no profile is found/0 rows
  void _handleUpdate(final List<Map<String, dynamic>> users) async {
    if (users.isNotEmpty) {
      // TODO: Temp fix
      if (users[0]["color"] is String) {
        users[0]["color"] = int.parse(users[0]["color"]);
      }
      if (users[0]["icon"] is String) {
        users[0]["icon"] = int.parse(users[0]["icon"]);
      }
      if (users[0]["points"] is String) {
        users[0]["points"] = int.parse(users[0]["points"]);
      }
      if (users[0]["gives"] is String) {
        users[0]["gives"] = int.parse(users[0]["gives"]);
      }
      _addToStream(User.fromJson(users[0]));
    }
  }

  void _addToStream(User newProfile) {
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
  }

  /// Close streams and cancel realtime
  void close() {
    _profileStreamController.close();
    _sub.cancel();
  }
}
