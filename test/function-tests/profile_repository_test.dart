import 'package:auth_repository/auth_repository.dart';
import 'package:faker/faker.dart';
import 'package:supabase/supabase.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/configure_supabase_client.dart';
import 'helpers/fake_hive_box.dart';

import 'package:points_repositories/points_repositories.dart';

import 'package:async/async.dart';

void main() async {
  late SupabaseClient loggedInClient;
  late PointsProfileRepository sut;

  setUp(() async {
    final email = faker.internet.email();
    final password = faker.internet.password(length: 8);
    final supabaseClient = await getConfiguredSupabaseClient();
    final sessionStore = FakeHiveBox<String>();

    final authRepo = AuthRepository(
      sessionStore: sessionStore,
      authClient: supabaseClient.auth,
    );

    await authRepo.signUp(email, password);

    loggedInClient = supabaseClient;

    sut = PointsProfileRepository(client: loggedInClient);
  });

  test("create account, update it and delete it", () async {
    final userId = loggedInClient.auth.user()!.id;
    final name1 = faker.randomGenerator.string(8, min: 3);

    final name2 = faker.randomGenerator.string(8, min: 3);
    final status2 = faker.randomGenerator.string(16, min: 10);
    final color2 = faker.randomGenerator.integer(9);

    final name3 = faker.randomGenerator.string(8, min: 3);
    final bio3 = faker.lorem.sentence();

    final bio4 = faker.lorem.sentence();
    final icon4 = faker.randomGenerator.integer(255);

    final exRU1 = RootUser.defaultWith(id: userId, name: name1);
    final exRU2 = exRU1.copyWith(name: name2, status: status2, color: color2);
    final exRU3 = exRU2.copyWith(name: name3, bio: bio3);
    final exRU4 = exRU3.copyWith(bio: bio4, icon: icon4);

    expect(
      sut.profileStream,
      emitsInOrder([
        isNull,
        exRU1,
        exRU2,
        exRU3,
        exRU4,
        isNull,
      ]),
    );

    final profileStream = StreamQueue(sut.profileStream);

    await profileStream.next;
    await sut.createAccount(name1);

    await profileStream.next;
    await sut.updateAccount(
      name: name2,
      status: status2,
      color: color2,
    );

    await profileStream.next;
    await sut.updateAccount(
      name: name3,
      bio: bio3,
    );

    await profileStream.next;
    await sut.updateAccount(
      bio: bio4,
      icon: icon4,
    );

    await profileStream.next;
    await sut.deleteAccount();

    await profileStream.next;

    sut.close();
  });
}
