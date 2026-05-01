import 'package:dart_project_tasks/calendar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState(){
    return _AddTaskPageState();
  } 
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  DateTime? _selectedDate;

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

  Future<void> _createTask() async {
    if (_selectedDate == null || _nameController.text.isEmpty) {
      _showSnackbar("กรุณากรอกข้อมูลให้ครบถ้วน");
      return;
    }

    final url = Uri.parse('https://my-api-dart.vercel.app/list');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'name': _nameController.text,
      'date': "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
      'status': 'pending',
      'category': _typeController.text,
    });
    
    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonDecode(response.body);
        _showSnackbar("สร้างกิจกรรมสำเร็จ");
        Navigator.pushReplacement(
          context, MaterialPageRoute(
            builder: (context) => const Calendar())
          );
      }
    } catch (e) {
      _showSnackbar("บันทึกกิจกรรมไม่สำเร็จ ข้อผิดพลาด: $e");
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
        title: const Text('เพิ่มกิจกรรม'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'ใส่กิจกรรมของคุณ',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),
            
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'เลือกวันที่',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectDate,
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'ประเภทกิจกรรม',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            TextButton(
              onPressed: _createTask,
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
              ),
              child: const Text('เพิ่ม'),
            ),
          ],
        ),
      ),
    );
  }
}