import 'package:supabase/supabase.dart';
import 'package:faker/faker.dart';
import 'package:user_repositories/user_discovery_repository.dart';

import 'configure_supabase_client.dart';
import 'package:async/async.dart';

import 'package:user_repositories/relations_repository.dart';
import 'package:user_repositories/profile_repository.dart';

class LoggedInUser {
  final SupabaseClient client;
  final RootUser user;
  final String id;
  final String email, password;
  final ProfileRepository profile;
  final RelationsRepository relations;
  final UserDiscoveryRepository userDiscovery;

  LoggedInUser._(
    this.client,
    this.user,
    this.profile,
    this.relations,
    this.userDiscovery,
    this.email,
    this.password,
  ) : id = user.id;

  static Future<LoggedInUser> getRandom() async {
    final supabaseClient = await getConfiguredSupabaseClient();
    final password = faker.internet.password(length: 8);
    final email = faker.internet.email();
    final response = await supabaseClient.auth.signUp(email, password);

    if (response.error != null) {
      throw Exception("Error on signup: ${response.error!.message}");
    }

    final profileRepository = ProfileRepository(
      client: supabaseClient,
    );

    final profileStream = StreamQueue(profileRepository.profileStream);

    final user = (await profileStream.next)!;

    final relationRepository = RelationsRepository(
      client: supabaseClient,
    );

    final userDiscoverRepository = UserDiscoveryRepository(
      client: supabaseClient,
    );

    return LoggedInUser._(
      supabaseClient,
      user,
      profileRepository,
      relationRepository,
      userDiscoverRepository,
      email,
      password,
    );
  }
}
