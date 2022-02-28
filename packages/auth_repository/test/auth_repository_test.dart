import 'dart:convert';

import 'package:faker/faker.dart';
import 'package:hive/hive.dart';
import 'package:supabase/supabase.dart';
import 'package:test/test.dart';

import 'package:auth_repository/auth_repository.dart';

import 'package:hive_test/hive_test.dart';
import 'package:supabase_testing_utils/supabase_testing_utils.dart';

void main() {
  late SupabaseClient client;

  setUp(() async {
    client = await getConfiguredSupabaseClient();
  });

  group("Auto sign in", () {
    late IAuthRepository sut1;
    late IAuthRepository sut2;
    late Box<String> sessionStore;

    setUp(() {
      sessionStore = FakeHiveBox<String>();

      sut1 = AuthRepository(
        client: client,
        sessionStore: sessionStore,
      );
      sut2 = AuthRepository(
        client: client,
        sessionStore: sessionStore,
      );
    });

    test("auto sign in", () async {
      final email = faker.internet.email();
      final password = faker.internet.password(length: 6);

      await sut1.signUp(email, password);

      await client.auth.signOut();

      sut2.tryAutoSignIn();
    });

    test("log in and log out, then fail auto sign in", () async {
      final email = faker.internet.email();
      final password = faker.internet.password(length: 6);

      await sut1.signUp(email, password);
      await sut1.logOut();

      expect(
        sut2.tryAutoSignIn(),
        throwsA(TypeMatcher<AuthAutoSignInFailedError>()),
      );
    });

    test("log in, change sessionToken, then fail auto sign in", () async {
      final email = faker.internet.email();
      final password = faker.internet.password(length: 6);

      await sut1.signUp(email, password);

      await client.auth.signOut();

      final key = "sessionTokenJsonStr";
      final rawSession = sessionStore.get(key)!;
      final Map<String, dynamic> sessionJson = jsonDecode(rawSession);
      final session = Session.fromJson(sessionJson);

      final fakeSession = session.copyWith(
        accessToken: "/" + session.accessToken.substring(1),
      );

      sessionStore.put(key, fakeSession.persistSessionString);

      expect(
        sut2.tryAutoSignIn(),
        throwsA(TypeMatcher<AuthAutoSignInFailedError>()),
      );
    }, skip: true);

    tearDown(() async {
      try {
        await sut1.logOut();
      } on Exception {}
      try {
        await sut2.logOut();
      } on Exception {}
    });
  });

  group("Auth flow", () {
    late IAuthRepository sut;
    setUp(() {
      final sessionStore = FakeHiveBox<String>();

      sut = AuthRepository(
        client: client,
        sessionStore: sessionStore,
      );
    });

    test("log in and destroy account", () async {
      final email = faker.internet.email();
      final password = faker.internet.password(length: 6);

      await sut.signUp(email, password);

      await sut.deleteAccount();
    });

    test("log in and sign up repeatedly, then can't sign up again", () async {
      final email = faker.internet.email();
      final password = faker.internet.password(length: 6);

      await sut.signUp(email, password);
      await sut.logOut();

      Future<void> logInAndOut() async {
        await sut.logIn(email, password);
        await sut.logOut();
      }

      await logInAndOut();
      await logInAndOut();
      await logInAndOut();

      try {
        await sut.signUp(email, password);
        fail("Sign up should throw, as the email is already signed up");
      } on AuthError catch (e) {
        expect(e.type, AuthErrorType.email);
      } catch (e) {
        fail("Wrong exception");
      }
    });

    test("password too short", () async {
      final email = faker.internet.email();
      final password = faker.internet.password(length: 5);

      expect(sut.signUp(email, password), throwsA(TypeMatcher<AuthError>()));
    });

    tearDown(() async {
      try {
        await sut.logOut();
      } on Exception {}
    });
  });
}
