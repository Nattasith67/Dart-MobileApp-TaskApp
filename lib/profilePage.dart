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
      appBar: AppBar(title: const Text("Profile")),
      body: Center(
        child: _isLoading
          ? const CircularProgressIndicator()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Total Tasks",
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
                Text(
                  "$_totalCount",
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "Pending Tasks",
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
                Text(
                  "$_pendingCount",
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "Completed Tasks",
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
                Text(
                  "$_completedCount",
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.green
                  ),
                ),
              ],
            ),
      ),
    );
  }
}