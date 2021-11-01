import 'package:points_repositories/points_repositories.dart';
import 'package:supabase/supabase.dart';
import 'package:faker/faker.dart';

import 'configure_supabase_client.dart';
import 'package:async/async.dart';

class LoggedInUser {
  final SupabaseClient client;
  final RootUser user;
  final String id;
  final PointsProfileRepository profile;
  final PointsRelationsRepository relations;

  LoggedInUser._(
    this.client,
    this.user,
    this.profile,
    this.relations,
  ) : id = user.id;

  static Future<LoggedInUser> getRandom() async {
    final supabaseClient = await getConfiguredSupabaseClient();
    final password = faker.internet.password(length: 8);
    final email = faker.internet.email();
    await supabaseClient.auth.signUp(email, password);

    final profileRepository = PointsProfileRepository(
      client: supabaseClient,
    );

    final profileStream = StreamQueue(profileRepository.profileStream);

    assert((await profileStream.next) == null);
    profileRepository.createAccount(faker.randomGenerator.string(8, min: 3));
    final user = (await profileStream.next)!;

    final relationRepository = PointsRelationsRepository(
      client: supabaseClient,
    );

    return LoggedInUser._(
      supabaseClient,
      user,
      profileRepository,
      relationRepository,
    );
  }
}
