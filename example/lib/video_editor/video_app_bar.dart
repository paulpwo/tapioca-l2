import 'package:flutter/material.dart';

class VideoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const VideoAppBar({
    Key? key,
    required this.isEditfloatText,
    required this.onAudioIconPressed,
    required this.onRemoveTextPressed,
    required this.onInsertTextPressed,
    required this.onSavePressed,
    required this.color,
  }) : super(key: key);

  final ValueNotifier<bool> isEditfloatText;
  final VoidCallback onAudioIconPressed;
  final VoidCallback onRemoveTextPressed;
  final VoidCallback onInsertTextPressed;
  final VoidCallback onSavePressed;
  final Color color;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: color,
      elevation: 0,
      title: const Text(''),
      actions: [
        ValueListenableBuilder(
          valueListenable: isEditfloatText,
          builder: (BuildContext context, bool value, Widget? child) {
            if (!value) {
              return Row(
                children: [
                  IconButton(
                    onPressed: onAudioIconPressed,
                    icon: const Icon(Icons.mic_none_sharp, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: onInsertTextPressed,
                    icon: const Icon(Icons.text_fields, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: onSavePressed,
                    icon: const Icon(Icons.download, color: Colors.white),
                  ),
                ],
              );
            }
            return Row(
              children: [
                IconButton(
                  onPressed: onRemoveTextPressed,
                  icon: const Icon(Icons.delete, color: Colors.white),
                ),
                IconButton(
                  onPressed: onInsertTextPressed,
                  icon: const Icon(Icons.text_fields, color: Colors.white),
                ),
              ],
            );
          },
        ),
      ],
      // agregar más widgets, como iconos o botones aquí
    );
  }

  void _save(BuildContext context) {
    // implementación de la función _save
  }
}
