import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:wtqrscan/api/checkInternet.dart';
import 'package:wtqrscan/api/get_Data.dart';
import 'package:wtqrscan/class/FindLocationNotQR.dart';
import 'package:wtqrscan/class/alert.dart';
import 'package:wtqrscan/class/share.dart';
import 'package:wtqrscan/screens/form_productdetail.dart';

import '../api/auth_service.dart';
import '../class/CustomButton.dart';
import '../class/CustomGradientAppBar.dart';
import '../class/GradientHeader.dart';
import '../class/checkAppVersion.dart';

//class CheckStock extends StatelessWidget {
//  const checkStock({super.key});

class CheckStock extends StatefulWidget {
  const CheckStock({super.key});

  @override
  _CheckStockState createState() => _CheckStockState();
}

class _CheckStockState extends State<CheckStock> {
  final AuthService authService =
      AuthService(); // อินสแตนซ์ของ AuthService สำหรับการจัดการผู้ใช้
  String? locationQRCodeData; // ตัวแปรเก็บข้อมูล QR Code ของ Location
  String barcodeResult =
      "Result will show here !"; // ตัวแปรแสดงผลลัพธ์ของ QR Code

  final checkInternet = CheckInternet();

  // ฟังก์ชันสำหรับการสแกน QR Code ของ Location
  Future<void> onLocationScan() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInternetAndVersion(context);
    });
  }

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
        String resultData;
        try {
          resultData = await FlutterBarcodeScanner.scanBarcode("#ff6666",
              "Cancel", true, ScanMode.QR); // เปิดกล้องเพื่อสแกน QR Code
          setState(() {
            locationQRCodeData = resultData;
            Share.LocationSTOCK = resultData;
          });

          final data =
              await fetchMultipleApis(); // เรียกใช้ API เพื่อนำข้อมูล Location
          if (data != null) {
            setState(() {
              final data1 = data['data1'];
              if (data1 != null && data1['data'] != null) {
                Share.LocationSTOCK_ID = data1['data']['location_id'] ?? 0;
                Share.LocationSTOCK_Name =
                    data1['data']['location_description'] ?? 'N/A';
                Share.LocationSTOCK_Keep = data1['data']['remark'] ?? 'N/A';
              } else {
                // ตั้งค่าหากไม่พบข้อมูลที่ต้องการ
                Share.LocationSTOCK = '';
                Share.LocationSTOCK_ID = 0;
                Share.LocationSTOCK_Name = 'N/A';
                Share.LocationSTOCK_Keep = 'N/A';
                if (resultData != '-1') {
                  alert(context,
                      title: 'Massage Box',
                      content: 'QR Code นี้ไม่ใช่ QR Code Location',
                      showCancel: false); // แสดงการแจ้งเตือนถ้า QR ไม่ถูกต้อง
                }
              }
            });
          }
        } on PlatformException {
          setState(() {
            locationQRCodeData =
                "Location Data"; // กำหนดค่าเริ่มต้นเมื่อเกิดข้อผิดพลาด
          });
        }
      }
    });
  }

  // ฟังก์ชันสแกน QR Code และเปิดหน้า ProductDetail
  Future<void> QRScan() async {
    String resultData;
    try {
      resultData = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
      setState(() {
        barcodeResult = resultData;
        Share.URL = resultData;
        Share.CodeMove = '30';
      });

      if (resultData != '-1') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkInternetAndVersionLink(context);
        });
      }
    } on PlatformException {
      setState(() {
        barcodeResult = "Failed to scan!"; // แสดงข้อความเมื่อสแกนไม่สำเร็จ
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

  // วิดเจ็ตสำหรับแสดงข้อมูล Location และการเปลี่ยนสีตามเงื่อนไข
  Widget location(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 360 ? 14.0 : 16.0;

    return Container(
      margin: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width, // กำหนดความกว้างเท่ากับหน้าจอ
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: (Share.LocationSTOCK?.isEmpty ?? true)
            ? Colors.red[100]
            : Colors.green[100], // เปลี่ยนสีตามสถานะของ LocationSTOCK
        border: Border.all(
          color: (Share.LocationSTOCK?.isEmpty ?? true)
              ? Colors.red
              : Colors.green,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        (Share.LocationSTOCK?.isEmpty ?? true)
            ? 'Please Scan Location'
            : "Location : ${Share.LocationSTOCK_Name} Remark : ${Share.LocationSTOCK_Keep}",
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: (Share.LocationSTOCK?.isEmpty ?? true)
              ? Colors.red
              : Colors.green,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ปุ่ม LocationScan
  Widget btnLocationScan() => CustomButton(
        icon: Icons.qr_code,
        text: "QR Scan (Location)",
        onPressed: onLocationScan,
      );

  // ปุ่ม QR Scan ที่มีกรอบ header และ styling
  Widget btnQRScan() => Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueGrey, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header พร้อมความโค้งที่สามารถกำหนดค่าได้
            GradientHeader(
              text: 'Scan QR Code',
              color1: Colors.orange.shade300,
              color2: Colors.orange.shade600,
              borderRadius: 7.0,
              icon: Icons.qr_code_scanner,
            ),

            const SizedBox(height: 10),
            CustomButton(
              icon: Icons.qr_code,
              text: "QR Scan (Check Stock)",
              onPressed: QRScan,
            ),
          ],
        ),
      );

  // วิดเจ็ต LocationInfo ที่แสดงข้อมูลโลโก้และปุ่ม
  Widget LocationInfo(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize144 = screenWidth < 360 ? 124.0 : 144.0;

    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header พร้อมความโค้งที่สามารถกำหนดค่าได้
          GradientHeader(
            text: 'Location Information',
            color1: Colors.orange.shade300,
            color2: Colors.orange.shade600,
            borderRadius: 7.0,
            icon: Icons.location_on,
          ),

          Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Image.asset(
                    'assets/images/LOGO-WTG.png',
                    width: imageSize144,
                    height: imageSize144,
                  ),
                ),
                const SizedBox(height: 10),
                location(context), // วิดเจ็ตแสดงข้อมูล Location
                const SizedBox(height: 0),
                btnLocationScan(), // ปุ่มสแกน Location
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันสำหรับเรียก API หลายตัวและนำข้อมูลที่ได้ไปใช้
  Future<Map<String, dynamic>?> fetchMultipleApis() async {
    final GetAllData _getAllData = GetAllData();
    String url = Share.LocationSTOCK;
    Uri uri = Uri.parse(url);

    Future<Map<String, dynamic>?> apiCall1 = _getAllData.getLocation(
      uri.queryParameters['location_id'] ?? 'Unknown',
    );

    return await Future.wait([apiCall1]).then((responses) {
      final data1 = responses[0];
      return {
        'data1': data1,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomGradientAppBar(
        titleText: "WT QR Scan :: STOCK",
        color1: Colors.orange.shade300,
        color2: Colors.orange.shade600,
        leadingIcon: Icons.qr_code_2,
        ActionIcon: Icons.exit_to_app, // เพิ่ม ActionIcon
        showActionButton: true,
        onActionPressed: () => alert(
          context,
          title: 'Message Box',
          content: 'ออกจากระบบ?',
          okAction: () async {
            await authService.logout(context);
          },
          showCancel: true,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              LocationInfo(context), // กรอบที่รวม Location Information
              const SizedBox(height: 0),
              if (Share.LocationSTOCK != null &&
                  Share.LocationSTOCK!.isNotEmpty) ...[
                btnQRScan(), // แสดงปุ่ม QR Scan
                FindLocationNotQR(
                  codemove: '30',
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
