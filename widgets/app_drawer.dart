import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/archive_screen.dart';

class KeepDrawer extends StatelessWidget {
  final int selectedIndex;

  const KeepDrawer({
    super.key,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 225,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            const Padding(
              padding: EdgeInsets.fromLTRB(25, 20, 24, 8),
              child: Text(
                'Ghi chú',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF202124),
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Ghi chú
            _DrawerItem(
              icon: Icons.lightbulb_outline,
              label: 'Ghi chú',
              isSelected: selectedIndex == 0,
              onTap: () {
                final navigator = Navigator.of(context);
                navigator.pop();
                if (selectedIndex != 0) {
                  if (navigator.canPop()) {
                    navigator.pop();
                  } else {
                    navigator.pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  }
                }
              },
            ),

            // Lưu trữ
            _DrawerItem(
              icon: Icons.archive_outlined,
              label: 'Lưu trữ',
              isSelected: selectedIndex == 1,
              onTap: () {
                final navigator = Navigator.of(context);
                navigator.pop();
                if (selectedIndex != 1) {
                  navigator.push(
                    MaterialPageRoute(builder: (_) => const ArchiveScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1.5),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0x265C6BC0)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            size: 24,
            color: isSelected
                ? const Color(0xFF5C6BC0)
                : const Color(0xFF5F6368),
          ),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? const Color(0xFF5C6BC0)
                  : const Color(0xFF202124),
            ),
          ),
          dense: true,
          visualDensity: const VisualDensity(vertical: -1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
