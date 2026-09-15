import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woc/provider/user_provider.dart';
import 'package:woc/main_wrapper.dart';
//import 'package:google_sign_in/google_sign_in.dart';

void main() async {
/*
  // สั่งให้ระบบ Flutter Engine เชื่อมต่อและสื่อสารกับตัวระบบปฏิบัติการให้เสร็จสมบูรณ์ก่อนเริ่มการทำงาน
  WidgetsFlutterBinding.ensureInitialized();
  
  // ตั้งค่า Google Sign-In ให้พร้อมก่อนเปิดหน้าแอป
  await GoogleSignIn.instance.initialize(
    // เป็นเสมือนตราประทับเพื่อตรวจสอบว่า id ที่ไปเอามาจาก google คืออันเดียวกับที่ผูกไว้กับส่วนของ backend
    serverClientId: "322948964487-s1653nkp0eq497iq4jrq2du61p9af8o1.apps.googleusercontent.com",
  );
*/
  runApp(ChangeNotifierProvider(create: (_) => UserProvider(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainWrapper(),
    );
  }
}
