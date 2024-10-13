import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'TaskDetailScreen.dart';
import 'Login_Screen.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> filteredTasks = [];
  List<Map<String, dynamic>> todayNotifications = [];

  String searchText = '';
  String? dailyQuote;
  bool isLoadingQuote = false;

  @override
  void initState() {
    super.initState();
    filteredTasks = tasks;
    fetchDailyQuote();
    checkForTodayNotifications(); // ตรวจสอบการแจ้งเตือนวันนี้
  }

  Future<void> fetchDailyQuote() async {
    setState(() {
      isLoadingQuote = true;
    });
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:3000/randomquote'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final randomQuote = data[0];
        setState(() {
          dailyQuote = '${randomQuote['q']} - ${randomQuote['a']}';
          isLoadingQuote = false;
        });
      } else {
        setState(() {
          dailyQuote = 'ไม่สามารถดึงคำคมได้';
          isLoadingQuote = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        dailyQuote = 'เกิดข้อผิดพลาดในการดึงคำคม';
        isLoadingQuote = false;
      });
    }
  }

  void updateSearch(String query) {
    setState(() {
      searchText = query;
      filteredTasks = tasks
          .where((task) =>
              task['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      updateSearch(searchText);
      checkForTodayNotifications();
    });
  }

  void toggleCompleted(int index, bool? value) {
    setState(() {
      tasks[index]['completed'] = value!;
    });
  }

  void _openMap(String? location) async {
    if (location != null && location.isNotEmpty) {
      final url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$location');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่มีพิกัดสำหรับสถานที่นี้')),
      );
    }
  }

  void checkForTodayNotifications() {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    setState(() {
      todayNotifications = tasks.where((task) {
        return task['date'] == today && task['notification'] == true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          child: TextField(
            onChanged: updateSearch,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.black),
              hintText: 'Search',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.blue),
              ),
              contentPadding: EdgeInsets.all(10),
            ),
            style: TextStyle(color: Colors.black),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 226, 188, 215),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 12),
          if (isLoadingQuote)
            Center(child: CircularProgressIndicator())
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  dailyQuote ?? 'ไม่มีคำคมในวันนี้',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'List',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            height: 130,
            child: ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Checkbox(
                    value: filteredTasks[index]['completed'],
                    onChanged: (value) {
                      toggleCompleted(index, value);
                    },
                  ),
                  title: Text(filteredTasks[index]['title']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskDetailScreen(
                                task: tasks[index],
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              tasks[index] = result;
                              updateSearch(searchText);
                              checkForTodayNotifications();
                            });
                          }
                        },
                      ),
                      if (tasks[index]['location'] != null &&
                          tasks[index]['location'].isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.map),
                          onPressed: () {
                            _openMap(tasks[index]['location']);
                          },
                        ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteTask(index);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Notification',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            height: 170,
            child: ListView.builder(
              itemCount: todayNotifications.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Checkbox(
                    value: todayNotifications[index]['completed'],
                    onChanged: (value) {
                      toggleCompleted(index, value);
                    },
                  ),
                  title: Text(todayNotifications[index]['title']),
                  subtitle:
                      Text('วันที่: ${todayNotifications[index]['date']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskDetailScreen(
                                task: todayNotifications[index],
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              tasks[index] = result;
                              updateSearch(searchText);
                              checkForTodayNotifications();
                            });
                          }
                        },
                      ),
                      if (todayNotifications[index]['location'] != null &&
                          todayNotifications[index]['location'].isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.map),
                          onPressed: () {
                            _openMap(todayNotifications[index]['location']);
                          },
                        ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteTask(index);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink[200],
        child: Icon(Icons.add),
        onPressed: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(
                task: {
                  'title': '',
                  'details': '',
                  'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  'time': '',
                  'location': '',
                  'latLng': null,
                  'completed': false,
                  'notification': true
                },
              ),
            ),
          );
          if (result != null) {
            setState(() {
              tasks.add(result);
              updateSearch(searchText);
              checkForTodayNotifications();
            });
          }
        },
      ),
    );
  }
}
