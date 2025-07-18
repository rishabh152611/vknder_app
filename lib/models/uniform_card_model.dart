import 'package:flutter/material.dart';

class UniformCard extends StatelessWidget {
  final IconData avatar;
  final Color avatarColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final bool isThreeLine;
  final VoidCallback? onTap;

  const UniformCard({
    super.key,
    required this.avatar,
    required this.avatarColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.isThreeLine = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Card(
        color: const Color(0xFFC4ABE1),
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 44), // Space for the arrow
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: avatarColor,
                  child: Icon(avatar, color: Colors.white, size: 22),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  subtitle,
                  maxLines: isThreeLine ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                isThreeLine: isThreeLine,
              ),
            ),
            // Center the trailing icon vertically at the right edge
            if (trailing != null)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(child: trailing!),
              ),
          ],
        ),
      ),
    );
  }
}
