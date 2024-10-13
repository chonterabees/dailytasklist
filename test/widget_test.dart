import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daily_task_manager/Screen/TaskDetailScreen.dart';
void main() {
  testWidgets('ทดสอบการตั้งค่าการแจ้งเตือนใน TaskDetailScreen',
      (WidgetTester tester) async {
    // สร้าง TaskDetailScreen จำลอง
    final task = {
      'title': 'Test Task',
      'details': 'Test Details',
      'date': '',
      'time': '',
      'location': '',
      'latLng': null,
      'completed': false,
      'notification': false
    };
    await tester.pumpWidget(MaterialApp(
      home: TaskDetailScreen(task: task),
    ));
    final switchFinder = find.byType(Switch);// ค้นหา Switch 
    Switch notificationSwitch = tester.widget(switchFinder);// ตรวจสอบว่า Switch 
    expect(notificationSwitch.value, false);
    await tester.tap(switchFinder); // เปลี่ยนสถานะของ Switch
    await tester.pumpAndSettle(); // รอให้ state ถูกอัพเดต
    // ตรวจสอบว่า Switch อยู่ในสถานะไหน
    notificationSwitch = tester.widget(switchFinder);
    expect(notificationSwitch.value, true);
  });
}
