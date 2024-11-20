import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:wtqrscan/api/checkInternet.dart';
import 'package:wtqrscan/class/FindLocationNotQR.dart';
import 'package:wtqrscan/class/alert.dart';
import 'package:wtqrscan/class/share.dart';
import 'package:wtqrscan/screens/form_productdetail.dart';
import '../api/auth_service.dart';
import '../class/CustomButton.dart';
import '../class/CustomGradientAppBar.dart';
import '../class/GradientHeader.dart';
import '../class/checkAppVersion.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkInternetAndVersionLink(context);
        });
      }
    } on PlatformException {
      setState(() {
        barcodeResult = "Failed to scan!";
      });
    }
  }

  Future<void> _checkInternetAndVersionLink(BuildContext context) async {
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
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ProductDetail(); // ไปยังหน้า ProductDetail เมื่อเชื่อมต่ออินเทอร์เน็ตได้
        }));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize144 = screenWidth < 360 ? 124.0 : 144.0;

    return Scaffold(
      appBar: CustomGradientAppBar(
        titleText: "WT QR Scan :: HOME",
        color1: Colors.blue.shade400,
        color2: Colors.blue.shade700,
        leadingIcon: Icons.qr_code_2,
        ActionIcon: Icons.exit_to_app, // เพิ่ม ActionIcon
        showActionButton: true,
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
      // ส่วนอื่นๆ ของ Scaffold
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
                      width: imageSize144,
                      height: imageSize144,
                    ),
                    const SizedBox(height: 10),
                    // ปุ่ม QR Scan (Check Production Detail)
                    CustomButton(
                      icon: Icons.qr_code,
                      text: "QR Scan (Check Production Detail)",
                      onPressed: QRScan,
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
