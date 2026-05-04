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
    final response = await http.get(Uri.parse('https://my-api-dart.vercel.app/list'));
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
    final response = await http.get(Uri.parse('https://my-api-dart.vercel.app/list/pending'));
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
    final response = await http.get(Uri.parse('https://my-api-dart.vercel.app/list/completed'));
    print('Completed Status: ${response.statusCode}');
    print('Completed Body: ${response.body}');
    if (mounted) {
      setState(() {
        _tasks = json.decode(response.body);
        _filter = 'Completed';
      });
    }
  }

  Future<void> _deleteTasks(dynamic id, int index) async {
    final response = await http.delete(Uri.parse('https://my-api-dart.vercel.app/list/${id.toString()}'));
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
    final url = Uri.parse('https://my-api-dart.vercel.app/list/${id.toString()}/status');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'status': 'Completed'
      });

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
      SnackBar(content: Text(message),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
      ),   
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ปฏิทินกิจกรรม"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFilterButton('ทั้งหมด', 'all', Icons.list, Colors.blue),
                  _buildFilterButton('สิ่งที่ต้องทำ', 'pending', Icons.pending, Colors.orange),
                  _buildFilterButton('เสร็จแล้ว', 'completed', Icons.check_circle, Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'ไม่มีกิจกรรม',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        final bool isCompleted = task['status'] == 'Completed';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isCompleted
                                    ? [Colors.green.shade50, Colors.white]
                                    : [Colors.blue.shade50, Colors.white],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isCompleted ? Colors.green : Colors.blue,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          isCompleted ? Icons.check_circle : Icons.event,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          task['name'] ?? '',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow('สถานะ', task['status'] ?? 'N/A', isCompleted ? Colors.green : Colors.orange),
                                  _buildInfoRow('วันที่', task['taskdate'] ?? 'N/A', Colors.grey),
                                  _buildInfoRow('ประเภท', task['category'] ?? 'N/A', Colors.purple),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (!isCompleted)
                                        _buildActionButton(
                                          Icons.edit,
                                          Colors.blue,
                                          () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditPage(id: task['id']),
                                              ),
                                            );
                                          },
                                        ),
                                      const SizedBox(width: 8),
                                      _buildActionButton(
                                        Icons.delete,
                                        Colors.red,
                                        () => _deleteTasks(task['id'], index),
                                      ),
                                      if (!isCompleted) ...[
                                        const SizedBox(width: 8),
                                        _buildActionButton(
                                          Icons.check_circle_outline,
                                          Colors.green,
                                          () => _completeTask(task['id'], index),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มกิจกรรม'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildFilterButton(String label, String filter, IconData icon, Color color) {
    final isSelected = _filter == filter;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (filter == 'all') {
            _fetchTasks();
          } else if (filter == 'pending') {
            _fetchPendingTasks();
          } else {
            _fetchCompletedTasks();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }
}