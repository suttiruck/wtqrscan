import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class CheckInternet {
  // ฟังก์ชันสำหรับตรวจสอบการเชื่อมต่ออินเทอร์เน็ตก่อนทำเหตุการณ์ใดๆ พร้อมปุ่ม Retry
  Future<void> checkInternetAndProceed_WithTry(
      BuildContext context, Function onConnected) async {
    bool isConnected = await InternetConnectionChecker().hasConnection;

    if (!isConnected) {
      print("No internet connection. Please connect to the internet.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              "No internet connection. Please connect to the internet."),
          duration: const Duration(days: 1),
          action: SnackBarAction(
            label: 'Retry', // ปุ่ม Retry สำหรับตรวจสอบใหม่
            onPressed: () {
              checkInternetAndProceed_WithTry(
                  context, onConnected); // เรียกฟังก์ชันใหม่เมื่อกด Retry
            },
          ),
        ),
      );
    } else {
      print("Internet is connected.");
      onConnected(); // เรียกฟังก์ชันที่ส่งเข้ามาเมื่อมีการเชื่อมต่ออินเทอร์เน็ต
    }
  }

  // ฟังก์ชันตรวจสอบการเชื่อมต่ออินเทอร์เน็ตและดำเนินการต่อหากเชื่อมต่อได้
  Future<void> checkInternetAndProceed_NotTry(
      BuildContext context, Function onConnected) async {
    bool isConnected = await InternetConnectionChecker().hasConnection;

    if (!isConnected) {
      // ไม่มีการเชื่อมต่ออินเทอร์เน็ต แสดง SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              "No internet connection. Please connect to the internet."),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      // มีการเชื่อมต่ออินเทอร์เน็ต เรียกฟังก์ชันที่ส่งเข้ามา
      onConnected();
    }
  }
}
