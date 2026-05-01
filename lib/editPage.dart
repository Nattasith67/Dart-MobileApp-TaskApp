import 'package:dart_project_tasks/calendar.dart';
import 'package:dart_project_tasks/profilePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditPage extends StatefulWidget {
  final int id;
  const EditPage({super.key, required this.id});

  @override
  State<StatefulWidget> createState() {
    return _EditPageState();
  }
}

class _EditPageState extends State<EditPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchTask();
  }

  Future<void> _fetchTask() async {
    final url = Uri.parse('https://my-api-dart.vercel.app/list/${widget.id}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final taskData = jsonDecode(response.body)[0];
      _loadUserData(taskData);
    } else {
      _showSnackBar('โหลดข้อมูลไม่สำเร็จ');
    }
  }

  void _loadUserData(Map<String, dynamic> userData) {
    _nameController.text = userData['name'] ?? '';
    _dateController.text = userData['taskdate'] ?? '';
    _typeController.text = userData['category'] ?? '';
    setState(() {});
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _updateTask() async {
    final url = Uri.parse('https://my-api-dart.vercel.app/list/${widget.id}');
    final headers = {'Content-Type': 'application/json'};
    String resultDate = _dateController.text;
    if (_selectedDate != null) {
      resultDate = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
      }
    final body = json.encode({
      'name': _nameController.text,
      'taskdate': resultDate,
      'category': _typeController.text,
    });

    try {
      final response = await http.patch(url, headers: headers, body: body);
      
      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('อัพเดทกิจกรรมเรียบร้อย');
        Navigator.pushReplacement(context, 
        MaterialPageRoute(builder: (context) => const Calendar()));
      } else {
        _showSnackBar('อัพเดทกิจกรรมไม่สำเร็จ ข้อผิดพลาด :  ${response.body}');
      }
    } catch (e) {
      _showSnackBar('อัพเดทข้อมูลลงเซิร์ฟเวอร์ไม่สำเร็จ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Calendar()),
              );
            },
          ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: const InputDecoration(
                labelText: 'Date',
                hintText: 'dd/mm/yyyy',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _updateTask,
                child: const Text('Update Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}