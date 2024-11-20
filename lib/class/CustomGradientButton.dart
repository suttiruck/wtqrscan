import 'package:flutter/material.dart';

class CustomGradientButton extends StatelessWidget {
  final String text; // ข้อความในปุ่ม
  final IconData icon; // ไอคอนในปุ่ม
  final VoidCallback onPressed; // ฟังก์ชันที่ทำงานเมื่อกดปุ่ม
  final List<Color> gradientColors; // สีไล่ระดับ

  const CustomGradientButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.gradientColors = const [Colors.blue, Colors.blueAccent], // สีเริ่มต้น
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 360 ? 14.0 : 16.0;
    final iconSize24 = screenWidth < 360 ? 22.0 : 24.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      width: double.infinity, // กำหนดความกว้างให้เต็มหน้าจอ
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50), // ขนาดขั้นต่ำของปุ่ม
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize24, color: Colors.white),
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
      ),
    );
  }
}
