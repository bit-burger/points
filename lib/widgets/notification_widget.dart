import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';

/// Custom widget for a notification
class NotificationWidget extends StatelessWidget {
  static final timeDateFormat = DateFormat("HH:mm");

  final IconData? icon;
  final String? title;
  final String message;
  final Color color;
  final DateTime? date;
  final bool lessSpacing;
  final bool read;

  // Will be depth of 4, if this is not null, otherwise the depth is 8
  final VoidCallback? onPressed;

  const NotificationWidget({
    this.icon,
    this.title,
    this.lessSpacing = false,
    required this.message,
    this.date,
    required this.color,
    this.read = false,
    this.onPressed,
  });

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(
              icon,
            ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.caption,
                  ),
                Text(
                  message,
                  maxLines: 10,
                  overflow: TextOverflow.fade,
                ),
                if (date != null) ...[
                  SizedBox(
                    height: 4,
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      timeDateFormat.format(date!),
                      style: Theme.of(context)
                          .textTheme
                          .caption!
                          .copyWith(color: Theme.of(context).hintColor),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 12),
          Icon(read ? Ionicons.checkmark_outline : null),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (onPressed == null) {
      return Neumorphic(
        margin: lessSpacing
            ? EdgeInsets.symmetric(horizontal: 20)
            : EdgeInsets.all(20),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: _buildContent(context),
        style: NeumorphicStyle(
          color: color,
          depth: 8,
        ),
      );
    }
    return NeumorphicButton(
      margin: lessSpacing
          ? EdgeInsets.symmetric(horizontal: 20)
          : EdgeInsets.all(20),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: _buildContent(context),
      onPressed: onPressed,
      style: NeumorphicStyle(
        color: color,
      ),
    );
  }
}
