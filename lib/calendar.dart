import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:dart_project_tasks/addTaskPage.dart';
import 'package:dart_project_tasks/editPage.dart';
import 'package:dart_project_tasks/profilePage.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() {
    return ListScreenState();
  }
}

class ListScreenState extends State<Calendar> {
  List<dynamic> _tasks = [];
  String _filter = 'all';
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _checkDailyTasks();
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  void _checkDailyTasks() {
    _notificationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      _showDueTaskNotifications();
    });
    _showDueTaskNotifications();
  }

  void _showDueTaskNotifications() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var task in _tasks) {
      if (task['status'] == 'Completed') continue;

      final taskDateStr = task['taskdate'];
      if (taskDateStr == null) continue;

      try {
        final taskDate = DateTime.parse(taskDateStr);
        final taskDay = DateTime(taskDate.year, taskDate.month, taskDate.day);

        if (taskDay == today) {
          _showTaskNotification(task['name'] ?? 'กิจกรรม');
        }
      } catch (e) {
        print('Error parsing date: $e');
      }
    }
  }

  void _showTaskNotification(String taskName) {
    if (!mounted) return;
    _showSnackbar('วันนี้มีกิจกรรม: $taskName');
  }

  Future<void> _fetchTasks() async {
    final response = await http.get(
      Uri.parse('https://my-api-dart.vercel.app/list'),
    );
    print('All Status: ${response.statusCode}');
    print('All Body: ${response.body}');
    if (mounted) {
      setState(() {
        _tasks = json.decode(response.body);
        _filter = 'all';
      });
    }
  }

  Future<void> _fetchPendingTasks() async {
    final response = await http.get(
      Uri.parse('https://my-api-dart.vercel.app/list/pending'),
    );
    print('Pending Status: ${response.statusCode}');
    print('Pending Body: ${response.body}');
    if (mounted) {
      setState(() {
        _tasks = json.decode(response.body);
        _filter = 'pending';
      });
    }
  }

  Future<void> _fetchCompletedTasks() async {
    final response = await http.get(
      Uri.parse('https://my-api-dart.vercel.app/list/completed'),
    );
    print('Completed Status: ${response.statusCode}');
    print('Completed Body: ${response.body}');
    if (mounted) {
      setState(() {
        _tasks = json.decode(response.body);
        _filter = 'completed';
      });
    }
  }

  Future<void> _deleteTasks(dynamic id, int index) async {
    final response = await http.delete(
      Uri.parse('https://my-api-dart.vercel.app/list/${id.toString()}'),
    );
    print('Delete Status: ${response.statusCode}');
    print('Delete Body: ${response.body}');
    if (response.statusCode == 200) {
      setState(() {
        _tasks.removeAt(index);
      });
      _showSnackbar('ลบกิจกรรมสำเร็จ');
    } else {
      _showSnackbar('ลบกิจกรรมไม่สำเร็จ');
    }
  }

  Future<void> _completeTask(dynamic id, int index) async {
    final url = Uri.parse(
      'https://my-api-dart.vercel.app/list/${id.toString()}/status',
    );
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'status': 'Completed'});

    try {
      final response = await http.patch(url, headers: headers, body: body);
      print('Complete Status: ${response.statusCode}');
      print('Complete Body: ${response.body}');
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonDecode(response.body);
        setState(() {
          _tasks[index]['status'] = 'Completed';
        });
        _showSnackbar("อัพเดทสถานะสำเร็จ");
      } else {
        _showSnackbar("อัพเดทสถานะไม่สำเร็จ: ${response.statusCode}");
      }
    } catch (e) {
      _showSnackbar("อัพเดทสถานะไม่สำเร็จ");
      print(e);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Calendar"),
        elevation: 1,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black87,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            icon: const Icon(Icons.person_4, color: Colors.black87),
            label: const Text('Profile', style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: _filter == 'all'
                        ? Colors.blue.shade50
                        : Colors.transparent,
                    foregroundColor: _filter == 'all'
                        ? Colors.blue.shade800
                        : Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                  onPressed: _fetchTasks,
                  icon: Icon(
                    Icons.list,
                    color: _filter == 'all' ? Colors.blue.shade700 : Colors.grey,
                  ),
                  label: Text(
                    'ทั้งหมด',
                    style: TextStyle(
                      color: _filter == 'all'
                          ? Colors.blue.shade700
                          : Colors.grey.shade700,
                      fontWeight: _filter == 'all'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: _filter == 'pending'
                        ? Colors.yellow.shade100
                        : Colors.transparent,
                    foregroundColor: _filter == 'pending'
                        ? Colors.orange.shade800
                        : Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                  onPressed: _fetchPendingTasks,
                  icon: Icon(
                    Icons.pending,
                    color: _filter == 'pending'
                        ? Colors.orange.shade700
                        : Colors.grey,
                  ),
                  label: Text(
                    'สิ่งที่ต้องทำ',
                    style: TextStyle(
                      color: _filter == 'pending'
                          ? Colors.orange.shade700
                          : Colors.grey.shade700,
                      fontWeight: _filter == 'pending'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: _filter == 'completed'
                        ? Colors.green.shade50
                        : Colors.transparent,
                    foregroundColor: _filter == 'completed'
                        ? Colors.green.shade800
                        : Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                  onPressed: _fetchCompletedTasks,
                  icon: Icon(
                    Icons.check_circle,
                    color: _filter == 'completed' ? Colors.green : Colors.grey,
                  ),
                  label: Text(
                    'เสร็จแล้ว',
                    style: TextStyle(
                      color: _filter == 'completed'
                          ? Colors.green.shade700
                          : Colors.grey.shade700,
                      fontWeight: _filter == 'completed'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                final bool isCompleted = task['status'] == 'Completed';

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 2,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isCompleted
                          ? Colors.green.shade700
                          : Colors.yellow.shade700,
                      width: 1.8,
                    ),
                  ),
                  color: isCompleted ? Colors.green.shade50 : Colors.yellow.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isCompleted)
                              const Icon(
                                Icons.check,
                                color: Colors.green,
                                size: 24,
                              ),
                            if (!isCompleted)
                              const Icon(
                                Icons.work,
                                color: Colors.yellow,
                                size: 24,
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                task['name'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Status: ${task['status']}",
                              style: TextStyle(
                                color: isCompleted
                                    ? Colors.green.shade700
                                    : Colors.yellow.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text("Task Date: ${task['taskdate']}"),
                            const SizedBox(height: 4),
                            Text(
                              "Create At : ${task['createDate'] ?? 'N/A'}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text("Update At : ${task['updateDate'] ?? 'N/A'}"),
                            const SizedBox(height: 2),
                            Text("ประเภทงาน : ${task['category'] ?? ''}"),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!isCompleted)
                              IconButton(
                                splashRadius: 24,
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditPage(id: task['id']),
                                    ),
                                  );
                                },
                              ),
                            IconButton(
                              splashRadius: 24,
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _deleteTasks(task['id'], index),
                            ),
                            if (!isCompleted)
                              IconButton(
                                splashRadius: 24,
                                icon: const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                ),
                                onPressed: () =>
                                    _completeTask(task['id'], index),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskPage()),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('เพิ่มกิจกรรม', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
    );
  }
}
