import 'package:flutter/material.dart';

class CustomGradientAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String titleText;
  final IconData? leadingIcon;
  final IconData? ActionIcon; // คงชื่อ ActionIcon ไว้ตามที่กำหนด
  final Color color1;
  final Color color2;
  final bool showActionButton;
  final VoidCallback? onActionPressed;

  const CustomGradientAppBar({
    Key? key,
    required this.titleText,
    required this.color1,
    required this.color2,
    this.leadingIcon,
    this.ActionIcon, // ใช้ ActionIcon โดยไม่ต้องเปลี่ยนชื่อ
    this.showActionButton = true,
    this.onActionPressed,
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
      title: Row(
        children: [
          if (leadingIcon != null)
            Icon(
              leadingIcon,
              size: iconSize28,
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
      actions: [
        if (showActionButton && ActionIcon != null)
          IconButton(
            icon: Icon(
              ActionIcon, // ใช้ ActionIcon ที่กำหนดไว้
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
