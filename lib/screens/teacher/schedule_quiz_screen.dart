import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/database_helper.dart';
import '../../models/quiz_model.dart';
import '../../utils/constants.dart';

class ScheduleQuizScreen extends StatefulWidget {
  final int teacherId;
  const ScheduleQuizScreen({super.key, required this.teacherId});

  @override
  State<ScheduleQuizScreen> createState() => _ScheduleQuizScreenState();
}

class _ScheduleQuizScreenState extends State<ScheduleQuizScreen> {
  final _titleController = TextEditingController();
  String? _selectedClassCode;
  DateTime? _startDate;
  DateTime? _endDate;
  List<Question> _allQuestions = [];
  final List<int> _selectedQuestionIds = [];
  List<Map<String, dynamic>> _classrooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final classes = await DatabaseHelper.instance.getTeacherClassrooms(widget.teacherId);
    final questions = await DatabaseHelper.instance.getAllQuestions();
    setState(() {
      _classrooms = classes;
      _allQuestions = questions;
      _isLoading = false;
    });
  }

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
          if (isStart) _startDate = dt; else _endDate = dt;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Lên lịch kỳ thi'),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCard(
                    title: 'Thông tin kỳ thi',
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Tên đề thi / Kỳ thi',
                            prefixIcon: Icon(Icons.title),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedClassCode,
                          hint: const Text('Chọn lớp học áp dụng'),
                          items: _classrooms.map((c) => DropdownMenuItem(
                            value: c['code'] as String,
                            child: Text('${c['name']} (${c['code']})'),
                          )).toList(),
                          onChanged: (v) => setState(() => _selectedClassCode = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildCard(
                    title: 'Thời gian hiệu lực',
                    child: Column(
                      children: [
                        _buildTimePickerTile(
                          label: 'Thời gian bắt đầu',
                          value: _startDate,
                          icon: Icons.play_circle_outline,
                          onTap: () => _pickDateTime(true),
                        ),
                        const Divider(),
                        _buildTimePickerTile(
                          label: 'Thời gian kết thúc',
                          value: _endDate,
                          icon: Icons.stop_circle_outlined,
                          onTap: () => _pickDateTime(false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Chọn câu hỏi cho đề thi (${_selectedQuestionIds.length})', 
                    style: AppTextStyles.heading),
                  const SizedBox(height: 12),
                  _buildQuestionSelector(),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTimePickerTile({required String label, DateTime? value, required IconData icon, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
      subtitle: Text(
        value == null ? 'Chưa chọn' : DateFormat('dd/MM/yyyy - HH:mm').format(value),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      trailing: const Icon(Icons.calendar_month, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildQuestionSelector() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _allQuestions.length,
      itemBuilder: (context, index) {
        final q = _allQuestions[index];
        final isSelected = _selectedQuestionIds.contains(q.id);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: CheckboxListTile(
            title: Text(q.text, maxLines: 1, overflow: TextOverflow.ellipsis),
            value: isSelected,
            activeColor: AppColors.primary,
            onChanged: (val) {
              setState(() {
                if (val!) {
                  _selectedQuestionIds.add(q.id!);
                } else {
                  _selectedQuestionIds.remove(q.id);
                }
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: AppColors.white),
      child: ElevatedButton(
        onPressed: _submitQuiz,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('XUẤT BẢN ĐỀ THI', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  void _submitQuiz() async {
    if (_titleController.text.isEmpty || _selectedClassCode == null || _selectedQuestionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đủ thông tin và chọn ít nhất 1 câu hỏi')),
      );
      return;
    }
    await DatabaseHelper.instance.addScheduledQuiz(
      _titleController.text,
      _selectedClassCode!,
      _startDate,
      _endDate,
      widget.teacherId,
      _selectedQuestionIds,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lên lịch đề thi thành công!')));
      Navigator.pop(context);
    }
  }
}
