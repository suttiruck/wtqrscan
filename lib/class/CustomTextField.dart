import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText; // สำหรับการซ่อนข้อความ (เช่น รหัสผ่าน)
  final String? hintText; // ข้อความแนะนำใน TextField

  const CustomTextField({
    Key? key,
    required this.controller, // บังคับส่ง
    required this.labelText, // บังคับส่ง
    this.keyboardType, // ไม่บังคับส่ง
    this.inputFormatters, // ไม่บังคับส่ง
    this.obscureText = false, // ค่าเริ่มต้นไม่ซ่อนข้อความ
    this.hintText, // ไม่บังคับส่ง
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 360 ? 14.0 : 16.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        width: screenWidth, // กำหนดความกว้างของ TextField เท่ากับหน้าจอ
        child: TextField(
          controller: controller,
          obscureText: obscureText, // ใช้สำหรับซ่อนข้อความ
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(
              fontSize: fontSize, // ขนาดของ Label
            ),
            hintText: hintText, // เพิ่มข้อความแนะนำ
            hintStyle: TextStyle(
              fontSize: fontSize, // ขนาดของ Hint
              color: Colors.grey, // สีของ Hint
            ),
            border: const OutlineInputBorder(),
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(
            fontSize: fontSize, // ขนาดข้อความใน TextField
          ),
        ),
      ),
    );
  }
}
