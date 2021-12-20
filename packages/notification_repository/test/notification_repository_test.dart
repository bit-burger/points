import 'package:async/async.dart';
import 'package:test/test.dart';

import 'package:supabase_testing_utils/supabase_testing_utils.dart';
import 'package:notification_repository/notification_repository.dart';

import 'notification_matcher.dart';

void main() {
  late LoggedInUser user1;
  late NotificationRepository sut;

  late LoggedInUser user2;

  setUp(() async {
    user1 = await LoggedInUser.get();
    sut = user1.notifications;

    user2 = await LoggedInUser.get();
  });

  test(
    'Create some notifications, then page them, mark the first read and then all read',
    () async {
      // Setup
      final relationsStream1 = StreamQueue(user1.relations.relationsStream);
      final relationsStream2 = StreamQueue(user2.relations.relationsStream);

      final profileStream1 = StreamQueue(user1.profile.profileStream);

      if (user1.relations.currentUserRelations == null) {
        await relationsStream1.next;
      }
      if (user2.relations.currentUserRelations == null) {
        await relationsStream2.next;
      }
      if (user1.profile.currentProfile == null) {
        await profileStream1.next;
      }

      Future<void> waitRelations() async {
        await relationsStream1.next;
        await relationsStream2.next;
      }

      // Expected notifications
      expect(
        user1.notifications.notificationStream,
        emitsInOrder(
          [
            NotificationMatcher.first(user1.id),
            NotificationMatcher(
              selfId: user1.id,
              secondActorId: user2.id,
              type: "relations_changed",
              messageData: {
                "change_type": "requested",
              },
            ),
            NotificationMatcher(
              selfId: user1.id,
              firstActorId: user2.id,
              secondActorId: user1.id,
              type: "relations_changed",
              messageData: {
                "change_type": "accepted",
              },
            ),
            NotificationMatcher(
              selfId: user1.id,
              secondActorId: user2.id,
              type: "relations_changed",
              messageData: {
                "change_type": "blocked",
              },
            ),
          ],
        ),
      );

      user1.relations.request(user2.id);
      await waitRelations();

      user2.relations.accept(user1.id);
      await waitRelations();

      user1.relations.block(user2.id);
      await waitRelations();

      // Create notifications

      // Expected paging and marking read results

      // Paging

      // Marking read
    },
  );
}
