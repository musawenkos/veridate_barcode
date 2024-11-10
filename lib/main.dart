import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:veridate_barcode/screens/get_started.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VeriDate',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: GetStartedScreen(),
    );
  }
}


