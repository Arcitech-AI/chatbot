// widgets/user_tile.dart
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  // final String email;
  final String name;
  final VoidCallback? onTap;
  final String actionLabel;

  const UserTile({
    super.key,
    // required this.email,
    required this.name,
    this.onTap,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Container(
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
            onTap != null
                ? ElevatedButton(onPressed: onTap, child: Text(actionLabel))
                : Container(),
          ],
        ),
      ),
    );
  }
}
