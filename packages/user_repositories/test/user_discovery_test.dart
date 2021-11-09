import 'package:supabase_testing_utils/supabase_testing_utils.dart';
import 'package:test/test.dart';

void main() {
  test("Finds user via email", () async {
    final user1 = await LoggedInUser.getRandom();
    final user2 = await LoggedInUser.getRandom();

    final result = await user2.userDiscovery.getUserByEmail(email: user1.email);

    // TODO: Fix user equals
    expect(user1.user, result);
  });

  group("Query testing", () {
    final users = <LoggedInUser>[];

    setUpAll(() async {
      final names = [
        "toby",
        "tobr",
        "kony",
        "tom",
        "aram",
        "olevenba",
      ];
      for (final name in names) {
        final user = await LoggedInUser.getRandom(name: name);
        users.add(user);
      }
    });

    test("Searching ranks correctly for name", () async {
      final result = await users.last.userDiscovery.queryUsers(
        nameQuery: "tony",
      );

      print("Query for tony: ");
      for (final rawUser in result) {
        print(rawUser.name);
      }
    });

    tearDownAll(() async {
      for (final user in users) {
        await user.auth.deleteAccount();
      }
    });
  });
}
