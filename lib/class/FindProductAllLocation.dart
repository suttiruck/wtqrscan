import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:wtqrscan/api/get_Data.dart';
import 'package:wtqrscan/class/DateFormat.dart';
import 'package:wtqrscan/class/share.dart';
import 'package:wtqrscan/screens/form_productdetail.dart';

class FindProductAllLocation extends StatefulWidget {
  final String typeqr;
  final String proJe;
  final String proOr;
  final String MatNum;

  FindProductAllLocation({
    required this.typeqr,
    required this.proJe,
    required this.proOr,
    required this.MatNum,
  });

  @override
  _FindProductAllLocationState createState() => _FindProductAllLocationState();
}

class _FindProductAllLocationState extends State<FindProductAllLocation> {
  // Future to store the data fetched from the API
  late Future<Map<String, dynamic>?> productData;

  // Function to call the API and fetch data
  Future<Map<String, dynamic>?> fetchMultipleApis({
    required String proJe,
    required String proOr,
    required String MatNum,
    required String typeqr,
  }) async {
    final GetAllData _getAllData = GetAllData();

    // API call to fetch product data
    Future<Map<String, dynamic>?> apiCall1 = _getAllData.getProductAllLocation(
      typeqr,
      proJe,
      proOr,
      MatNum,
    );

    return await Future.wait([apiCall1]).then((responses) {
      final data1 = responses[0];
      return {'data1': data1};
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize the productData Future to automatically load data when the screen loads
    productData = fetchMultipleApis(
      proJe: widget.proJe,
      proOr: widget.proOr,
      MatNum: widget.MatNum,
      typeqr: widget.typeqr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          // Displaying product information fetched from the API
          getProductInfo(context),
        ],
      ),
    );
  }

  // Widget สำหรับแสดงข้อมูลสินค้าที่ได้จาก API
  Widget getProductInfo(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize15 = screenWidth < 360 ? 13.0 : 15.0;
    final fontSize18 = screenWidth < 360 ? 16.0 : 18.0;

    return Padding(
      padding: const EdgeInsets.all(0), // ไม่มี Padding รอบ widget ทั้งหมด
      child: FutureBuilder<Map<String, dynamic>?>(
        future: productData, // future ที่ใช้โหลดข้อมูลจาก API
        builder: (context, snapshot) {
          // แสดงวงกลมหมุนระหว่างรอข้อมูลจาก API
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // แสดงข้อความ Error เมื่อเกิดปัญหาการโหลดข้อมูล
          else if (snapshot.hasError) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(16), // ระยะห่างภายใน Container
                margin: const EdgeInsets.symmetric(vertical: 15), // Margin รอบๆ
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(8), // ความโค้งมุมของ Container
                  border:
                      Border.all(color: Colors.red, width: 1), // เส้นขอบสีแดง
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2), // เงาสีเทาอ่อน
                      spreadRadius: 2,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Error: ${snapshot.error}', // ข้อความแสดงข้อผิดพลาด
                  style: TextStyle(
                    fontSize: fontSize15,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          // แสดงผลข้อมูลเมื่อโหลดสำเร็จ
          else if (snapshot.hasData) {
            final data = snapshot.data;
            final data1 = data?['data1'];

            // ตรวจสอบว่ามีข้อมูลใน data1 หรือไม่ ถ้าไม่มีให้แสดงข้อความ "No data found"
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
                    'This product is not available anywhere.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize18,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
              );
            }

            // ถ้ามีข้อมูล จะแสดงใน ListView
            final List<dynamic> dataList = data1['data'];

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                final item = dataList[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding: const EdgeInsets.all(0), // ระยะห่างภายใน Container
                  decoration: BoxDecoration(
                    color: index.isEven
                        ? Colors.blue.shade50
                        : Colors.grey.shade100, // พื้นหลังสลับสี
                    borderRadius:
                        BorderRadius.circular(2), // ความโค้งมุมของ Container
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1), // เงาเบาๆ
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: buildListTile(
                      item), // เรียกใช้ฟังก์ชันเพื่อสร้าง ListTile สำหรับแต่ละรายการข้อมูล
                );
              },
              separatorBuilder: (context, index) => Divider(
                color: Colors.blueGrey.shade200, // สีของเส้นแบ่ง
                thickness: 1,
                indent: 10,
                endIndent: 10,
              ),
            );
          } else {
            return const SizedBox
                .shrink(); // ถ้าไม่มีข้อมูลใน snapshot แสดงพื้นที่ว่าง
          }
        },
      ),
    );
  }

// ฟังก์ชันสำหรับสร้าง ListTile เพื่อแสดงข้อมูลของสินค้าแต่ละรายการ
  Widget buildListTile(Map<String, dynamic> item) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize14 = screenWidth < 360 ? 12.0 : 14.0;
    final fontSize15 = screenWidth < 360 ? 13.0 : 15.0;
    final fontSize16 = screenWidth < 360 ? 14.0 : 16.0;
    final fontSize18 = screenWidth < 360 ? 16.0 : 18.0;

    return ListTile(
      title: Text(
        "Location: ${item['location_description'] ?? 'N/A'}", // แสดงตำแหน่งหรือ 'N/A' ถ้าไม่มีข้อมูล
        style: TextStyle(
          fontSize: fontSize15,
          fontWeight: FontWeight.w600,
          color: Colors.blueGrey,
        ),
      ),
      trailing: Text(
        "${item['qty_prod']?.toInt() ?? 'N/A'} แผ่น", // แสดงจำนวนสินค้า หรือ 'N/A' ถ้าไม่มีข้อมูล
        style: TextStyle(
          fontSize: fontSize15,
          fontWeight: FontWeight.w600,
          color: Colors.blueGrey,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 10), // ลด Padding เพื่อให้ ListTile กะทัดรัดขึ้น
    );
  }
}
