import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:wtqrscan/api/checkInternet.dart';
import 'package:wtqrscan/api/get_Data.dart';
import 'package:wtqrscan/class/CustomButton.dart';
import 'package:wtqrscan/class/CustomTextField.dart';
import 'package:wtqrscan/class/DateFormat.dart';
import 'package:wtqrscan/class/GradientHeader.dart';
import 'package:wtqrscan/class/checkAppVersion.dart';
import 'package:wtqrscan/class/share.dart';
import 'package:wtqrscan/screens/form_productdetail.dart';

class FindLocationNotQR extends StatefulWidget {
  final String codemove;

  FindLocationNotQR({required this.codemove});

  @override
  _FindLocationNotQRState createState() => _FindLocationNotQRState();
}

class _FindLocationNotQRState extends State<FindLocationNotQR> {
  // สร้างตัวควบคุม TextField สำหรับ Project Number, Production Order, และ Material Number
  final TextEditingController projectNumberController = TextEditingController();
  final TextEditingController productionOrderController =
      TextEditingController();
  final TextEditingController materialNumberController =
      TextEditingController();
  final TextEditingController lengthController = TextEditingController();

  final checkInternet = CheckInternet();

  // ตัวแปรสำหรับเก็บข้อมูลที่ได้จาก API
  Future<Map<String, dynamic>?>? productData;

  // ฟังก์ชันสำหรับเรียกข้อมูลจาก API หลายแหล่ง
  Future<Map<String, dynamic>?> fetchMultipleApis({
    required String projectNo,
    required String prodOrder,
    required String matNo,
    required String length,
    String typeQrCode = 'Unknown',
  }) async {
    final GetAllData _getAllData = GetAllData();

    // เรียกข้อมูลจาก API
    Future<Map<String, dynamic>?> apiCall1 = _getAllData.prodinfoNotQR(
      typeQrCode,
      projectNo,
      prodOrder,
      matNo,
      length,
    );

    // รวบรวมข้อมูลจาก API หลายตัวแล้วส่งกลับเป็นแผนที่ข้อมูล
    return await Future.wait([apiCall1]).then((responses) {
      final data1 = responses[0];
      return {'data1': data1};
    });
  }

