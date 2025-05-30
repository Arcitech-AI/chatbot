// widgets/user_tile.dart
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String email;
  final VoidCallback onTap;
  final String actionLabel;

  const UserTile({
    super.key,
    required this.email,
    required this.onTap,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(email),
      trailing: ElevatedButton(
        onPressed: onTap,
        child: Text(actionLabel),
      ),
    );
  }
}
