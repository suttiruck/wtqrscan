import 'package:flutter/material.dart';

// สร้างคลาสใหม่สำหรับ LocationInfo
class FindLocationNotQR_bk extends StatelessWidget {
  final String locationName;
  final String locationRemark;
  final Color borderColor;
  final Color backgroundColor;

  FindLocationNotQR_bk({
    required this.locationName,
    required this.locationRemark,
    this.borderColor = Colors.blue,
    this.backgroundColor = Colors.blueAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "Location: $locationName\nRemark: $locationRemark",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