  @override
  void initState() {
    super.initState();
    // ยกเลิกการโฟกัสของ TextField เมื่อเปิดหน้าจอครั้งแรก
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void dispose() {
    // ล้างหน่วยความจำของตัวควบคุม TextField
    projectNumberController.dispose();
    productionOrderController.dispose();
    materialNumberController.dispose();
    lengthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ยกเลิกการโฟกัสของ TextField เมื่อแตะบริเวณนอก TextField
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
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
              text: 'Search Data',
              color1: widget.codemove == "10"
                  ? Colors.yellow.shade300
                  : widget.codemove == "20"
                      ? Colors.green.shade300
                      : widget.codemove == "30"
                          ? Colors.orange.shade300
                          : Colors.blue.shade300,
              color2: widget.codemove == "10"
                  ? Colors.yellow.shade600
                  : widget.codemove == "20"
                      ? Colors.green.shade600
                      : widget.codemove == "30"
                          ? Colors.orange.shade600
                          : Colors.blue.shade600,
              borderRadius: 7.0,
              icon: Icons.search,
            ),

            const SizedBox(height: 10),
            // ช่องกรอกข้อมูล Project Number
            CustomTextField(
              controller: projectNumberController,
              labelText: "Project Number",
              hintText: "Enter your Project Number",
            ),

            const SizedBox(height: 10),
            // ช่องกรอกข้อมูล Production Order ที่รับตัวเลขเท่านั้น
            CustomTextField(
              controller: productionOrderController,
              labelText: "Production Order",
              hintText: "Enter your Production Order",
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            const SizedBox(height: 10),
            // ช่องกรอกข้อมูล Material Number ที่รับตัวเลขเท่านั้น
            CustomTextField(
              controller: materialNumberController,
              labelText: "Material Number",
              hintText: "Enter your Material Number",
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 10),
            // ช่องกรอกข้อมูล Length Panel ที่รับตัวเลขเท่านั้น
            CustomTextField(
              controller: lengthController,
              labelText: "Length Panel",
              hintText: "Enter your Length Panel",
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d*')), // อนุญาตเฉพาะตัวเลขและจุดทศนิยม
              ],
            ),

            const SizedBox(height: 10),
            // ปุ่มค้นหาข้อมูล
            CustomButton(
              icon: Icons.search,
              text: "Search Data",
              onPressed: () {
                checkInternet.checkInternetAndProceed_WithTry(
                  context,
                  () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _checkInternetAndVersion(context);
                    });
                  },
                );
                // ตรวจสอบการเชื่อมต่ออินเทอร์เน็ตก่อนเรียก _checkLoginStatus
              },
            ),

            getProductInfo(context), // แสดงข้อมูลที่ได้จาก API
          ],
        ),
      ),
    );
  }

  // แสดงข้อมูลที่ได้จาก API ในรูปแบบ FutureBuilder
  Widget getProductInfo(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 360 ? 16.0 : 18.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: FutureBuilder<Map<String, dynamic>?>(
        future: productData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // แสดงตัวโหลดข้อมูลเมื่อกำลังรอข้อมูล
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // แสดงข้อความผิดพลาดเมื่อมีข้อผิดพลาด
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data;
            final data1 = data?['data1'];

            // แสดงข้อความเมื่อไม่มีข้อมูลที่จะแสดง
            if (data1 == null ||
                data1['data'] == null ||
                (data1['data'] as List).isEmpty) {
              return Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.87,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    'No data found',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
              );
            }

            final List<dynamic> dataList = data1['data'];

            // แสดงข้อมูลในรูปแบบ ListView
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(0),
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                final item = dataList[index];
                return Container(
                  decoration: BoxDecoration(
                    color: index.isEven ? Colors.blue[50] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: buildListTile(item),
                );
              },
              separatorBuilder: (context, index) => const Divider(
                color: Colors.blueGrey,
                thickness: 1,
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

// สร้าง ListTile เพื่อแสดงรายละเอียดข้อมูลแต่ละรายการ
  Widget buildListTile(Map<String, dynamic> item) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize14 = screenWidth < 360 ? 12.0 : 14.0;
    final fontSize15 = screenWidth < 360 ? 13.0 : 15.0;
    final fontSize16 = screenWidth < 360 ? 14.0 : 16.0;
    final fontSize18 = screenWidth < 360 ? 16.0 : 18.0;
    final iconSize36 = screenWidth < 360 ? 34.0 : 36.0;

    return ListTile(
      title: Text(
        "Production Order: ${item['prod_order'] ?? 'N/A'}",
        style: TextStyle(
          fontSize: fontSize16,
          fontWeight: FontWeight.w600,
          color: Colors.blueGrey[800],
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Project No: ${item['project_no'] ?? 'N/A'}",
            style: TextStyle(
              fontSize: fontSize14,
              color: Colors.blueGrey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Material No: ${item['mat_no'] ?? 'N/A'}",
            style: TextStyle(
              fontSize: fontSize14,
              color: Colors.blueGrey[600],
            ),
          ),
          Text(
            "Description: ${item['mat_des'] ?? 'N/A'}",
            style: TextStyle(
              fontSize: fontSize14,
              color: Colors.blueGrey[600],
            ),
          ),
          Text(
            "Length: ${item['panel_length'] ?? 'N/A'}",
            style: TextStyle(
              fontSize: fontSize14,
              color: Colors.blueGrey[600],
            ),
          ),
          Text(
            "Production Date: ${Formatdate.formatDate(item['date_prod'] ?? 'N/A')}",
            style: TextStyle(
              fontSize: fontSize14,
              color: Colors.blueGrey[600],
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.double_arrow,
          color: Colors.blueAccent,
          size: iconSize36, // กำหนดขนาดของไอคอน
        ),
        onPressed: () {
          // แปลง timestamp และนำไปแสดงผลในหน้าถัดไป
          String rawDate = item['date_prod'];
          int timestamp = int.parse(rawDate.replaceAll(RegExp(r'[^0-9]'), ''));
          DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
          String formattedDate = DateFormat('yyyy-MM-dd').format(date);

          // ตั้งค่า URL และ CodeMove สำหรับการนำไปใช้ในหน้าถัดไป
          Share.URL =
              "https://info.wtg.co.th/ProdManagementSystem/insert_form.aspx?type_qrcode=${item['type']}&project_no=${item['project_no']}&prod_order=${item['prod_order']}&mat_no=${item['mat_no']}&date_prod=$formattedDate";
          Share.CodeMove = widget.codemove;

          //checkInternet.checkInternetAndProceed_WithTry(context, () {
          //  // ดำเนินการต่อเมื่อมีการเชื่อมต่ออินเทอร์เน็ต
          //  Navigator.push(context, MaterialPageRoute(builder: (context) {
          //    return ProductDetail();
          //  }));
          //});

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkInternetAndVersionLink(context);
          });
        },
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
    );
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
        // ตรวจสอบว่ามีข้อมูลใน TextField อย่างน้อย 1 ช่องหรือไม่
        if (projectNumberController.text.isNotEmpty ||
            productionOrderController.text.isNotEmpty ||
            materialNumberController.text.isNotEmpty ||
            lengthController.text.isNotEmpty) {
          setState(() {
            // เรียกใช้ fetchMultipleApis เพื่อนำข้อมูลมาแสดง
            productData = fetchMultipleApis(
              projectNo: projectNumberController.text,
              prodOrder: productionOrderController.text,
              matNo: materialNumberController.text,
              length: lengthController.text,
            );
          });
        } else {
          // แสดงข้อความแจ้งเตือนหากไม่มีข้อมูลในช่องใดเลย
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("กรุณาป้อนข้อมูลอย่างน้อย 1 ช่อง"),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
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
}
