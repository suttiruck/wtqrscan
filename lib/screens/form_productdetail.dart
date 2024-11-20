import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wtqrscan/api/auth_service.dart';
import 'package:wtqrscan/api/checkInternet.dart';
import 'package:wtqrscan/api/get_Data.dart';
import 'package:wtqrscan/class/DateFormat.dart';
import 'package:wtqrscan/class/FindHistoryScan.dart';
import 'package:wtqrscan/class/FindProductAllLocation.dart';
import 'package:wtqrscan/class/alert.dart';
import 'package:wtqrscan/class/share.dart';
import 'dart:async';

import '../class/CustomBackAppBar.dart';
import '../class/CustomGradientButton.dart';
import '../class/GradientHeader.dart';
import '../class/checkAppVersion.dart';

// รายการหัวข้อที่จะแสดงใน ListView สำหรับรายละเอียดสินค้า
final List<String> items = [
  'Project No.',
  'Production Order',
  'Ref. Production Order',
  'Material No.',
  'ความยาวแผ่น (m)',
  'จำนวนแผ่น',
  'Material Description',
  'Production Date',
  'Delivery Date',
  'Batch Code',
  'Remark',
];
int _value = 1; // ตัวแปรเก็บค่าของตัวนับ

// คลาสหลักที่แสดงรายละเอียดสินค้า
class ProductDetail extends StatefulWidget {
  const ProductDetail({super.key});

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final AuthService _authService = AuthService();
  late Future<Map<String, dynamic>?> productData; // เก็บข้อมูลที่ดึงจาก API
  final checkInternet = CheckInternet();

  // สร้างตัวแปรคีย์เพื่อควบคุมการรีเฟรชของ widget
  Key _untilAmountKey = UniqueKey();
  Key _historyKey = UniqueKey();
  Key _getProductInfoKey = UniqueKey();
  Key _AmountKey = UniqueKey();
  Key _FindLocationKeyKey = UniqueKey();

  // เพิ่มคอนโทรลเลอร์สำหรับ TextField ของ remark
  final TextEditingController _ctrlRemark = TextEditingController();

  // สร้าง TextEditingController สำหรับแต่ละจำนวน
  final TextEditingController receiveAmountController =
      TextEditingController(text: '0.00');
  final TextEditingController withdrawAmountController =
      TextEditingController(text: '0.00');
  final TextEditingController remainingAmountController =
      TextEditingController(text: '0.00');

  @override
  void initState() {
    super.initState();
    productData = fetchMultipleApis(); // โหลดข้อมูลครั้งแรก

    _value = 1;
  }

  void refreshData() {
    setState(() {
      productData = fetchMultipleApis(); // รีเฟรชข้อมูลเมื่อเรียกใช้

      // เปลี่ยน Key เพื่อบังคับการโหลด widget ใหม่
      _AmountKey = UniqueKey();
      // เปลี่ยน Key เพื่อบังคับ Widget โหลดใหม่
      _historyKey = UniqueKey();
      _FindLocationKeyKey = UniqueKey();
    });
  }

  void updateAmounts(double receive, double withdraw, double remaining) {
    setState(() {
      receiveAmountController.text = receive.toStringAsFixed(2);
      withdrawAmountController.text = withdraw.toStringAsFixed(2);
      remainingAmountController.text = remaining.toStringAsFixed(2);

      // เปลี่ยน Key เพื่อบังคับการโหลด widget ใหม่
      _AmountKey = UniqueKey();
    });
  }

