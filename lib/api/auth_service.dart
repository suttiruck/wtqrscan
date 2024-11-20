import 'dart:convert';
// สำหรับ json.decode
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:wtqrscan/class/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wtqrscan/screens/form_login.dart';

class AuthService {
  final _storage =
      const FlutterSecureStorage(); // สร้างตัวแปร _storage สำหรับจัดเก็บข้อมูลอย่างปลอดภัย

  // เก็บ Cookie หลังจากล็อกอินสำเร็จ
  Future<void> saveCookie(String cookie) async {
    await _storage.write(key: 'userCookie', value: cookie);
  }

  // ดึง Cookie
  Future<String?> getCookie() async {
    return await _storage.read(key: 'userCookie');
  }

  // ลบ Cookie เมื่อออกจากระบบ
  Future<void> deleteCookie() async {
    await _storage.delete(key: 'userCookie');
  }

  // ฟังก์ชันเข้าสู่ระบบ
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('http://api.wtg.co.th/QRScan/CheckUser.aspx'),
      headers: {
        'Content-Type': 'application/json', // ตั้งค่า headers เป็น JSON
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // แปลง JSON body เป็น Map
      final responseBody = jsonDecode(response.body);

      try {
        // แปลง JSON string เป็น Map
        Map<String, dynamic> jsonMap = json.decode(response.body);

        // เข้าถึงค่า username
        String Uname = jsonMap['data']['UserName'];
        String name = jsonMap['data']['Name'];
        //print('Username: $username');
        Share.Uname = Uname;
        Share.Name = name;

        // เมื่อผู้ใช้ล็อกอินสำเร็จ
        await saveLoginData(Uname, name);
        //await saveLoginData('your_username', 'your_password');
      } catch (e) {
        //print('Error decoding JSON: $e');
      }
      final status = responseBody['status'];
      if (status != null) {
        await saveCookie(status);
        return true; // ล็อกอินสำเร็จ
      }
    }
    return false; // ล็อกอินไม่สำเร็จ
  }

  // ฟังก์ชันตรวจสอบสถานะการเข้าสู่ระบบ
  Future<bool> checkAuthStatus() async {
    String? cookie = await getCookie();
    //await deleteCookie();
    if (cookie != null) {
      // สร้าง HTTP POST request พร้อม Cookie
      final response = await http.post(
        Uri.parse('http://api.wtg.co.th/QRScan/CheckUser.aspx'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': cookie, // ส่ง cookie ไปกับ headers
        },
        body: jsonEncode({
          // ส่งข้อมูลเพิ่มเติมใน body หาก API ต้องการ เช่น userID หรือ sessionID
          "additionalData": "value"
        }),
      );

      if (response.statusCode == 200) {
        // แปลง JSON response เป็น Map
        final responseBody = jsonDecode(response.body);

        // ตรวจสอบสถานะ 'status' ใน response body
        if (responseBody['status'] == 'success') {
          return true; // ผู้ใช้เข้าสู่ระบบแล้ว
        }
      }
    }
    return false; // ผู้ใช้ยังไม่ได้เข้าสู่ระบบ
  }

  // ฟังก์ชันออกจากระบบ
  // Future<void> logout() async {
  Future<void> logout(BuildContext context) async {
    await deleteCookie();
    // ทำอย่างอื่นเพิ่มเติมถ้าจำเป็น เช่น เรียก API สำหรับ logout
    // เมื่อคุณต้องการลบข้อมูลการล็อกอิน
    await clearLoginData();

    // นำผู้ใช้ไปยังหน้า LoginScreen และเคลียร์สแตกทั้งหมดเพื่อไม่ให้ถอยกลับได้
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false, // เคลียร์สแตกทั้งหมด
    );
    //SystemNavigator.pop(); //Exit Apps
  }

  // ฟังก์ชันสำหรับเก็บข้อมูลการล็อกอิน
  // Future<void> saveLoginData(String username, String password) async {
  Future<void> saveLoginData(String username, String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('name', name);
    //await prefs.setString('password', password); // เก็บรหัสผ่าน (แนะนำให้เก็บ token แทน)
  }

// ฟังก์ชันสำหรับดึงข้อมูลการล็อกอิน
  Future<Map<String, String?>> getLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? name = prefs.getString('name');
    //String? password = prefs.getString('password'); // ดึงรหัสผ่าน (แนะนำให้เก็บ token แทน)
    //return {'username': username, 'password': password};
    return {'username': username, 'name': name};
  }

// ฟังก์ชันสำหรับลบข้อมูลการล็อกอิน
  Future<void> clearLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('name');
    //await prefs.remove('password');
  }

  // เมื่อคุณต้องการดึงข้อมูลการล็อกอิน
//Map<String, String?> loginData = await getLoginData();
//print('Username: ${loginData['username']}');
//print('Password: ${loginData['password']}'); // ควรระมัดระวังการแสดงรหัสผ่าน
}
