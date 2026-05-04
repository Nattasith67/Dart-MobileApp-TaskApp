import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() {
    return _ProfilePageState();
  } 
}

class _ProfilePageState extends State<ProfilePage> {
  int _totalCount = 0;
  int _pendingCount = 0;
  int _completedCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTotalCount();
    _fetchPendingTotal();
    _fetchCompletedTotal();
  }

  Future<void> _fetchTotalCount() async {
    try {
      final response = await http.get(Uri.parse('https://my-api-dart.vercel.app/list/count'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _totalCount = data[0]['total'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("โหลดข้อมูลจำนวนทั้งหมดไม่สำเร็จ ข้อผิดพลาด: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchPendingTotal() async {
    try {
      final response = await http.get(Uri.parse('https://my-api-dart.vercel.app/list/pendingCount'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _pendingCount = data[0]['total'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchCompletedTotal() async {
    try {
      final response = await http.get(Uri.parse('https://my-api-dart.vercel.app/list/completedCount'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _completedCount = data[0]['total'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(
                            Icons.person,
                            size: 36,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'ผู้ใช้ของคุณ',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'สรุปงานล่าสุดของคุณ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'ทั้งหมด',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '$_totalCount',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'ยังไม่เสร็จ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '$_pendingCount',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'เสร็จแล้ว',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$_completedCount',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}