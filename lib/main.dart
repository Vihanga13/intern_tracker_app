import 'package:flutter/material.dart';
import 'Pages/supervisor_dashboard_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supervisor Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
        brightness: Brightness.light,
      ),
      home: SupervisorDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}
