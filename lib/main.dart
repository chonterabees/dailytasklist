import 'package:flutter/material.dart';
//import 'Screen/Login_Screen.dart';
import 'Screen/TaskListScreen.dart';

void main() => runApp(DailyTaskManagerApp());

class DailyTaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
        ),
        listTileTheme: ListTileThemeData(
          iconColor: Colors.black,
          textColor: Colors.black,
        ),
      ),
      //home: LoginScreen(),
      home: TaskListScreen(),
    );
  }
}
