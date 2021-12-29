import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:ionicons/ionicons.dart';

class NotificationWidget extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final String message;
  final Color color;
  final bool lessSpacing;
  final bool read;

  // Will be depth of 4, if this is not null, otherwise the depth is 8
  final VoidCallback? onPressed;

  const NotificationWidget({
    this.icon,
    this.title,
    this.lessSpacing = false,
    required this.message,
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
              ],
            ),
          ),
          if (read) ...[
            SizedBox(width: 12),
            Icon(Ionicons.checkmark_outline),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(onPressed == null) {
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
