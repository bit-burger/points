import 'package:supabase_testing_utils/supabase_testing_utils.dart';
import 'package:test/test.dart';


void main() {
  test("Finds user via email", () async {
    final user1 = await LoggedInUser.getRandom();
    final user2 = await LoggedInUser.getRandom();

    final result = await user2.userDiscovery.getUserByEmail(email: user1.email);

    expect(user1.user, result);
  });
}
