import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:ionicons/ionicons.dart';
import 'package:points/widgets/neumorphic_box.dart';

class NotificationWidget extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final String message;
  final Color color;
  final bool lessSpacing;
  final bool read;

  const NotificationWidget(
      {this.icon,
      this.title,
      this.lessSpacing = false,
      required this.message,
      required this.color,
      this.read = false});

  @override
  Widget build(BuildContext context) {
    return NeumorphicBox(
      listPadding: true,
      lessSpacing: lessSpacing,
      child: Padding(
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
      ),
      style: NeumorphicStyle(
        color: color,
        depth: 8,
      ),
    );
  }
}
