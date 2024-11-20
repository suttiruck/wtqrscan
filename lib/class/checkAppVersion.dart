import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wtqrscan/class/alert.dart';
import 'package:wtqrscan/api/get_Data.dart';
import 'package:wtqrscan/class/share.dart';

import '../api/auth_service.dart';

class checkAppVersion {
  final BuildContext context;
  final GetAllData getAllData = GetAllData();
  final AuthService authService = AuthService();

  checkAppVersion(this.context);

  Future<bool> checkVersion(
      {required Function(String version) onVersionLoaded}) async {
    // ดึงข้อมูลเวอร์ชันจาก PackageInfo
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Map<String, String?> loginData = await authService.getLoginData();
    String appVersion =
        "Version: ${packageInfo.version}, Build: ${packageInfo.buildNumber}";

    // เรียกฟังก์ชัน callback เพื่ออัปเดตเวอร์ชันใน state
    onVersionLoaded(appVersion);

    // ตรวจสอบเวอร์ชัน
    bool isVersion = await getAllData.checkVersion(
        packageInfo.version, loginData['username'] ?? '');

    if (!isVersion) {
      // ถ้า isVersion เป็น false ให้แสดง Alert และออกจากแอป
      _showVersionAlert(packageInfo.version);
      return false; // เวอร์ชันไม่ถูกต้อง
    }

    return true; // เวอร์ชันถูกต้อง
  }

  void _showVersionAlert(String version_number) {
    alert(
      context,
      title: 'Version Alert',
      content:
          'กรุณาอัปเดตแอปพลิเคชั่นเป็นเวอร์ชั่นล่าสุดจาก Link ติดตั้งโปรแกรมที่ได้รับอีกครั้ง หรือติดต่อธุรการฝ่ายโรงงาน, ฝ่ายไอที',
      showCancel: false,
      okAction: () {
        Navigator.of(context).pop(); // ปิด AlertDialog
        Future.delayed(Duration(milliseconds: 100), () {
          exit(0); // ปิดแอปหลังปิด AlertDialog
        });
      },
    );
  }
}
//'เวอร์ชั่นปัจจุบันของคุณคือ ${version_number} จำเป็นต้องอัพเดตเวอร์ชั่นก่อนการใช้งาน กรุณาอัปเดตแอปพลิเคชั่นเป็นเวอร์ชั่นล่าสุดจาก Link ติดตั้งโปรแกรมเดิม หรือติดต่อธุรการฝ่ายโรงงาน, ฝ่ายไอที',