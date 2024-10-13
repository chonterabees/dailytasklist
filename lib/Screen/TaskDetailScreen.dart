import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class TaskDetailScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  TaskDetailScreen({required this.task});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  LatLng? selectedLocation;
  bool isNotificationEnabled = false; // สถานะการเปิดแจ้งเตือน

  @override
  void initState() {
    super.initState();
    titleController.text = widget.task['title'];
    detailsController.text = widget.task['details'];
    locationController.text = widget.task['location'];
    selectedDate =
        widget.task['date'] != '' ? DateTime.parse(widget.task['date']) : null;
    selectedTime = widget.task['time'] != ''
        ? TimeOfDay(
            hour: int.parse(widget.task['time'].split(':')[0]),
            minute: int.parse(widget.task['time'].split(':')[1]),
          )
        : null;
    selectedLocation = widget.task['latLng'];
    isNotificationEnabled =
        widget.task['notification'] ?? false; // รับค่าการแจ้งเตือน
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _selectLocation(BuildContext context) async {
    LatLng? location = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocationPickerScreen()),
    );
    if (location != null) {
      setState(() {
        selectedLocation = location;
        locationController.text =
            '(${location.latitude}, ${location.longitude})';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('กิจกรรมใหม่'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'ชื่อเรื่อง'),
            ),
            TextField(
              controller: detailsController,
              decoration: InputDecoration(labelText: 'รายละเอียด'),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                      controller: locationController,
                      decoration: InputDecoration(labelText: 'สถานที่นัดหมาย')),
                ),
                IconButton(
                  icon: Icon(Icons.map),
                  onPressed: () => _selectLocation(context),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(selectedDate != null
                      ? 'วันที่: ${DateFormat.yMMMd().format(selectedDate!)}'
                      : 'เลือกวันที่'),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(selectedTime != null
                      ? 'เวลา: ${selectedTime!.format(context)}'
                      : 'เลือกเวลา'),
                ),
                IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () => _selectTime(context),
                ),
              ],
            ),
            SizedBox(height: 20),

            // เพิ่ม Switch สำหรับการเปิด/ปิดการแจ้งเตือน
            Row(
              children: [
                Text('เปิดการแจ้งเตือน'),
                Switch(
                  value: isNotificationEnabled,
                  onChanged: (value) {
                    setState(() {
                      isNotificationEnabled = value;
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: 20),
            ElevatedButton(
              child: Text('บันทึก'),
              onPressed: () {
                Navigator.pop(context, {
                  'title': titleController.text,
                  'details': detailsController.text,
                  'date': selectedDate != null
                      ? selectedDate!.toIso8601String()
                      : '',
                  'time': selectedTime != null
                      ? '${selectedTime!.hour}:${selectedTime!.minute}'
                      : '',
                  'location': locationController.text,
                  'latLng': selectedLocation,
                  'completed': widget.task['completed'],
                  'notification':
                      isNotificationEnabled // ส่งสถานะการแจ้งเตือนกลับไป
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LocationPickerScreen extends StatefulWidget {
  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng _initialPosition = LatLng(13.7563, 100.5018); // เริ่มต้นที่กรุงเทพฯ
  LatLng? _pickedLocation;
  TextEditingController locationSearchController = TextEditingController();
  List<dynamic> placeSuggestions = [];

  void _onMapTap(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  Future<void> searchLocation(String query) async {
    final url =
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        placeSuggestions = data;
      });
    } else {
      print('Failed to search location');
    }
  }

  void selectPlace(int index) {
    final selectedPlace = placeSuggestions[index];
    final lat = double.parse(selectedPlace['lat']);
    final lon = double.parse(selectedPlace['lon']);
    setState(() {
      _pickedLocation = LatLng(lat, lon);
      locationSearchController.text = selectedPlace['display_name'];
      placeSuggestions = []; // ล้างคำแนะนำเมื่อเลือกเสร็จแล้ว
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เลือกสถานที่'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _pickedLocation);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: locationSearchController,
              decoration: InputDecoration(
                hintText: 'ค้นหาสถานที่',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  searchLocation(value);
                }
              },
            ),
          ),
          if (placeSuggestions.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: placeSuggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(placeSuggestions[index]['display_name']),
                    onTap: () {
                      selectPlace(index);
                    },
                  );
                },
              ),
            ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 15,
              ),
              onTap: _onMapTap,
              markers: _pickedLocation != null
                  ? {
                      Marker(
                        markerId: MarkerId('selected-location'),
                        position: _pickedLocation!,
                      )
                    }
                  : {},
            ),
          ),
        ],
      ),
    );
  }
}
