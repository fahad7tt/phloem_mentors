import 'package:flutter/material.dart';

class ProfileListTile extends StatelessWidget {
  final Widget leading;
  final Widget trailing;
  final String title;
  final VoidCallback? onTap;

  const ProfileListTile({super.key, 
    required this.leading,
    required this.trailing,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }
}