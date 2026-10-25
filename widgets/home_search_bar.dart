import 'package:flutter/material.dart';

class KeepSearchBar extends StatelessWidget {
  final VoidCallback onMenuTap;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final VoidCallback? onClear;

  const KeepSearchBar({
    super.key,
    required this.onMenuTap,
    this.onChanged,
    this.controller,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF5F6368)),
            onPressed: onMenuTap,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm',
                hintStyle: TextStyle(
                  color: Color(0xFF80868B),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(
                color: Color(0xFF202124),
                fontSize: 16,
              ),
            ),
          ),
          if (controller != null && controller!.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF5F6368)),
              onPressed: () {
                controller?.clear();
                if (onClear != null) {
                  onClear!();
                } else if (onChanged != null) {
                  onChanged!('');
                }
              },
            ),
        ],
      ),
    );
  }
}

