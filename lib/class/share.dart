//import 'dart:convert';

import 'dart:ffi';

class Share {
  static bool isLoggedIn = false;
  static Function updateState = () {};

  //ALL
  static String Uname = '';
  static String Name = '';
  static String CodeMove = '';

  //Prodution Detail
  static String URL = '';

  //IN
  static String LocationIN = '';
  static int LocationIN_ID = 0;
  static String LocationIN_Name = '';
  static String LocationIN_Keep = '';

  //OUT
  static String LocationOUT = '';
  static int LocationOUT_ID = 0;
  static String LocationOUT_Name = '';
  static String LocationOUT_Keep = '';

  //STOCK
  static String LocationSTOCK = '';
  static int LocationSTOCK_ID = 0;
  static String LocationSTOCK_Name = '';
  static String LocationSTOCK_Keep = '';
}
