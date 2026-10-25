import 'package:flutter/material.dart';
import '../models/note.dart';

class CardView extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CardView({
    super.key,
    required this.note,
    this.onTap,
    this.onLongPress,
  });

  factory CardView.fromMap(
    Map<String, dynamic> data, {
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return CardView(
      note: Note.fromMap(data),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = note.title;
    final content = note.content;
    final isPinned = note.pin;
    final hasTitle = title.trim().isNotEmpty;
    final hasContent = content.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasTitle || isPinned)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasTitle)
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF202124),
                              height: 1.25,
                            ),
                          ),
                        )
                      else
                        const Spacer(),
                      if (isPinned)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.push_pin,
                            size: 16,
                            color: Color(0xFF5F6368),
                          ),
                        ),
                    ],
                  ),

                if (hasTitle && hasContent) const SizedBox(height: 8),

                if (hasContent)
                  Text(
                    content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF3C4043),
                      height: 1.35,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
