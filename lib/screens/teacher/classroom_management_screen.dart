import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../utils/constants.dart';
import 'dart:math';

class ClassroomManagementScreen extends StatefulWidget {
  final int teacherId;
  const ClassroomManagementScreen({super.key, required this.teacherId});

  @override
  State<ClassroomManagementScreen> createState() => _ClassroomManagementScreenState();
}

class _ClassroomManagementScreenState extends State<ClassroomManagementScreen> {
  List<Map<String, dynamic>> _classrooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClassrooms();
  }

  Future<void> _loadClassrooms() async {
    final data = await DatabaseHelper.instance.getTeacherClassrooms(widget.teacherId);
    setState(() {
      _classrooms = data;
      _isLoading = false;
    });
  }

  String _generateClassCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  void _showCreateClassDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController(text: _generateClassCode());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo lớp học mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tên lớp học (VD: Toán 10A1)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: 'Mã lớp học',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => codeController.text = _generateClassCode(),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('HỦY')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && codeController.text.isNotEmpty) {
                await DatabaseHelper.instance.addClassroom(
                  nameController.text,
                  codeController.text,
                  widget.teacherId,
                );
                if (mounted) {
                  Navigator.pop(context);
                  _loadClassrooms();
                }
              }
            },
            child: const Text('TẠO LỚP'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Quản lý lớp học'),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classrooms.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.class_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Bạn chưa có lớp học nào', style: AppTextStyles.bodyLight),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showCreateClassDialog,
              icon: const Icon(Icons.add),
              label: const Text('Tạo lớp ngay'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _classrooms.length,
        itemBuilder: (context, index) {
          final classroom = _classrooms[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.groups, color: AppColors.primary),
              ),
              title: Text(classroom['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Mã lớp: ${classroom['code']}',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã sao chép mã lớp')),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateClassDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}