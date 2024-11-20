import 'package:flutter/material.dart';

class CustomBackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final IconData? leadingIcon;
  final Color color1;
  final Color color2;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;
  final bool showActionButton;
  final VoidCallback? onBackPressed;

  const CustomBackAppBar({
    Key? key,
    required this.titleText,
    required this.color1,
    required this.color2,
    this.leadingIcon,
    this.actionIcon,
    this.onActionPressed,
    this.showActionButton = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 360 ? 16.0 : 20.0;
    final iconSize28 = screenWidth < 360 ? 26.0 : 28.0;
    final iconSize26 = screenWidth < 360 ? 24.0 : 26.0;

    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 4,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white, size: iconSize28),
        onPressed: onBackPressed ??
            () {
              Navigator.pop(context);
            },
      ),
      title: Row(
        children: [
          if (leadingIcon != null)
            Icon(
              leadingIcon,
              size: iconSize26,
              color: Colors.white,
            ),
          if (leadingIcon != null) const SizedBox(width: 8),
          Text(
            titleText,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
      titleSpacing: 0,
      actions: [
        if (showActionButton && actionIcon != null)
          IconButton(
            icon: Icon(
              actionIcon,
              color: Colors.white,
              size: iconSize26,
            ),
            onPressed: onActionPressed,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
