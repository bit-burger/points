import 'package:user_repositories/relations_repository.dart';
import 'package:test/test.dart';

import '../../supabase_testing_utils/lib/src/logged_in_user.dart';
import 'package:async/async.dart';

void main() {
  late LoggedInUser user1;
  late LoggedInUser user2;

  setUp(() async {
    user1 = await LoggedInUser.getRandom();
    user2 = await LoggedInUser.getRandom();
  });

  test("request, accept, unfriend, block, unblock", () async {
    final relationsStream1 = StreamQueue(user1.relations.relationsStream);
    final relationsStream2 = StreamQueue(user2.relations.relationsStream);

    if (user1.relations.currentUserRelations == null) {
      await relationsStream1.next;
    }

    if (user2.relations.currentUserRelations == null) {
      await relationsStream2.next;
    }

    // user1 requests user2
    user1.relations.request(user2.id);

    final a1 = await relationsStream1.next;
    expect(
      a1,
      UserRelations([], [], [user2.user], [], []),
    );

    final a2 = await relationsStream2.next;
    expect(
      a2,
      UserRelations([], [user1.user], [], [], []),
    );

    // user2 accepts the request of user1
    user2.relations.accept(user1.id);
    // await w();

    final b1 = await relationsStream1.next;
    expect(
      b1,
      UserRelations([user2.user], [], [], [], []),
    );

    final b2 = await relationsStream2.next;
    expect(
      b2,
      UserRelations([user1.user], [], [], [], []),
    );

    // user1 unfriends user2
    user1.relations.unfriend(user2.id);

    final c1 = await relationsStream1.next;
    expect(
      c1,
      UserRelations([], [], [], [], []),
    );

    final c2 = await relationsStream2.next;
    expect(
      c2,
      UserRelations([], [], [], [], []),
    );

    // user2 blocks user1
    user2.relations.block(user1.id);

    final d1 = await relationsStream1.next;
    expect(
      d1,
      UserRelations([], [], [], [], [user2.user]),
    );

    final d2 = await relationsStream2.next;
    expect(
      d2,
      UserRelations([], [], [], [user1.user], []),
    );

    // user1 blocks user2
    user1.relations.block(user2.id);

    final e = await relationsStream1.next;
    expect(
      e,
      UserRelations([], [], [], [user2.user], []),
    );

    // user1 unblocks user2
    user1.relations.unblock(user2.id);

    final f = await relationsStream1.next;
    expect(
      f,
      UserRelations([], [], [], [], [user2.user]),
    );

    // user2 unblocks user1
    user2.relations.unblock(user1.id);

    final g1 = await relationsStream1.next;
    expect(
      g1,
      UserRelations([], [], [], [], []),
    );

    final g2 = await relationsStream2.next;
    expect(
      g2,
      UserRelations([], [], [], [], []),
    );

    // Setup for user2 requesting user1
    Future<void> request() async {
      user2.relations.request(user1.id);

      final h1 = await relationsStream1.next;
      expect(
        h1,
        UserRelations([], [user2.user], [], [], []),
      );

      final h2 = await relationsStream2.next;
      expect(
        h2,
        UserRelations([], [], [user1.user], [], []),
      );
    }

    // user1 rejects user2
    await request();

    user1.relations.reject(user2.id);

    final i1 = await relationsStream1.next;
    expect(
      i1,
      UserRelations([], [], [], [], []),
    );

    final i2 = await relationsStream2.next;
    expect(
      i2,
      UserRelations([], [], [], [], []),
    );

    // user1 takes back request to user2
    await request();

    user2.relations.cancelRequest(user1.id);

    final j1 = await relationsStream1.next;
    expect(
      j1,
      UserRelations([], [], [], [], []),
    );

    final j2 = await relationsStream2.next;
    expect(
      j2,
      UserRelations([], [], [], [], []),
    );

    user1.relations.close();
    user2.relations.close();

    user1.profile.close();
    user2.profile.close();
  });
}
