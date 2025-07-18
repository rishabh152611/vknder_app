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
    return Card(
      color: Colors.white.withOpacity(0.08),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
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
            fontWeight: FontWeight.normal,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        isThreeLine: isThreeLine,
      ),
    );
  }
}
