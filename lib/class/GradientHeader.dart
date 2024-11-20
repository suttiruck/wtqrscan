import 'package:flutter/material.dart';

class GradientHeader extends StatelessWidget {
  final String text;
  final Color color1;
  final Color color2;
  final double borderRadius;
  final IconData icon;

  const GradientHeader({
    Key? key,
    required this.text,
    required this.color1,
    required this.color2,
    this.borderRadius = 7.0, // ค่าความโค้งเริ่มต้น
    this.icon = Icons.info, // ค่าเริ่มต้นของไอคอน
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 360 ? 14.0 : 18.0;
    final iconSize24 = screenWidth < 360 ? 22.0 : 24.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: iconSize24,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
