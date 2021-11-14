import 'dart:async';

import 'package:async/async.dart';
import 'package:auth_repository/auth_repository.dart';
import 'package:faker/faker.dart';
import 'package:hive_test/hive_test.dart';
import 'package:supabase/supabase.dart' hide User;
import 'package:user_repositories/profile_repository.dart';
import 'package:user_repositories/relations_repository.dart';
import 'package:user_repositories/user_discovery_repository.dart';

import 'configure_supabase_client.dart';

class LoggedInUser {
  final SupabaseClient client;
  final User user;
  final String id, email, password;
  final AuthRepository auth;
  final ProfileRepository profile;
  final RelationsRepository relations;
  final UserDiscoveryRepository userDiscovery;

  LoggedInUser._(this.client,
      this.user,
      this.email,
      this.password,
      this.auth,
      this.profile,
      this.relations,
      this.userDiscovery,) : id = user.id;

  static Future<LoggedInUser> getRandom({String? name}) async {
    final supabaseClient = await getConfiguredSupabaseClient();
    final email = faker.internet.email();
    final password = faker.internet.password(length: 8);

    final sessionStore = FakeHiveBox<String>();
    final authRepository = AuthRepository(
      client: supabaseClient,
      sessionStore: sessionStore,
    );
    await authRepository.signUp(email, password);

    final profileRepository = ProfileRepository(
      client: supabaseClient,
    );

    final profileStream = StreamQueue(profileRepository.profileStream);

    final user = await profileStream.next;

    if (name != null) {
      profileRepository.updateAccount(name: name);

      final val = await Future.any([
        profileStream.next,
        Future.delayed(Duration(seconds: 1)),
      ]);
      if (val is User) {
        assert(val == user.copyWith(name: name));
      }
    }

    final relationsRepository = RelationsRepository(
      client: supabaseClient,
    );

    final userDiscoverRepository = UserDiscoveryRepository(
      client: supabaseClient,
    );

    return LoggedInUser._(
      supabaseClient,
      user,
      email,
      password,
      authRepository,
      profileRepository,
      relationsRepository,
      userDiscoverRepository,
    );
  }
}
