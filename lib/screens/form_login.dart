import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wtqrscan/api/auth_service.dart';
import 'package:wtqrscan/class/alert.dart';

import '../api/checkInternet.dart';
import '../class/CustomGradientAppBar.dart';
import '../class/CustomGradientButton.dart';
import '../class/CustomTextField.dart';
import '../class/GradientHeader.dart';
import '../class/checkAppVersion.dart';
import '../main.dart';

// คลาส LoginScreen ที่เป็นหน้าจอสำหรับเข้าสู่ระบบ
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // คอนโทรลเลอร์สำหรับรับค่าจาก TextField
  final _ctrlUser = TextEditingController();
  final _ctrlPswd = TextEditingController();
  final AuthService _authService = AuthService(); // อินสแตนซ์ของ AuthService
  final checkInternet = CheckInternet();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize144 = screenWidth < 360 ? 124.0 : 144.0;

    return Scaffold(
      appBar: CustomGradientAppBar(
        titleText: "WT QR Scan :: Login",
        color1: Colors.blue.shade400,
        color2: Colors.blue.shade700,
        leadingIcon: Icons.qr_code_2,
        ActionIcon: Icons.exit_to_app, // เพิ่ม ActionIcon
        showActionButton: false,
        onActionPressed: () => alert(
          context,
          title: 'Message Box',
          content: 'ออกจากระบบ?',
          okAction: () async {
            await _authService.logout(context);
          },
          showCancel: true,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(10), // margin รอบนอกทั้งหมดของฟอร์ม
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey), // กรอบรอบทั้งหมดของฟอร์ม
              borderRadius: BorderRadius.circular(8), // มุมโค้งของกรอบฟอร์ม
            ),
            child: Column(
              children: [
                // Header ติดขอบบนและกว้างเท่ากับกรอบ
                GradientHeader(
                  text: 'Login',
                  color1: Colors.blue.shade300,
                  color2: Colors.blue.shade600,
                  borderRadius: 7.0,
                  icon: Icons.login,
                ),

                // เนื้อหาภายใน Container หลักที่จัดระยะห่างด้านใน
                Padding(
                  padding: const EdgeInsets.all(
                      10), // padding รอบทั้งหมดของเนื้อหาฟอร์ม
                  child: Column(
                    children: [
                      const SizedBox(height: 5), // ระยะห่างบน
                      Image.asset('assets/images/LOGO-WTG.png',
                          width: imageSize144,
                          height: imageSize144), // โลโก้ของแอป
                      const SizedBox(
                          height: 10), // ระยะห่างระหว่างโลโก้กับฟิลด์
                      textFieldUsername(), // เรียกใช้งาน TextField สำหรับ Username
                      const SizedBox(height: 10),
                      textFieldPassword(), // เรียกใช้งาน TextField สำหรับ Password
                      const SizedBox(height: 0), // ระยะห่างระหว่างฟิลด์และปุ่ม
                      btnLogin(), // ปุ่ม Login
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // TextField สำหรับ Username
  Widget textFieldUsername() => CustomTextField(
        controller: _ctrlUser,
        labelText: "Username",
        hintText: "Enter your username",
      );

  // TextField สำหรับ Password
  Widget textFieldPassword() => CustomTextField(
        controller: _ctrlPswd,
        labelText: "Password",
        hintText: "Enter your password",
        obscureText: true, // ซ่อนข้อความ (Password)
      );

  // ปุ่ม Login ที่มีการตกแต่งให้สวยงาม
  Widget btnLogin() => CustomGradientButton(
        text: "LOGIN",
        icon: Icons.lock,
        onPressed: () async {
          // ฟังก์ชันที่ทำงานเมื่อกดปุ่ม Login
          bool success =
              await _authService.login(_ctrlUser.text, _ctrlPswd.text);
          if (success) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _checkInternetAndVersion(context);
            });
          } else {
            // ถ้า login ไม่สำเร็จ จะแสดงข้อความแจ้งเตือน
            alert(context,
                title: 'Massage Box',
                content: 'ชื่อหรือรหัสผ่านไม่ถูกต้อง',
                showCancel: false);
          }
        },
        gradientColors: [Colors.blue.shade400, Colors.blue.shade600],
      );

  Future<void> _checkInternetAndVersion(BuildContext context) async {
    // ตรวจสอบการเชื่อมต่ออินเทอร์เน็ต
    await checkInternet.checkInternetAndProceed_WithTry(context, () async {
      // สร้างอินสแตนซ์ของ AppVersionChecker
      checkAppVersion versionChecker = checkAppVersion(context);

      // เรียกใช้การตรวจสอบเวอร์ชัน
      bool isVersionValid = await versionChecker.checkVersion(
        onVersionLoaded: (version) {
          // อัปเดตเวอร์ชันใน state
          //setState(() {
          //  this.version = version;
          //});
        },
      );

      if (isVersionValid) {
        // ถ้า login สำเร็จ จะนำไปหน้าหลัก
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      }
    });
  }
}