  // ฟังก์ชันสำหรับดึงข้อมูลจาก API หลายตัวและรวมผลลัพธ์
  Future<Map<String, dynamic>?> fetchMultipleApis() async {
    final GetAllData _getAllData = GetAllData();

    String url = Share.URL;
    Uri uri = Uri.parse(url);

    // เรียกใช้ API ข้อมูลสินค้า
    Future<Map<String, dynamic>?> apiCall1 = _getAllData.prodinfo(
      uri.queryParameters['type_qrcode'] ?? 'Unknown',
      uri.queryParameters['project_no'] ?? 'Unknown',
      uri.queryParameters['prod_order'] ?? 'Unknown',
      uri.queryParameters['mat_no'] ?? 'Unknown',
      uri.queryParameters['date_prod'] ?? 'Unknown',
    );

    // รอผลลัพธ์จาก API ทั้งหมด
    return await Future.wait([apiCall1]).then((responses) {
      final data1 = responses[0];
      return {'data1': data1}; // คืนค่าผลลัพธ์ในรูปแบบแผนที่
    });
  }

  @override
  void dispose() {
    _ctrlRemark.dispose(); // ทำลายคอนโทรลเลอร์เมื่อ widget ถูกทำลาย

    // ล้าง controller เมื่อ widget ถูกทำลาย
    receiveAmountController.dispose();
    withdrawAmountController.dispose();
    remainingAmountController.dispose();
    super.dispose();
  }

