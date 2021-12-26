import 'package:async/async.dart';
import 'package:test/test.dart';

import 'package:notification_repository/notification_repository.dart';
import 'package:supabase_testing_utils/supabase_testing_utils.dart';

import 'notification_matcher.dart';

void main() {
  test(
    'Create some notifications, then page them, mark the first read and then all read',
    () async {
      // Setup
      final user1 = await LoggedInUser.get();
      final user2 = await LoggedInUser.get();

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

      final notificationStream1 = StreamQueue(
        user1.notifications.notificationStream,
      );
      final notificationStream2 = StreamQueue(
        user1.notifications.notificationStream,
      );

      Future<void> waitRelationsAndNotifications() async {
        await Future.wait(
          [
            relationsStream1.next,
            notificationStream1.next,
            relationsStream2.next,
            notificationStream2.next,
          ],
        );
      }

      // Expected notifications
      final user1ExpectedNotifications = [
        NotificationMatcher.first(user1.id),
        NotificationMatcher(
          selfId: user1.id,
          secondActorId: user2.id,
          type: NotificationType.changedRelation,
          messageData: {
            "change_type": "requested",
          },
          hasRead: true,
        ),
        NotificationMatcher(
          selfId: user1.id,
          firstActorId: user2.id,
          secondActorId: user1.id,
          type: NotificationType.changedRelation,
          messageData: {
            "change_type": "accepted",
          },
          hasRead: false,
        ),
        NotificationMatcher(
          selfId: user1.id,
          secondActorId: user2.id,
          type: NotificationType.changedRelation,
          messageData: {
            "change_type": "blocked",
          },
          hasRead: true,
        ),
        NotificationMatcher(
          selfId: user1.id,
          secondActorId: user2.id,
          type: NotificationType.changedRelation,
          messageData: {
            "change_type": "unblocked",
          },
          hasRead: true,
        ),
      ];

      final user2ExpectedNotifications = [
        NotificationMatcher.first(user2.id),
        ...user1ExpectedNotifications.sublist(1).map(
              (expectedNotification) => expectedNotification.copyWith(
                  selfId: user2.id, hasRead: !expectedNotification.hasRead),
            ),
      ];

      expect(
        user1.notifications.notificationStream,
        emitsInOrder(
          user1ExpectedNotifications.sublist(1, 4),
        ),
      );

      expect(
        user2.notifications.notificationStream,
        emitsInOrder(
          user2ExpectedNotifications.sublist(1, 4),
        ),
      );

      // Create notifications
      user1.relations.request(user2.id);
      await waitRelationsAndNotifications();

      user2.relations.accept(user1.id);
      await waitRelationsAndNotifications();

      user1.relations.block(user2.id);
      await waitRelationsAndNotifications();

      final user1ExpectedNotificationsInOrder =
          user1ExpectedNotifications.reversed.toList();

      // Expected paging and marking read results
      user1.notifications.startListeningToPagingStream(
        onlyUnread: false,
        startMaxNotificationCount: 2,
      );

      final notificationQueue = StreamQueue(
        user1.notifications.notificationsPagingStream!,
      );

      // (Because of page stream, main stream shouldn't be continued until done)
      expect(user1.notifications.notificationStream, emitsDone);

      // Get beginning results
      final notifications1 = await notificationQueue.next;
      expect(
        notifications1.notifications,
        user1ExpectedNotificationsInOrder.sublist(1, 3),
      );
      expect(notifications1.allNotificationsFetched, false);

      // Fetch more
      user1.notifications.fetchMoreNotifications(howMany: 1);
      final notifications2 = await notificationQueue.next;
      expect(
        notifications2.notifications,
        user1ExpectedNotificationsInOrder.sublist(1, 4),
      );
      expect(notifications2.allNotificationsFetched, false);

      // Fetch rest
      user1.notifications.fetchMoreNotifications(howMany: 100);
      final notifications3 = await notificationQueue.next;
      expect(
        notifications3.notifications,
        user1ExpectedNotificationsInOrder.sublist(1, 5),
      );
      expect(notifications3.allNotificationsFetched, true);

      // Mark first notification read
      user1.notifications.markNotificationRead(
        notificationId: notifications3.notifications.last.id,
      );
      final notifications4 = await notificationQueue.next;
      final expectedNotifications4 = [
        ...user1ExpectedNotificationsInOrder.sublist(1, 4),
        NotificationMatcher.first(user1.id).copyWith(hasRead: true),
      ];
      expect(
        notifications4.notifications,
        expectedNotifications4,
      );
      expect(notifications4.allNotificationsFetched, true);

      // Create another notification

      // (test notification also coming to the normal notification stream,
      // because user1 is listening to the page stream,
      // user1 shouldn't get another event)
      expect(
        user2.notifications.notificationStream,
        emits(user2ExpectedNotifications.last),
      );

      user1.relations.unblock(user2.id);
      await relationsStream1.next;
      await relationsStream2.next;

      final notifications5 = await notificationQueue.next;
      expect(
        notifications5.notifications,
        [
          user1ExpectedNotificationsInOrder.first,
          ...expectedNotifications4,
        ],
      );
      expect(notifications5.allNotificationsFetched, true);

      // Closing
      user1.notifications.stopPagingStream();

      await user1.close();
      await user2.close();
    },
  );
}
