import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:wtqrscan/api/checkInternet.dart';
import 'package:wtqrscan/class/FindLocationNotQR.dart';
import 'package:wtqrscan/class/alert.dart';
import 'package:wtqrscan/class/share.dart';
import 'package:wtqrscan/screens/form_productdetail.dart';
import '../api/auth_service.dart';
import '../class/GradientHeader.dart';

class MainScreen_copy extends StatefulWidget {
  const MainScreen_copy({super.key});

  @override
  _MainScreen_copyState createState() => _MainScreen_copyState();
}

class _MainScreen_copyState extends State<MainScreen_copy> {
  final AuthService _authService = AuthService();
  String barcodeResult = "Result will show here !";

  final checkInternet = CheckInternet();

  Future<void> QRScan() async {
    String resultData;
    try {
      resultData = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
      print("Result scan: $resultData");

      setState(() {
        barcodeResult = resultData;
        Share.URL = resultData;
        Share.CodeMove = '00';
      });

      if (resultData != '-1') {
        checkInternet.checkInternetAndProceed_WithTry(context, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ProductDetail(); // ไปยังหน้า ProductDetail เมื่อเชื่อมต่ออินเทอร์เน็ตได้
          }));
        });
      }
    } on PlatformException {
      setState(() {
        barcodeResult = "Failed to scan!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ใช้ Gradient เพื่อให้มีสีไล่ระดับ
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade400,
                Colors.blue.shade700,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4, // เพิ่มเงาให้ AppBar
        title: Row(
          children: [
            const Icon(Icons.qr_code_2, size: 28, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              "WT QR Scan :: HOME",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () => alert(
              context,
              title: 'Massage Box',
              content: 'ออกจากระบบ?',
              okAction: () async {
                await _authService.logout(context);
              },
              showCancel: true,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 0),

              // Container สำหรับปุ่มสแกน QR Code
              Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueGrey, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Header พร้อมความโค้งที่สามารถกำหนดค่าได้
                    GradientHeader(
                      text: 'Scan QR Code',
                      color1: Colors.blue.shade300,
                      color2: Colors.blue.shade600,
                      borderRadius: 7.0,
                      icon: Icons.qr_code_scanner,
                    ),

                    const SizedBox(height: 10),
                    // โลโก้
                    Image.asset(
                      'assets/images/LOGO-WTG.png',
                      width: 144,
                      height: 144,
                    ),
                    const SizedBox(height: 10),
                    // ปุ่ม QR Scan (Check Production Detail)
                    Container(
                      margin: const EdgeInsets.all(10), // เพิ่ม margin รอบปุ่ม
                      child: ElevatedButton(
                        onPressed: QRScan,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 20), // padding ภายในปุ่ม
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          minimumSize: const Size.fromHeight(60),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.qr_code, size: 24),
                            SizedBox(width: 8),
                            Text("QR Scan (Check Production Detail)"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 0),
              FindLocationNotQR(
                codemove: '00',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