  // ฟังก์ชันสำหรับบันทึกข้อมูล
  Future<void> btnSAVEAction() async {
    String url_3 = Share.URL;
    Uri uri_3 = Uri.parse(url_3);
    final GetAllData getAllData = GetAllData();
    final remark = _ctrlRemark.text;

    if (_value > 0) {
      int locationId;
      if (Share.CodeMove == '10') {
        locationId = Share.LocationIN_ID;
      } else if (Share.CodeMove == '20') {
        locationId = Share.LocationOUT_ID;
      } else if (Share.CodeMove == '30') {
        locationId = Share.LocationSTOCK_ID;
      } else {
        locationId = 0;
      }

      bool isSavedata = await getAllData.saveQRData(
        Share.CodeMove,
        uri_3.queryParameters['type_qrcode'] ?? 'Unknown',
        uri_3.queryParameters['project_no'] ?? 'Unknown',
        uri_3.queryParameters['prod_order'] ?? 'Unknown',
        uri_3.queryParameters['mat_no'] ?? 'Unknown',
        uri_3.queryParameters['date_prod'] ?? 'Unknown',
        _value,
        locationId,
        Share.Uname,
        remark,
      );

      if (isSavedata) {
        alert(context,
            title: 'Massage Box', content: 'บันทึกสำเร็จ', showCancel: false);
        setState(() {
          refreshData();
          _untilAmountKey = UniqueKey();
          _historyKey = UniqueKey();
          _getProductInfoKey = UniqueKey();
          _AmountKey = UniqueKey();
        });
      } else {
        alert(context,
            title: 'Massage Box',
            content: 'กรุณาตรวจสอบจำนวน IN/OUT หรือ Location ให้ถูกต้อง',
            showCancel: false);
      }
    } else {
      alert(context,
          title: 'Massage Box',
          content: 'กรุณาป้อนจำนวนมากกว่า 0 แผ่น',
          showCancel: false);
    }
  }

// ฟังก์ชันปุ่ม SAVE ที่มีการตกแต่ง
  Widget btnSAVE() {
    return CustomGradientButton(
      text: "SAVE",
      icon: Icons.save,
      onPressed: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkInternetAndVersion(context);
        });
      },
      gradientColors: [Colors.blue.shade400, Colors.blue.shade600],
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
        // หากเวอร์ชันถูกต้อง ให้ดำเนินการตรวจสอบการเข้าสู่ระบบ
        btnSAVEAction();
      }
    });
  }

  Widget txtRemark(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 360 ? 18.0 : 20.0;

    return Container(
      padding: const EdgeInsets.all(10), // เพิ่ม padding รอบ Container
      //decoration: BoxDecoration(
      //  border: Border.all(
      //    color: Colors.grey, // สีของกรอบ
      //    width: 1, // ความหนาของกรอบ
      //  ),
      //  borderRadius:
      //      BorderRadius.circular(8), // โค้งมุมของกรอบ
      //),
      child: TextField(
        controller: _ctrlRemark, // คอนโทรลเลอร์สำหรับเก็บข้อมูล remark
        maxLines: 3, // ตั้งค่าเป็น multiline โดยกำหนดจำนวนบรรทัดที่แสดง
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), // โค้งมุมกรอบของ TextField
            borderSide: BorderSide(
              color: Colors.grey, // สีของกรอบ TextField
            ),
          ),
          hintText: 'Enter remarks here', // ข้อความแนะนำใน TextField
          labelText: 'Remark', // แสดงคำว่า Remark
          labelStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: Colors.black, // กำหนดสีข้อความ (ปรับได้ตามต้องการ)
          ),
          alignLabelWithHint: true, // ทำให้ label/hint ชิดบนซ้าย
          floatingLabelBehavior:
              FloatingLabelBehavior.always, // ให้ label ค้างที่ด้านบนเสมอ
        ),
      ),
    );
  }

  Widget worker(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 360 ? 14.0 : 16.0;

    return Container(
      margin: const EdgeInsets.all(10),
      width:
          MediaQuery.of(context).size.width, // กำหนดความกว้างเท่ากับขนาดของจอ
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 234, 236, 238), // ถ้ามีค่า ใช้พื้นหลัง
        border: Border.all(
          color: Colors.blue, // ถ้ามีค่า ใช้กรอบสีน้ำเงิน
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        // จัดให้ข้อความอยู่กลาง Container
        child: Text(
          "Worker : " + Share.Name.toString(), // ถ้ามีข้อมูล
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: Colors.blue, // ถ้ามีค่า ใช้สีน้ำเงิน
          ),
          textAlign: TextAlign.center, // จัดข้อความให้อยู่ตรงกลางแนวนอน
        ),
      ),
    );
  }

  Widget location(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 360 ? 14.0 : 16.0;

    return Container(
      margin: const EdgeInsets.all(10),
      width:
          MediaQuery.of(context).size.width, // กำหนดความกว้างเท่ากับขนาดของจอ
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 234, 236, 238), // ถ้ามีค่า ใช้พื้นหลัง
        border: Border.all(
          color: Colors.blue, // ถ้ามีค่า ใช้กรอบสีน้ำเงิน
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        // จัดให้ข้อความอยู่กลาง Container
        child: Text(
          // กำหนดข้อความ "Location : " ตามด้วยค่าของชื่อ Location และข้อความ Remark ตามเงื่อนไข Share.CodeMove
          "Location : " +
              (Share.CodeMove == "10"
                      ? Share
                          .LocationIN_Name // ใช้ LocationIN_Name หาก Share.CodeMove เท่ากับ "10"
                      : Share.CodeMove == "20"
                          ? Share
                              .LocationOUT_Name // ใช้ LocationOUT_Name หาก Share.CodeMove เท่ากับ "20"
                          : Share.CodeMove == "30"
                              ? Share
                                  .LocationSTOCK_Name // ใช้ LocationSTOCK_Name หาก Share.CodeMove เท่ากับ "30"
                              : "" // ปล่อยว่าง หาก Share.CodeMove ไม่ใช่ "10", "20", หรือ "30"
                  )
                  .toString() +
              " Remark : " +
              (Share.CodeMove == "10"
                  ? Share
                      .LocationIN_Keep // ใช้ LocationIN_Keep หาก Share.CodeMove เท่ากับ "10"
                  : Share.CodeMove == "20"
                      ? Share
                          .LocationOUT_Keep // ใช้ LocationOUT_Keep หาก Share.CodeMove เท่ากับ "20"
                      : Share.CodeMove == "30"
                          ? Share
                              .LocationSTOCK_Keep // ใช้ LocationSTOCK_Keep หาก Share.CodeMove เท่ากับ "30"
                          : "" // ปล่อยว่าง หาก Share.CodeMove ไม่ใช่ "10", "20", หรือ "30"
              ),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: Colors.blue, // กำหนดสีของตัวอักษรเป็นสีน้ำเงิน
          ),
          textAlign: TextAlign.center, // จัดข้อความให้อยู่ตรงกลางแนวนอน
        ),
      ),
    );
  }

  Widget amount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 360 ? 13.0 : 15.0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 2), // margin ด้านบนและล่าง
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 2,
      ), // padding รอบข้อความ
      alignment: Alignment.centerLeft, // ชิดซ้าย
      child: Text(
        "Amount :",
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: Colors.black, // กำหนดสี (ถ้าต้องการ)
        ),
      ),
    );
  }

  Widget getProductInfo(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 360 ? 16.0 : 18.0;

    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8), // โค้งมุมขอบของ Container หลัก
      ),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header พร้อมความโค้งที่สามารถกำหนดค่าได้
          GradientHeader(
            text: 'Product Information',
            color1: Colors.blue.shade300,
            color2: Colors.blue.shade600,
            borderRadius: 7.0,
            icon: Icons.info,
          ),

          // ส่วนแสดงข้อมูลสินค้าที่ดึงจาก API
          Padding(
            padding: const EdgeInsets.all(0),
            child: FutureBuilder<Map<String, dynamic>?>(
              future: productData, // ใช้ Future ที่ดึงข้อมูลแล้ว
              //future:
              //fetchMultipleApis(), // เรียก API โดยตรงใน future ทุกครั้งที่ build
              builder: (context, snapshot) {
                // กรณีที่ข้อมูลยังโหลดไม่เสร็จ
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // กรณีที่เกิดข้อผิดพลาด
                else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                // กรณีที่โหลดข้อมูลสำเร็จและมีข้อมูล
                else if (snapshot.hasData) {
                  final data = snapshot.data!;
                  final data1 = data['data1'];

                  // ถ้าไม่มีข้อมูลให้แสดง "No data found"
                  if (data1 == null || data1['data'] == null) {
                    Future.microtask(() => alert(
                          context,
                          title: 'Message Box',
                          content:
                              'QR Code ไม่ถูกต้อง หรือไม่มีข้อมูล Production Order นี้ในระบบ',
                          showCancel: false,
                          okAction: () {
                            Navigator.of(context).pop(); // ปิด AlertDialog
                            Navigator.of(context).pop(); // กลับหน้าก่อนหน้า
                          },
                        ));
                    return const SizedBox
                        .shrink(); // คืนค่าว่างเพื่อไม่ให้แสดงอะไร
                    //return Center(
                    //  child: Container(
                    //    padding: const EdgeInsets.symmetric(
                    //        vertical: 20, horizontal: 30),
                    //    decoration: BoxDecoration(
                    //      borderRadius: BorderRadius.circular(8),
                    //    ),
                    //    child: Text(
                    //      'No data found',
                    //      style: TextStyle(
                    //        fontSize: 18,
                    //        fontWeight: FontWeight.bold,
                    //        color: Colors.red,
                    //      ),
                    //    ),
                    //  ),
                    //);
                  }

                  // สร้างรายการข้อมูลที่ได้จาก API
                  final List<String> detail = [
                    data1['data']['project_no'] ?? 'N/A',
                    data1['data']['prod_order'] ?? 'N/A',
                    data1['data']['ref_prod_order']?.isEmpty ?? true
                        ? '-'
                        : data1['data']['ref_prod_order'] ?? '-',
                    data1['data']['mat_no'] ?? 'N/A',
                    data1['data']['panel_length']?.toString() ?? 'N/A',
                    data1['data']['qty_copy']?.toString() ?? 'N/A',
                    data1['data']['mat_des'] ?? 'N/A',
                    Formatdate.formatDate(data1['data']['date_prod']),
                    Formatdate.formatDate(data1['data']['date_expect_send']),
                    data1['data']['batch_code'] ?? 'N/A',
                    data1['data']['remark']?.isEmpty ?? true
                        ? '-'
                        : data1['data']['remark'] ?? '-',
                  ];

                  // อัปเดตค่าใน TextEditingController หลังจากที่ data1 ถูกโหลดสำเร็จ
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      updateAmounts(
                        double.tryParse(
                                data1['data']['qty_in']?.toString() ?? '0') ??
                            0.0,
                        double.tryParse(
                                data1['data']['qty_out']?.toString() ?? '0') ??
                            0.0,
                        double.tryParse(
                                data1['data']['qty_prod']?.toString() ?? '0') ??
                            0.0,
                      );
                    });
                  });

                  // สร้าง ListView แสดงข้อมูลสินค้า
                  return ListView.separated(
                    shrinkWrap:
                        true, // ให้ขนาดของ ListView พอดีกับจำนวนของ item
                    physics:
                        NeverScrollableScrollPhysics(), // ปิดการ scroll ของ ListView
                    padding:
                        const EdgeInsets.all(10), // กำหนด padding รอบ ListView
                    itemCount: items.length, // จำนวนรายการใน ListView
                    itemBuilder: (context, index) =>
                        buildListTitle(index, detail),
                    separatorBuilder: (context, i) => Divider(
                      thickness: 1, // ความหนาของเส้นแบ่ง
                      color: Colors.blueGrey, // สีของเส้นแบ่ง
                      indent: 10, // ระยะห่างจากขอบซ้าย
                      endIndent: 10, // ระยะห่างจากขอบขวา
                    ),
                  );
                }
                // กรณีไม่มีข้อมูลแสดงข้อความ "No data found"
                else {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'No data found',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget getUntilAmount() {
    // Define `url` and `uri` outside the widget
    String url_1 = Share.URL;
    Uri uri_1 = Uri.parse(url_1);

    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      width:
          double.infinity, // Ensure the container width takes full screen width
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header พร้อมความโค้งที่สามารถกำหนดค่าได้
          GradientHeader(
            text: 'Product Amount Information',
            color1: Colors.blue.shade300,
            color2: Colors.blue.shade600,
            borderRadius: 7.0,
            icon: Icons.storage,
          ),

          // Content
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  _buildAmountContainer(
                      "จำนวนรับเข้า", receiveAmountController),
                  const SizedBox(height: 10),
                  _buildAmountContainer(
                      "จำนวนเบิกออก", withdrawAmountController),
                  const SizedBox(height: 10),
                  _buildAmountContainer(
                      "จำนวนคงเหลือ", remainingAmountController),

                  //_buildAmountContainer(
                  //  "จำนวนรับเข้า",
                  //  receiveAmountController,
                  //  margin: const EdgeInsets.all(16),
                  //  padding: const EdgeInsets.symmetric(
                  //      vertical: 20, horizontal: 16),
                  //),

                  // Pass the extracted query parameters to `FindProductAllLocation`
                  Container(
                    key: _FindLocationKeyKey,
                    child: FindProductAllLocation(
                      typeqr: uri_1.queryParameters['type_qrcode'] ?? 'Unknown',
                      proJe: uri_1.queryParameters['project_no'] ?? 'Unknown',
                      proOr: uri_1.queryParameters['prod_order'] ?? 'Unknown',
                      MatNum: uri_1.queryParameters['mat_no'] ?? 'Unknown',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// ฟังก์ชันสำหรับสร้าง Container แสดงจำนวนที่ควบคุมด้วย TextEditingController พร้อมความกว้างเต็มหน้าจอและกำหนด margin, padding ได้
  Widget _buildAmountContainer(
    String title,
    TextEditingController controller, {
    EdgeInsetsGeometry margin = const EdgeInsets.symmetric(vertical: 2),
    EdgeInsetsGeometry padding = const EdgeInsets.all(12),
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize14 = screenWidth < 360 ? 12.0 : 14.0;
    final fontSize15 = screenWidth < 360 ? 13.0 : 15.0;
    final fontSize16 = screenWidth < 360 ? 14.0 : 16.0;
    final fontSize18 = screenWidth < 360 ? 16.0 : 18.0;

    return Container(
      margin: margin, // กำหนด margin ที่สามารถปรับได้จากภายนอก
      padding: padding, // กำหนด padding ที่สามารถปรับได้จากภายนอก
      width: double.infinity, // ให้ Container มีความกว้างเต็มหน้าจอ
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.blue.shade300], // สีไล่ระดับ
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.blue.shade700, // สีขอบเข้มขึ้น
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(2), // เพิ่มความโค้งมน
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(4, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ชื่อหัวข้อ
          Text(
            title,
            style: TextStyle(
              fontSize: fontSize16,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 6), // ระยะห่างระหว่าง title และจำนวน
          // จำนวนที่ได้จาก TextEditingController
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              '${controller.text} แผ่น',
              style: TextStyle(
                fontSize: fontSize18,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define `url` and `uri` outside the widget
    String url_2 = Share.URL;
    Uri uri_2 = Uri.parse(url_2);

    return Scaffold(
      appBar: CustomBackAppBar(
        titleText: "Product Information",
        color1: Colors.blue.shade400,
        color2: Colors.blue.shade700,
        leadingIcon: Icons.inventory,
        actionIcon: Icons.exit_to_app,
        onActionPressed: () => alert(
          context,
          title: 'Message Box',
          content: 'ออกจากระบบ?',
          okAction: () async {
            await _authService.logout(context);
          },
          showCancel: true,
        ),
        onBackPressed: () {
          Navigator.pop(context); // กลับไปหน้าก่อนหน้า
        },
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // ยกเลิกการโฟกัสของ TextField เมื่อแตะบริเวณอื่น
        },
        child: RefreshIndicator(
          onRefresh: () async {
            refreshData(); // เรียกฟังก์ชัน refreshData เพื่อโหลดข้อมูลใหม่
          },
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(), // ให้ ScrollView รองรับ Pull-to-Refresh
            child: Column(
              children: [
                if (Share.CodeMove != '00')
                  Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blueGrey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(
                          8), // โค้งมุมขอบของ Container หลัก
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // header ชิดซ้าย
                      children: [
                        GradientHeader(
                          text: Share.CodeMove == "10"
                              ? 'IN'
                              : Share.CodeMove == "20"
                                  ? 'OUT'
                                  : Share.CodeMove == "30"
                                      ? 'STOCK'
                                      : 'Product Information',
                          color1: Share.CodeMove == "10"
                              ? Colors.yellow.shade300
                              : Share.CodeMove == "20"
                                  ? Colors.green.shade300
                                  : Share.CodeMove == "30"
                                      ? Colors.orange.shade300
                                      : Colors.blue.shade300,
                          color2: Share.CodeMove == "10"
                              ? Colors.yellow.shade600
                              : Share.CodeMove == "20"
                                  ? Colors.green.shade600
                                  : Share.CodeMove == "30"
                                      ? Colors.orange.shade600
                                      : Colors.blue.shade600,
                          borderRadius: 7.0,
                          icon: Icons.sync_alt,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              worker(context),
                              const SizedBox(height: 0),
                              location(context),
                              const SizedBox(height: 0),
                              amount(context),
                              CounterDisplay(),
                              const SizedBox(height: 10),
                              txtRemark(context),
                              const SizedBox(height: 0),
                              btnSAVE(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  key: _getProductInfoKey,
                  child: getProductInfo(context),
                ),
                Container(
                  key: _untilAmountKey,
                  child: getUntilAmount(),
                ),
                Container(
                  key: _historyKey,
                  child: FindHistoryScan(
                    typeqr: uri_2.queryParameters['type_qrcode'] ?? 'Unknown',
                    proJe: uri_2.queryParameters['project_no'] ?? 'Unknown',
                    proOr: uri_2.queryParameters['prod_order'] ?? 'Unknown',
                    MatNum: uri_2.queryParameters['mat_no'] ?? 'Unknown',
                    proDate: uri_2.queryParameters['date_prod'] ?? 'Unknown',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันสำหรับสร้างรายการ ListTile ใน ListView
  Widget buildListTitle(int index, List<String> detail) {
    // สลับสีพื้นหลังระหว่างรายการที่เป็นเลขคู่และเลขคี่
    Color backgroundColor = index.isEven ? Colors.blue[50]! : Colors.grey[100]!;
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize14 = screenWidth < 360 ? 12.0 : 14.0;
    final fontSize15 = screenWidth < 360 ? 13.0 : 15.0;
    final fontSize16 = screenWidth < 360 ? 14.0 : 16.0;
    final fontSize18 = screenWidth < 360 ? 16.0 : 18.0;

    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: 5, horizontal: 0), // margin รอบรายการ
      padding: const EdgeInsets.symmetric(
          vertical: 10, horizontal: 15), // padding ภายในกรอบ
      decoration: BoxDecoration(
        color: backgroundColor, // สีพื้นหลังของแต่ละรายการ
        borderRadius: BorderRadius.circular(2), // มุมโค้งของขอบ
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // สีของเงาแบบจาง
            blurRadius: 5, // ความฟุ้งของเงา
            offset: Offset(0, 3), // ตำแหน่งของเงา
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ใช้ Expanded เพื่อให้ title ใช้พื้นที่ได้มากขึ้น
          Expanded(
            flex: 3, // กำหนดความกว้างตามสัดส่วน
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  items[index], // ข้อความของรายการ
                  style: TextStyle(
                    fontSize: fontSize16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey[800], // สีตัวอักษร
                  ),
                ),
                //SizedBox(height: 4), // เว้นช่องว่างระหว่าง title กับ subtitle
                //Text(
                //  'Additional info about item ${index + 1}', // ข้อความย่อยเพิ่มเติม
                //  style: TextStyle(
                //    fontSize: 12, // ขนาดตัวอักษรย่อย
                //    color: Colors.blueGrey[600], // สีตัวอักษรย่อย
                //  ),
                //),
              ],
            ),
          ),
          const SizedBox(width: 10), // เว้นระยะห่างระหว่าง title กับ trailing
          // ใช้ Flexible เพื่อให้ trailing รองรับการขึ้นบรรทัดใหม่
          Flexible(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight, // จัดข้อความให้ชิดขวา
              child: Text(
                detail[index], // ข้อความที่อยู่ด้านขวาสุดของรายการ
                style: TextStyle(
                  fontSize: fontSize14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent, // สีตัวอักษรด้านขวา
                ),
                textAlign: TextAlign.right, // จัดข้อความชิดขวาในแนว text
                softWrap: true, // อนุญาตให้ขึ้นบรรทัดใหม่
                overflow: TextOverflow.visible, // แสดงข้อความทั้งหมดโดยไม่ตัด
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// คลาส CounterDisplay สำหรับแสดงตัวนับที่สามารถเพิ่มหรือลดค่าได้
class CounterDisplay extends StatefulWidget {
  @override
  _CounterDisplayState createState() => _CounterDisplayState();
}

class _CounterDisplayState extends State<CounterDisplay> {
  //int _value = 0; // ตัวแปรเก็บค่าของตัวนับ
  Timer? _timer; // Timer สำหรับการเพิ่มหรือลดค่าเมื่อกดค้าง
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = '$_value'; // ตั้งค่าเริ่มต้นใน TextField
  }

  // ฟังก์ชันเพิ่มค่า _value
  void _increment() {
    setState(() {
      _value += 1;
      _controller.text = '$_value'; // อัพเดตค่าใน TextField
    });
  }

  // ฟังก์ชันลดค่า _value โดยไม่ให้ติดลบ
  void _decrement() {
    if (_value > 0) {
      setState(() {
        _value -= 1;
        _controller.text = '$_value'; // อัพเดตค่าใน TextField
      });
    }
  }

  // เริ่มเพิ่มค่า _value อย่างต่อเนื่องเมื่อกดค้าง
  void _startIncrement() {
    _increment();
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      _increment();
    });
  }

  // เริ่มลดค่า _value อย่างต่อเนื่องเมื่อกดค้าง
  void _startDecrement() {
    _decrement();
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      _decrement();
    });
  }

  // หยุดการทำงานของ Timer เมื่อปล่อยปุ่ม
  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize14 = screenWidth < 360 ? 12.0 : 14.0;
    final fontSize15 = screenWidth < 360 ? 13.0 : 15.0;
    final fontSize16 = screenWidth < 360 ? 14.0 : 16.0;
    final fontSize18 = screenWidth < 360 ? 16.0 : 18.0;
    final fontSize20 = screenWidth < 360 ? 18.0 : 20.0;
    final flexSize2 = screenWidth < 360 ? 2 : 2;
    final flexSize5 = screenWidth < 360 ? 3 : 5;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ปุ่มลดค่า ใช้ Flexible เพื่อกำหนดให้กว้างน้อยกว่า TextField
            Flexible(
              flex: flexSize2, // อัตราส่วนของปุ่มลดค่า
              child: GestureDetector(
                onTapDown: (_) => _startDecrement(),
                onTapUp: (_) => _stopTimer(),
                onTapCancel: _stopTimer,
                child: OutlinedButton(
                  onPressed: _decrement,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('-', style: TextStyle(fontSize: fontSize20)),
                ),
              ),
            ),
            // TextField แสดงและแก้ไขค่า _value ได้โดยตรง ใช้ Expanded เพื่อขยายให้กว้างกว่า
            Expanded(
              flex: flexSize5, // อัตราส่วนของ TextField เพื่อให้กว้างกว่าปุ่ม
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _controller, // ใช้ TextEditingController
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly, // จำกัดให้ป้อนได้เฉพาะตัวเลข
                  ],
                  onChanged: (newValue) {
                    // เรียกใช้งานทุกครั้งที่มีการพิมพ์ลงใน TextField
                    setState(() {
                      _value = int.tryParse(newValue) ??
                          0; // แปลงค่าจาก TextField เป็น int และอัปเดตค่า _value หรือให้ค่า 0 ถ้าแปลงไม่ได้
                    });
                  },
                  style: TextStyle(
                      fontSize: fontSize16), // กำหนดขนาดตัวอักษรใน TextField
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10), // กำหนดความโค้งมนของกรอบ
                    ),
                    isDense: true, // ลดความหนาแน่นของพื้นที่ TextField
                    contentPadding: EdgeInsets.symmetric(
                        vertical:
                            8), // padding ภายใน TextField เพื่อให้ข้อความอยู่กลางกรอบ
                  ),
                ),
              ),
            ),

            // ปุ่มเพิ่มค่า ใช้ Flexible เพื่อกำหนดให้กว้างน้อยกว่า TextField
            Flexible(
              flex: flexSize2, // อัตราส่วนของปุ่มเพิ่มค่า
              child: GestureDetector(
                onTapDown: (_) => _startIncrement(),
                onTapUp: (_) => _stopTimer(),
                onTapCancel: _stopTimer,
                child: OutlinedButton(
                  onPressed: _increment,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('+', style: TextStyle(fontSize: fontSize20)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // ลบ controller เมื่อ widget ถูกลบ
    super.dispose();
  }
}
