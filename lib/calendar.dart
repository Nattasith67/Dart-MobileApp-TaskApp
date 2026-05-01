import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    _fetchTasks();
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
      duration: const Duration(seconds: 2),
      ),   
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar"),
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
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: _fetchTasks,
                child: Text('ทั้งหมด', style: TextStyle(color: _filter == 'all' ? Colors.blue : Colors.grey)),
              ),
              TextButton(
                onPressed: _fetchPendingTasks,
                child: Text('สิ่งที่ต้องทำ', style: TextStyle(color: _filter == 'pending' ? Colors.blue : Colors.grey)),
              ),
              TextButton(
                onPressed: _fetchCompletedTasks,
                child: Text('Completed', style: TextStyle(color: _filter == 'completed' ? Colors.blue : Colors.grey)),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                final bool isCompleted = task['status'] == 'Completed';

                return ListTile(
                  isThreeLine: true,
                  title: Text(
                    task['name'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Status: ${task['status']}", style: TextStyle(color: isCompleted ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
                      Text("Task Date: ${task['taskdate']}"),
                      Text("Create At : ${task['createDate'] ?? 'N/A'}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Text("Update At : ${task['updateDate'] ?? 'N/A'}"),
                      Text("ประเภทงาน : ${task['category'] ?? ''}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isCompleted)
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditPage(id: task['id']),
                              ),
                            );
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTasks(task['id'], index),
                      ),
                      if (!isCompleted)
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                          onPressed: () => _completeTask(task['id'], index),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}