import 'package:hive_test/hive_test.dart';
import 'package:test/test.dart';
import 'package:faker/faker.dart';
import 'package:supabase/supabase.dart' hide User;
import 'package:supabase_testing_utils/supabase_testing_utils.dart';
import 'package:user_repositories/profile_repository.dart';
import 'package:auth_repository/auth_repository.dart';

import 'package:async/async.dart';

void main() async {
  late SupabaseClient loggedInClient;
  late ProfileRepository sut;
  late AuthRepository authRepository;

  setUp(() async {
    final email = faker.internet.email();
    final password = faker.internet.password(length: 8);
    final supabaseClient = await getConfiguredSupabaseClient();

    await supabaseClient.auth.signUp(email, password);

    loggedInClient = supabaseClient;

    sut = ProfileRepository(client: loggedInClient);
    authRepository =
        AuthRepository(client: loggedInClient, sessionStore: FakeHiveBox());
  });

  test("create account, update it and delete it", () async {
    final userId = loggedInClient.auth.user()!.id;

    final name2 = faker.randomPointsName();
    final status2 = faker.randomGenerator.string(16, min: 10);
    final color2 = faker.randomGenerator.integer(9);

    final name3 = faker.randomPointsName();
    final bio3 = faker.lorem.sentence();

    final bio4 = faker.lorem.sentence();
    final icon4 = faker.randomGenerator.integer(255);

    final exRU1 = User.defaultWith(id: userId);
    final exRU2 = exRU1.copyWith(name: name2, status: status2, color: color2);
    final exRU3 = exRU2.copyWith(name: name3, bio: bio3);
    final exRU4 = exRU3.copyWith(bio: bio4, icon: icon4);

    expect(
      sut.profileStream,
      emitsInOrder([
        exRU1,
        exRU2,
        exRU3,
        exRU4,
      ]),
    );

    final profileStream = StreamQueue(sut.profileStream);

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

    sut.close();

    await authRepository.deleteAccount();
  });
}
