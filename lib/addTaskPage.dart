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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('เพิ่มกิจกรรม'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'สร้างกิจกรรมใหม่',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      _nameController,
                      'ชื่อกิจกรรม',
                      Icons.title,
                      false,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _dateController,
                      'วันที่',
                      Icons.calendar_today,
                      true,
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _typeController,
                      'ประเภทกิจกรรม',
                      Icons.category,
                      false,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _createTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'เพิ่มกิจกรรม',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool readOnly, {
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}