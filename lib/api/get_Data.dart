import 'dart:convert';
// สำหรับ json.decode
//import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
//import 'package:wtqrscan/class/share.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:wtqrscan/screens/form_login.dart';

class GetAllData {
  String APIURL = 'http://api.wtg.co.th/QRScan/';
  // ฟังก์ชัน prodinfo ที่คืนค่า JSON
  Future<Map<String, dynamic>?> prodinfo(String type, String projectno,
      String proorder, String matno, String proddate) async {
    final response = await http.post(
      Uri.parse(APIURL + 'getProdData.aspx'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': type,
        'projectno': projectno,
        'proorder': proorder,
        'matno': matno,
        'proddate': proddate,
      }),
    );

    if (response.statusCode == 200) {
      try {
        // แปลง JSON body เป็น Map
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

        // เช็คว่ามีข้อมูลที่ต้องการใน response หรือไม่
        final status = responseBody['status'];
        if (status != null) {
          return responseBody; // คืนค่า JSON ที่ได้จาก API
        }
      } catch (e) {
        // จัดการข้อผิดพลาดในกรณีที่ไม่สามารถแปลง JSON ได้
        // print('Error decoding JSON: $e');
      }
    }
    return null; // คืนค่า null หากการเรียก API ไม่สำเร็จหรือตอบกลับผิดพลาด
  }

  // ฟังก์ชัน getLocationData ที่คืนค่า JSON
  Future<Map<String, dynamic>?> getLocation(String locationid) async {
    final response = await http.post(
      Uri.parse(APIURL + 'getLocationData.aspx'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'locationid': locationid,
      }),
    );

    if (response.statusCode == 200) {
      try {
        // แปลง JSON body เป็น Map
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

        // เช็คว่ามีข้อมูลที่ต้องการใน response หรือไม่
        final status = responseBody['status'];
        if (status != null) {
          return responseBody; // คืนค่า JSON ที่ได้จาก API
        }
      } catch (e) {
        // จัดการข้อผิดพลาดในกรณีที่ไม่สามารถแปลง JSON ได้
        // print('Error decoding JSON: $e');
      }
    }
    return null; // คืนค่า null หากการเรียก API ไม่สำเร็จหรือตอบกลับผิดพลาด
  }

  // ฟังก์ชัน prodinfo ที่คืนค่า JSON
  Future<Map<String, dynamic>?> prodinfoNotQR(String type, String projectno,
      String proorder, String matno, String length) async {
    final response = await http.post(
      Uri.parse(APIURL + 'getProdDataNotQR.aspx'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': type,
        'projectno': projectno,
        'proorder': proorder,
        'matno': matno,
        'length': length,
      }),
    );

    if (response.statusCode == 200) {
      try {
        // แปลง JSON body เป็น Map
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

        // เช็คว่ามีข้อมูลที่ต้องการใน response หรือไม่
        final status = responseBody['status'];
        if (status != null) {
          return responseBody; // คืนค่า JSON ที่ได้จาก API
        }
      } catch (e) {
        // จัดการข้อผิดพลาดในกรณีที่ไม่สามารถแปลง JSON ได้
        // print('Error decoding JSON: $e');
      }
    }
    return null; // คืนค่า null หากการเรียก API ไม่สำเร็จหรือตอบกลับผิดพลาด
  }

  // ฟังก์ชัน prodinfo ที่คืนค่า JSON
  Future<Map<String, dynamic>?> getProductAllLocation(
      String type, String projectno, String proorder, String matno) async {
    final response = await http.post(
      Uri.parse(APIURL + 'getProductAllLocation.aspx'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': type,
        'projectno': projectno,
        'proorder': proorder,
        'matno': matno,
      }),
    );

    if (response.statusCode == 200) {
      try {
        // แปลง JSON body เป็น Map
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

        // เช็คว่ามีข้อมูลที่ต้องการใน response หรือไม่
        final status = responseBody['status'];
        if (status != null) {
          return responseBody; // คืนค่า JSON ที่ได้จาก API
        }
      } catch (e) {
        // จัดการข้อผิดพลาดในกรณีที่ไม่สามารถแปลง JSON ได้
        // print('Error decoding JSON: $e');
      }
    }
    return null; // คืนค่า null หากการเรียก API ไม่สำเร็จหรือตอบกลับผิดพลาด
  }

  // ฟังก์ชัน getHistory ที่คืนค่า JSON
  Future<Map<String, dynamic>?> getHistory(String type, String projectno,
      String proorder, String matno, String proddate) async {
    final response = await http.post(
      Uri.parse(APIURL + 'getHistoryScan.aspx'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': type,
        'projectno': projectno,
        'proorder': proorder,
        'matno': matno,
        'proddate': proddate,
      }),
    );

    if (response.statusCode == 200) {
      try {
        // แปลง JSON body เป็น Map
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

        // เช็คว่ามีข้อมูลที่ต้องการใน response หรือไม่
        final status = responseBody['status'];
        if (status != null) {
          return responseBody; // คืนค่า JSON ที่ได้จาก API
        }
      } catch (e) {
        // จัดการข้อผิดพลาดในกรณีที่ไม่สามารถแปลง JSON ได้
        // print('Error decoding JSON: $e');
      }
    }
    return null; // คืนค่า null หากการเรียก API ไม่สำเร็จหรือตอบกลับผิดพลาด
  }

  // ฟังก์ชัน saveQRData ที่คืนค่า JSON
  Future<bool> saveQRData(
      String record_id,
      String type_qrcode,
      String project_no,
      String prod_order,
      String mat_no,
      String date_prod,
      int qty,
      int location_id,
      String create_uname,
      String remark) async {
    final response = await http.post(
      Uri.parse(APIURL + 'saveScanData.aspx'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'record_id': record_id,
        'type_qrcode': type_qrcode,
        'project_no': project_no,
        'prod_order': prod_order,
        'mat_no': mat_no,
        'date_prod': date_prod,
        'qty': qty,
        'location_id': location_id,
        'create_uname': create_uname,
        'remark': remark,
      }),
    );

    if (response.statusCode == 200) {
      try {
        // แปลง JSON body เป็น Map
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

        // เช็คว่ามีข้อมูลที่ต้องการใน response หรือไม่
        final status = responseBody['status'];
        if (status != null) {
          return true; // ล็อกอินสำเร็จ // คืนค่า JSON ที่ได้จาก API
        }
      } catch (e) {
        // จัดการข้อผิดพลาดในกรณีที่ไม่สามารถแปลง JSON ได้
        // print('Error decoding JSON: $e');
      }
    }
    return false; // ล็อกอินไม่สำเร็จ // คืนค่า null หากการเรียก API ไม่สำเร็จหรือตอบกลับผิดพลาด
  }

  // ฟังก์ชัน checkVersion ที่คืนค่า JSON
  Future<bool> checkVersion(String version_number, String user_admin) async {
    final response = await http.post(
      Uri.parse(APIURL + 'checkVersion.aspx'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'version_number': version_number,
        'user_admin': user_admin,
      }),
    );

    if (response.statusCode == 200) {
      try {
        // แปลง JSON body เป็น Map
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

        // เช็คว่ามีข้อมูลที่ต้องการใน response หรือไม่
        final status = responseBody['status'];
        if (status != null) {
          return true; // ล็อกอินสำเร็จ // คืนค่า JSON ที่ได้จาก API
        }
      } catch (e) {
        // จัดการข้อผิดพลาดในกรณีที่ไม่สามารถแปลง JSON ได้
        // print('Error decoding JSON: $e');
      }
    }
    return false; // ล็อกอินไม่สำเร็จ // คืนค่า null หากการเรียก API ไม่สำเร็จหรือตอบกลับผิดพลาด
  }
}
