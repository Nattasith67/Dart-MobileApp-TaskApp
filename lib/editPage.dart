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
        title: const Text('แก้ไขกิจกรรม'),
        centerTitle: true,
        elevation: 0,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'แก้ไขกิจกรรม',
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
                          onPressed: _updateTask,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'บันทึกการแก้ไข',
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