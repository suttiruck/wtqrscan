import 'package:intl/intl.dart';

class Formatdate {
  // ฟังก์ชันเพื่อแปลงวันที่ในรูปแบบ /Date(timestamp)/
  static String formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return '-'; // คืนค่า "-" ถ้าค่าเป็น null หรือว่าง
    }

    try {
      // ใช้ Regular Expression เพื่อดึงค่า timestamp จากสตริง
      final RegExp regex = RegExp(r"\/Date\((\d+)\)\/");
      final match = regex.firstMatch(date);

      if (match != null) {
        // ดึงค่า timestamp แล้วแปลงเป็นตัวเลข
        final int timestamp = int.parse(match.group(1)!);

        // แปลง timestamp จาก milliseconds เป็น DateTime
        DateTime parsedDate = DateTime.fromMillisecondsSinceEpoch(timestamp);

        // แปลง DateTime เป็นรูปแบบวันที่ที่ต้องการ เช่น "dd/MM/yyyy"
        return DateFormat('dd/MM/yyyy').format(parsedDate);
      } else {
        return '-'; // คืนค่า "-" ถ้าหากไม่สามารถแปลง
      }
    } catch (e) {
      return '-'; // คืนค่า "-" ถ้าเกิดข้อผิดพลาดในการแปลง
    }
  }

  static String formatDateTime(String? date) {
    if (date == null || date.isEmpty) {
      return '-'; // คืนค่า "-" ถ้าค่าเป็น null หรือว่าง
    }

    try {
      // ใช้ Regular Expression เพื่อดึงค่า timestamp จากสตริง
      final RegExp regex = RegExp(r"\/Date\((\d+)\)\/");
      final match = regex.firstMatch(date);

      if (match != null) {
        // ดึงค่า timestamp แล้วแปลงเป็นตัวเลข
        final int timestamp = int.parse(match.group(1)!);

        // แปลง timestamp จาก milliseconds เป็น DateTime
        DateTime parsedDate = DateTime.fromMillisecondsSinceEpoch(timestamp);

        // แปลง DateTime เป็นรูปแบบวันที่ที่ต้องการ เช่น "dd/MM/yyyy"
        return DateFormat('dd/MM/yyyy HH:mm:ss').format(parsedDate);
      } else {
        return '-'; // คืนค่า "-" ถ้าหากไม่สามารถแปลง
      }
    } catch (e) {
      return '-'; // คืนค่า "-" ถ้าเกิดข้อผิดพลาดในการแปลง
    }
  }
}
