import 'dart:async';

import 'package:async/async.dart';
import 'package:auth_repository/auth_repository.dart';
import 'package:chat_repository/chat_repository.dart';
import 'package:faker/faker.dart';
import 'package:hive_test/hive_test.dart';
import 'package:notification_repository/notification_repository.dart';
import 'package:supabase/supabase.dart' hide User;
import 'package:user_repositories/profile_repository.dart';
import 'package:user_repositories/relations_repository.dart';
import 'package:user_repositories/user_discovery_repository.dart';

import 'configure_supabase_client.dart';

class LoggedInUser {
  final SupabaseClient client;
  final String id, email, password;
  final AuthRepository auth;
  final ProfileRepository profile;
  final RelationsRepository relations;
  final UserDiscoveryRepository userDiscovery;
  final ChatRepository chat;
  final NotificationRepository notifications;

  RelatedUser get user => RelatedUser.fromJson(
        profile.currentProfile!.toJson(),
        // just for testing,
        // RelatedUser does not check the chatId or relationType
        chatId: "",
        relationType: RelationType.friend,
      );

  LoggedInUser._(
    this.client,
    this.id,
    this.email,
    this.password,
    this.auth,
    this.profile,
    this.relations,
    this.userDiscovery,
    this.chat,
    this.notifications,
  );

  Future<void> close() async {
    notifications.close();
    profile.close();
    relations.close();
    chat.close();
    await auth.logOut();
  }

  Future<LoggedInUser> copyAndRefresh() {
    return get(
      signIn: true,
      email: email,
      password: password,
    );
  }

  static Future<LoggedInUser> get({
    String? name,
    bool signIn = false,
    String? email,
    String? password,
  }) async {
    final supabaseClient = await getConfiguredSupabaseClient();

    email ??= faker.internet.email();
    password ??= faker.internet.password(length: 8);

    final sessionStore = FakeHiveBox<String>();
    final authRepository = AuthRepository(
      client: supabaseClient,
      sessionStore: sessionStore,
    );

    if (signIn) {
      await authRepository.logIn(email, password);
    } else {
      await authRepository.signUp(email, password);
    }

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

    final chatRepository = ChatRepository(
      client: supabaseClient,
    );

    final notificationRepository = NotificationRepository(
      client: supabaseClient,
    );

    return LoggedInUser._(
      supabaseClient,
      user.id,
      email,
      password,
      authRepository,
      profileRepository,
      relationsRepository,
      userDiscoverRepository,
      chatRepository,
      notificationRepository,
    );
  }
}
