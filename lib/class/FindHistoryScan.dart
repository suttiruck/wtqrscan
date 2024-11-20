import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:wtqrscan/api/get_Data.dart';
import 'package:wtqrscan/class/DateFormat.dart';
import 'package:wtqrscan/class/GradientHeader.dart';
import 'package:wtqrscan/class/share.dart';
import 'package:wtqrscan/screens/form_productdetail.dart';

class FindHistoryScan extends StatefulWidget {
  final String typeqr;
  final String proJe;
  final String proOr;
  final String MatNum;
  final String proDate;

  FindHistoryScan({
    required this.typeqr,
    required this.proJe,
    required this.proOr,
    required this.MatNum,
    required this.proDate,
  });

  @override
  _FindHistoryScanState createState() => _FindHistoryScanState();
}

class _FindHistoryScanState extends State<FindHistoryScan> {
  Future<Map<String, dynamic>?>? productData;

  Future<Map<String, dynamic>?> fetchMultipleApis({
    required String projectNo,
    required String prodOrder,
    required String matNo,
    required String proddate,
    required String typeQrCode,
  }) async {
    final GetAllData _getAllData = GetAllData();

    Future<Map<String, dynamic>?> apiCall1 = _getAllData.getHistory(
      typeQrCode,
      projectNo,
      prodOrder,
      matNo,
      proddate,
    );

    return await Future.wait([apiCall1]).then((responses) {
      final data1 = responses[0];
      return {'data1': data1};
    });
  }

  @override
  void initState() {
    super.initState();
    productData = fetchMultipleApis(
      projectNo: widget.proJe,
      prodOrder: widget.proOr,
      matNo: widget.MatNum,
      proddate: widget.proDate,
      typeQrCode: widget.typeqr,
    );
  }

  //@override
  //void didChangeDependencies() {
  //  super.didChangeDependencies();
  //  // Unfocus ทุก TextField เมื่อกลับมาที่หน้า
  //  FocusScope.of(context).unfocus();
  //}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            text: 'Process History',
            color1: Colors.blue.shade300,
            color2: Colors.blue.shade600,
            borderRadius: 7.0,
            icon: Icons.history,
          ),

          getProductInfo(context),
        ],
      ),
    );
  }

  // ฟังก์ชันแสดงข้อมูลที่ได้จาก API ในรูปแบบ FutureBuilder
  Widget getProductInfo(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize14 = screenWidth < 360 ? 12.0 : 14.0;
    final fontSize15 = screenWidth < 360 ? 13.0 : 15.0;
    final fontSize16 = screenWidth < 360 ? 14.0 : 16.0;
    final fontSize18 = screenWidth < 360 ? 16.0 : 18.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: FutureBuilder<Map<String, dynamic>?>(
        future: productData, // ข้อมูลที่ต้องการดึงจาก API
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // แสดงวงกลมหมุนระหว่างรอข้อมูล
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // แสดงข้อความข้อผิดพลาด หากการดึงข้อมูลล้มเหลว
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: fontSize16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          } else if (snapshot.hasData) {
            // ตรวจสอบว่ามีข้อมูลอยู่หรือไม่
            final data = snapshot.data;
            final data1 = data?['data1'];

            // หากข้อมูลเป็นค่าว่างหรือไม่มีข้อมูล
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
                    borderRadius: BorderRadius.circular(10), // ขอบโค้งมน
                    border:
                        Border.all(color: Colors.red, width: 2), // เส้นขอบสีแดง
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 3), // เงาของ Container
                      ),
                    ],
                  ),
                  child: Text(
                    'No History Data', // ข้อความเมื่อไม่มีข้อมูล
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize18,
                      fontWeight: FontWeight.w600,
                      color: Colors.red, // สีข้อความ
                    ),
                  ),
                ),
              );
            }

            final List<dynamic> dataList = data1['data']; // ข้อมูลในรูปแบบ List

            // แสดงข้อมูลในรูปแบบ ListView หากมีข้อมูล
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(0),
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                final item = dataList[index];
                return Container(
                  decoration: BoxDecoration(
                    color: index.isEven
                        ? Colors.blue[50]
                        : Colors.grey[100], // สีพื้นตาม index
                    borderRadius: BorderRadius.circular(2), // ความโค้งมุม
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2), // เงาของ Container
                      ),
                    ],
                  ),
                  child:
                      buildListTile(item), // สร้าง ListTile สำหรับแต่ละรายการ
                );
              },
              separatorBuilder: (context, index) => const Divider(
                color: Colors.blueGrey, // สีเส้นแบ่ง
                thickness: 1,
              ),
            );
          } else {
            return const SizedBox.shrink(); // หากไม่มีข้อมูลใดเลย
          }
        },
      ),
    );
  }

// ฟังก์ชันสร้าง ListTile เพื่อแสดงรายละเอียดข้อมูลแต่ละรายการ
  Widget buildListTile(Map<String, dynamic> item) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize14 = screenWidth < 360 ? 12.0 : 14.0;
    final fontSize15 = screenWidth < 360 ? 13.0 : 15.0;
    final fontSize16 = screenWidth < 360 ? 14.0 : 16.0;
    final fontSize18 = screenWidth < 360 ? 16.0 : 18.0;

    return ListTile(
      title: Row(
        children: [
          // ส่วนแสดง Process ของสินค้า
          Text(
            "Process: ",
            style: TextStyle(
              fontSize: fontSize16,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey[800],
            ),
          ),
          Container(
            // กำหนดพื้นหลังของ Process ตามประเภท
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
            decoration: BoxDecoration(
              color: item['description'] == 'IN'
                  ? Colors.yellow.shade700 // สีเหลืองสำหรับ 'IN'
                  : item['description'] == 'OUT'
                      ? Colors.green // สีเขียวสำหรับ 'OUT'
                      : Colors.grey.shade300, // สีเทาสำหรับกรณีอื่น ๆ
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              "${item['description'] ?? 'N/A'}", // แสดงประเภทของ Process
              style: TextStyle(
                fontSize: fontSize16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      // ส่วนแสดงรายละเอียดเพิ่มเติม
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Location: ${item['location_description'] ?? 'N/A'}", // สถานที่
            style: TextStyle(
              fontSize: fontSize14,
              color: Colors.blueGrey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Date/Time: ${Formatdate.formatDateTime(item['create_date'] ?? 'N/A')}", // วันที่และเวลา
            style: TextStyle(
              fontSize: fontSize14,
              color: Colors.blueGrey[600],
            ),
          ),
          Text(
            "Worker: ${item['Name'] ?? 'N/A'}", // ชื่อผู้ดำเนินการ
            style: TextStyle(
              fontSize: fontSize14,
              color: Colors.blueGrey[600],
            ),
          ),
          Text(
            "Remark: ${item['remark'] ?? '-'}", // หมายเหตุ
            style: TextStyle(
              fontSize: fontSize14,
              color: Colors.blueGrey[600],
            ),
          ),
        ],
      ),
      trailing: Text(
        "${item['qty']?.toInt() ?? 'N/A'} แผ่น", // จำนวนสินค้า
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSize15,
          color: Colors.blueGrey,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
    );
  }
}
