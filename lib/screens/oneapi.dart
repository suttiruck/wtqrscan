import 'package:flutter/material.dart';
import 'package:wtqrscan/api/auth_service.dart';
import 'package:wtqrscan/api/get_Data.dart';
import 'package:wtqrscan/class/DateFormat.dart';
import 'package:wtqrscan/class/alert.dart';
import 'package:wtqrscan/class/share.dart';

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

class oneapi extends StatelessWidget {
  const oneapi({super.key});

  Future<Map<String, dynamic>?> fetchData() async {
    final GetAllData _getalldata = GetAllData();
    String url = Share.URL;
    Uri uri = Uri.parse(url);
    final response = await _getalldata.prodinfo(
      uri.queryParameters['type_qrcode'] ?? 'Unknown',
      uri.queryParameters['project_no'] ?? 'Unknown',
      uri.queryParameters['prod_order'] ?? 'Unknown',
      uri.queryParameters['mat_no'] ?? 'Unknown',
      uri.queryParameters['date_prod'] ?? 'Unknown',
    );
    return response;
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => alert(
              context,
              title: '',
              content: 'ออกจากระบบ?',
              okAction: () async {
                await _authService.logout(context);
              },
              showCancel: true,
            ),
          )
        ],
        title: const Text("Product Information"),
      ),
      body: SingleChildScrollView(
        // เพิ่ม SingleChildScrollView เพื่อให้ทั้งหน้าเลื่อน
        child: Container(
          margin: EdgeInsets.all(10), // เพิ่มระยะห่างภายนอกกรอบ
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blueGrey, // สีของขอบ
              width: 1, // ความหนาของขอบ
            ),
            borderRadius: BorderRadius.circular(8), // มุมโค้ง
          ),
          child: Column(
            children: [
              SizedBox(
                width: 350,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/wtglogo144.png',
                      width: 144,
                      height: 144,
                    ),
                    //Text(Share.URL),
                  ],
                ),
              ),
              FutureBuilder<Map<String, dynamic>?>(
                // เริ่มต้น FutureBuilder
                future: fetchData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final data = snapshot.data!;

                    // ดึงค่าจาก JSON สำหรับแต่ละข้อมูลใน detail
                    final List<String> detail = [
                      data['data']['project_no'] ?? 'N/A',
                      data['data']['prod_order'] ?? 'N/A',
                      data['data']['ref_prod_order']?.isEmpty ?? true
                          ? '-'
                          : data['data']['ref_prod_order'] ??
                              '-', // แสดง '-' ถ้าค่าว่างหรือ null
                      data['data']['mat_no'] ?? 'N/A',
                      data['data']['panel_length']?.toString() ?? 'N/A',
                      data['data']['qty_copy']?.toString() ?? 'N/A',
                      data['data']['mat_des'] ?? 'N/A',
                      Formatdate.formatDate(data['data']['date_prod']),
                      Formatdate.formatDate(data['data']['date_expect_send']),
                      data['data']['batch_code'] ?? 'N/A',
                      data['data']['remark']?.isEmpty ?? true
                          ? '-'
                          : data['data']['remark'] ?? '-',
                    ];

                    return ListView.separated(
                      shrinkWrap: true, // ให้ ListView มีขนาดตามข้อมูลที่แสดง
                      physics:
                          NeverScrollableScrollPhysics(), // ไม่ให้ ListView เลื่อนเอง
                      padding: EdgeInsets.all(10),
                      itemCount: items.length,
                      itemBuilder: (context, index) =>
                          buildListTitle(index, detail),
                      separatorBuilder: (context, i) => Divider(
                        thickness: 1,
                        color: Colors.blueGrey,
                        indent: 10,
                        endIndent: 10,
                      ),
                    );
                  } else {
                    // เมื่อไม่มีข้อมูลให้แสดงข้อความที่กลางหน้าจอ
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 100),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 30),
                            decoration: BoxDecoration(
                              color: Colors.grey[200], // กำหนดสีพื้นหลัง
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blueGrey,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'No data found',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListTitle(int index, List<String> detail) => ListTile(
        title: Text(
          items[index],
          textScaleFactor: 0.8,
        ),
        trailing: Text(
          detail[index],
          textScaleFactor: 1.1,
        ),
      );
}
