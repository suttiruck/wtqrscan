import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

void alert(BuildContext context,
    {String title = '',
    String content = '',
    VoidCallback? okAction,
    bool showCancel = false}) {
  void cancelPressed() {
    Navigator.of(context).pop(); // ปิด dialog
  }

  void okPressed() {
    if (okAction != null) {
      okAction();
    } else {
      cancelPressed();
    }
  }

  final screenWidth = MediaQuery.of(context).size.width;
  final iconSize24 = screenWidth < 360 ? 22.0 : 24.0;
  final iconSize30 = screenWidth < 360 ? 28.0 : 30.0;
  final fontSize16 = screenWidth < 360 ? 14.0 : 16.0;
  final fontSize18 = screenWidth < 360 ? 16.0 : 18.0;

  // Title ของ dialog พร้อมไอคอนและพื้นหลังไล่ระดับเหมือน header
  var textTitle = Container(
    padding: const EdgeInsets.all(0),
    alignment: Alignment.centerLeft,
    child: Row(
      children: [
        const SizedBox(width: 0), // ระยะห่างระหว่างไอคอนและข้อความ
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize18,
            fontWeight: FontWeight.w600,
            color: Colors.white, // สีข้อความให้สอดคล้องกับ header
          ),
        ),
      ],
    ),
  );

// Content พร้อมจัดให้อยู่กึ่งกลางและไอคอนด้านหน้า
  var textContent = Container(
    padding: const EdgeInsets.all(16), // ระยะห่างรอบเนื้อหา
    decoration: BoxDecoration(
      color: Colors.blueGrey.shade50, // พื้นหลังสีอ่อน
      borderRadius: BorderRadius.circular(10), // ความโค้งมนของขอบ
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2), // เงาที่ด้านล่าง
        ),
      ],
    ),
    child: Center(
      child: Wrap(
        alignment: WrapAlignment.center, // จัดเนื้อหาให้อยู่กึ่งกลาง
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8, // ระยะห่างระหว่างไอคอนและข้อความ
        children: [
          Icon(
            Icons.warning, // ไอคอนเตือน
            color: Colors.orangeAccent, // กำหนดสีให้เด่นชัดขึ้น
            size: iconSize30, // ขนาดไอคอน
          ),
          Text(
            content,
            textAlign: TextAlign.center, // จัดข้อความให้อยู่กึ่งกลาง
            style: TextStyle(
              fontSize: fontSize16,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey, // สีข้อความเพื่อให้สอดคล้องกับ style
            ),
          ),
        ],
      ),
    ),
  );

// ปุ่ม OK และ Cancel พร้อมสไตล์ใหม่ให้สอดคล้องกับ Dialog
  var textOK = Text(
    'OK',
    style: TextStyle(
        fontSize: fontSize16, fontWeight: FontWeight.w600, color: Colors.white),
  );

  var textCancel = Text(
    'Cancel',
    style: TextStyle(
        fontSize: fontSize16, fontWeight: FontWeight.w600, color: Colors.red),
  );

// ฟังก์ชันสำหรับสร้างปุ่มพร้อมสไตล์ให้สอดคล้องกับ Dialog
  Widget buildButton(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade300, Colors.blue.shade600], // สีไล่ระดับ
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8), // ความโค้งมุมเพิ่มขึ้น
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 3), // เงาของปุ่ม
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  if (Platform.isAndroid) {
    var btnOK = TextButton(
      onPressed: okPressed,
      child: buildButton(textOK),
    );

    var btnCancel = TextButton(
      onPressed: cancelPressed,
      child: buildButton(textCancel),
    );

    // จัดเรียงปุ่ม OK และ Cancel ให้อยู่ใกล้กัน
    var btns = <Widget>[
      btnOK,
      if (showCancel) const SizedBox(width: 0.0), // ลดระยะห่าง
      if (showCancel) btnCancel,
    ];

    showDialog(
      context: context,
      barrierDismissible: false, // ห้ามปิดด้วยการแตะด้านนอก
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // เพิ่มความโค้งมุมของ Dialog
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.blueGrey.shade50
              ], // ไล่สีพื้นหลังอ่อนๆ
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(
              color: Colors.blueGrey.shade300, // สีขอบอ่อน
              width: 1.5, // เพิ่มความหนาของเส้นกรอบ
            ),
            borderRadius: BorderRadius.circular(10), // ความโค้งมุมของกรอบ
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4), // เงาที่ด้านล่างของ Dialog
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header ของ Dialog พร้อมการไล่สีและไอคอน
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade500,
                      Colors.blue.shade700
                    ], // สีไล่ระดับ
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(7),
                    topRight: Radius.circular(7),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.white, size: iconSize24),
                    const SizedBox(width: 8),
                    textTitle, // รับค่า textTitle ที่ส่งมาจากโค้ดหลัก
                  ],
                ),
              ),

              // ส่วนเนื้อหา
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    textContent, // รับค่า textContent ที่ส่งมาจากโค้ดหลัก
                    const SizedBox(height: 16),
                    const Divider(thickness: 1.0, color: Colors.grey),
                  ],
                ),
              ),

              // ปุ่มใน Dialog
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: btns, // รับค่าปุ่มที่ส่งมาจากโค้ดหลัก
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } else if (Platform.isIOS) {
    var btnOK = CupertinoButton(
      onPressed: okPressed,
      child: buildButton(textOK),
    );

    var btnCancel = CupertinoButton(
      onPressed: cancelPressed,
      child: buildButton(textCancel),
    );

    var btns = [
      btnOK,
      if (showCancel) const SizedBox(width: 0.0), // ลดระยะห่าง
      if (showCancel) btnCancel,
    ];

    showCupertinoDialog(
      context: context,
      barrierDismissible: false, // ห้ามปิดด้วยการแตะด้านนอก
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // เพิ่มความโค้งมุมของ Dialog
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.blueGrey.shade50
              ], // ไล่สีพื้นหลังอ่อนๆ
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(
              color: Colors.blueGrey.shade300, // สีขอบอ่อน
              width: 1.5, // เพิ่มความหนาของเส้นกรอบ
            ),
            borderRadius: BorderRadius.circular(10), // ความโค้งมุมของกรอบ
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4), // เงาที่ด้านล่างของ Dialog
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header ของ Dialog พร้อมการไล่สีและไอคอน
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade500,
                      Colors.blue.shade700
                    ], // สีไล่ระดับ
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(7),
                    topRight: Radius.circular(7),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.white, size: iconSize24),
                    const SizedBox(width: 8),
                    textTitle, // รับค่า textTitle ที่ส่งมาจากโค้ดหลัก
                  ],
                ),
              ),

              // ส่วนเนื้อหา
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    textContent, // รับค่า textContent ที่ส่งมาจากโค้ดหลัก
                    const SizedBox(height: 16),
                    const Divider(thickness: 1.0, color: Colors.grey),
                  ],
                ),
              ),

              // ปุ่มใน Dialog
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: btns, // รับค่าปุ่มที่ส่งมาจากโค้ดหลัก
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
