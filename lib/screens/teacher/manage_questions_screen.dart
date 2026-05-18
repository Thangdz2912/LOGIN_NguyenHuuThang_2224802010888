import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../../database/database_helper.dart';
import '../../models/quiz_model.dart';
import '../../utils/constants.dart';
import 'add_edit_question_screen.dart';

class ManageQuestionsScreen extends StatefulWidget {
  final int teacherId;

  const ManageQuestionsScreen({super.key, required this.teacherId});

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  List<Question> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    final questions = await DatabaseHelper.instance.getAllQuestions();
    setState(() {
      _questions = questions;
      _isLoading = false;
    });
  }

  Future<void> _importExcel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        setState(() => _isLoading = true);
        var bytes = File(result.files.single.path!).readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        int count = 0;
        for (var table in excel.tables.keys) {
          var sheet = excel.tables[table];
          if (sheet == null) continue;

          // Skip header row
          for (int i = 1; i < sheet.maxRows; i++) {
            var row = sheet.rows[i];
            if (row.length < 6) continue;

            final question = Question(
              text: row[0]?.value?.toString() ?? '',
              option1: row[1]?.value?.toString() ?? '',
              option2: row[2]?.value?.toString() ?? '',
              option3: row[3]?.value?.toString() ?? '',
              option4: row[4]?.value?.toString() ?? '',
              correctAnswerIndex: int.tryParse(row[5]?.value?.toString() ?? '0') ?? 0,
              explanation: row.length > 6 ? (row[6]?.value?.toString() ?? '') : '',
              createdBy: widget.teacherId,
            );

            if (question.text.isNotEmpty) {
              await DatabaseHelper.instance.addQuestion(question);
              count++;
            }
          }
        }
        
        await _loadQuestions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã nhập thành công $count câu hỏi')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi nhập file: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteQuestion(Question question) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa câu hỏi: "${question.text}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteQuestion(question.id!);
      await _loadQuestions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa câu hỏi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Quản lý câu hỏi'),
        backgroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AppColors.primary),
            onPressed: _importExcel,
            tooltip: 'Nhập từ Excel',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeaderActions(),
                Expanded(child: _buildQuestionList()),
              ],
            ),
    );
  }

  Widget _buildHeaderActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditQuestionScreen(teacherId: widget.teacherId),
                  ),
                );
                if (result == true) _loadQuestions();
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm câu hỏi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: _importExcel,
            icon: const Icon(Icons.upload_file),
            label: const Text('Nhập Excel'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionList() {
    if (_questions.isEmpty) {
      return const Center(child: Text('Chưa có câu hỏi nào', style: AppTextStyles.bodyLight));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        final q = _questions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Text('Câu ${index + 1}: ${q.text}', 
                style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text('Đáp án: ${String.fromCharCode(65 + q.correctAnswerIndex)}', 
                style: const TextStyle(color: AppColors.primary, fontSize: 12)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...List.generate(4, (i) => _buildOptionView(i, q.options[i], i == q.correctAnswerIndex)),
                    const Divider(),
                    Text('Giải thích: ${q.explanation}', style: AppTextStyles.bodyLight),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddEditQuestionScreen(teacherId: widget.teacherId, question: q),
                              ),
                            );
                            if (result == true) _loadQuestions();
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Sửa'),
                        ),
                        TextButton.icon(
                          onPressed: () => _deleteQuestion(q),
                          icon: const Icon(Icons.delete, size: 18, color: AppColors.error),
                          label: const Text('Xóa', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionView(int index, String text, bool isCorrect) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCorrect ? AppColors.success : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(String.fromCharCode(65 + index), 
                style: TextStyle(color: isCorrect ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: isCorrect ? AppColors.success : Colors.black87))),
        ],
      ),
    );
  }
}
