import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/quiz_model.dart';
import '../../utils/constants.dart';

class AddEditQuestionScreen extends StatefulWidget {
  final int teacherId;
  final Question? question;

  const AddEditQuestionScreen({
    super.key,
    required this.teacherId,
    this.question,
  });

  @override
  State<AddEditQuestionScreen> createState() => _AddEditQuestionScreenState();
}

class _AddEditQuestionScreenState extends State<AddEditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  final _option3Controller = TextEditingController();
  final _option4Controller = TextEditingController();
  final _explanationController = TextEditingController();
  int _correctAnswerIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.question != null) {
      _textController.text = widget.question!.text;
      _option1Controller.text = widget.question!.option1;
      _option2Controller.text = widget.question!.option2;
      _option3Controller.text = widget.question!.option3;
      _option4Controller.text = widget.question!.option4;
      _correctAnswerIndex = widget.question!.correctAnswerIndex;
      _explanationController.text = widget.question!.explanation;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    _option4Controller.dispose();
    _explanationController.dispose();
    super.dispose();
  }

  Future<void> _saveQuestion() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final question = Question(
        id: widget.question?.id,
        text: _textController.text,
        option1: _option1Controller.text,
        option2: _option2Controller.text,
        option3: _option3Controller.text,
        option4: _option4Controller.text,
        correctAnswerIndex: _correctAnswerIndex,
        explanation: _explanationController.text,
        createdBy: widget.teacherId,
      );

      if (widget.question == null) {
        await DatabaseHelper.instance.addQuestion(question);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm câu hỏi thành công')),
        );
      } else {
        await DatabaseHelper.instance.updateQuestion(question);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật câu hỏi thành công')),
        );
      }

      setState(() => _isLoading = false);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(widget.question == null ? 'Thêm câu hỏi' : 'Sửa câu hỏi'),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nội dung câu hỏi', style: AppTextStyles.heading),
              const SizedBox(height: 8),
              TextFormField(
                controller: _textController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Nhập nội dung câu hỏi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập nội dung câu hỏi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Các đáp án', style: AppTextStyles.heading),
              const SizedBox(height: 8),
              _buildOptionField('Đáp án A', _option1Controller, 0),
              const SizedBox(height: 12),
              _buildOptionField('Đáp án B', _option2Controller, 1),
              const SizedBox(height: 12),
              _buildOptionField('Đáp án C', _option3Controller, 2),
              const SizedBox(height: 12),
              _buildOptionField('Đáp án D', _option4Controller, 3),
              const SizedBox(height: 20),
              const Text('Giải thích', style: AppTextStyles.heading),
              const SizedBox(height: 8),
              TextFormField(
                controller: _explanationController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Nhập giải thích cho đáp án đúng',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập giải thích';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GestureDetector(
                onTap: _saveQuestion,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      widget.question == null ? 'Thêm câu hỏi' : 'Cập nhật',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionField(String label, TextEditingController controller, int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _correctAnswerIndex == index ? AppColors.success : Colors.grey.shade300,
          width: _correctAnswerIndex == index ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập $label';
                }
                return null;
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _correctAnswerIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _correctAnswerIndex == index ? AppColors.success : Colors.grey.shade200,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                _correctAnswerIndex == index ? 'Đúng' : 'Chọn',
                style: TextStyle(
                  color: _correctAnswerIndex == index ? AppColors.white : AppColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}