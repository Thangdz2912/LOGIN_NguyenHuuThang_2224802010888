import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/quiz_model.dart';
import '../../database/database_helper.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';

class StudentResultScreen extends StatefulWidget {
  final User user;
  final bool justCompleted;
  final QuizAttempt? attempt;
  final List<bool>? answerStatus;
  final List<Question>? questions;

  const StudentResultScreen({
    super.key,
    required this.user,
    this.justCompleted = false,
    this.attempt,
    this.answerStatus,
    this.questions,
  });

  @override
  State<StudentResultScreen> createState() => _StudentResultScreenState();
}

class _StudentResultScreenState extends State<StudentResultScreen> {
  List<QuizAttempt> _attempts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttempts();
  }

  Future<void> _loadAttempts() async {
    final attempts = await DatabaseHelper.instance.getStudentAttempts(widget.user.id!);
    setState(() {
      _attempts = attempts;
      _isLoading = false;
    });
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.justCompleted && widget.attempt != null) {
      return _buildAnalysisView();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Lịch sử bài làm'),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout, color: AppColors.error)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _attempts.isEmpty
          ? const Center(child: Text('Chưa có lịch sử làm bài', style: AppTextStyles.bodyLight))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _attempts.length,
        itemBuilder: (context, index) => _buildHistoryCard(_attempts[index], _attempts.length - index),
      ),
    );
  }

  Widget _buildAnalysisView() {
    final correct = widget.attempt!.score;
    final total = widget.attempt!.totalQuestions;
    final wrong = total - correct;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Phân tích kết quả'), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildScoreSummary(correct, wrong, total),
            const SizedBox(height: 24),
            const Align(alignment: Alignment.centerLeft, child: Text('CHI TIẾT CÂU HỎI', style: AppTextStyles.heading)),
            const SizedBox(height: 12),
            if (widget.questions != null)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.questions!.length,
                itemBuilder: (context, index) => _buildQuestionDetail(index),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.all(16)),
                child: const Text('QUAY LẠI TRANG CHỦ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSummary(int correct, int wrong, int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const Text('TỔNG QUAN', style: AppTextStyles.heading),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Đúng', correct, Colors.green),
              _buildStat('Sai', wrong, Colors.red),
              _buildStat('Điểm', '${(correct / total * 100).toInt()}%', AppColors.primary),
            ],
          ),
          const Divider(height: 40),
          Text('Thời gian: ${widget.attempt!.timeTaken} giây', style: AppTextStyles.bodyLight),
        ],
      ),
    );
  }

  Widget _buildStat(String label, dynamic value, Color color) {
    return Column(
      children: [
        Text(value.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: AppTextStyles.bodyLight),
      ],
    );
  }

  Widget _buildQuestionDetail(int index) {
    final q = widget.questions![index];
    final isCorrect = widget.answerStatus![index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: isCorrect ? Colors.green : Colors.red, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Câu ${index + 1}: ${q.text}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Đáp án đúng: ${q.options[q.correctAnswerIndex]}', style: const TextStyle(color: Colors.green)),
          if (q.explanation.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Giải thích: ${q.explanation}', style: AppTextStyles.bodyLight),
          ]
        ],
      ),
    );
  }

  Widget _buildHistoryCard(QuizAttempt attempt, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text('Lần làm thứ $index'),
        subtitle: Text('Đúng ${attempt.score}/${attempt.totalQuestions} - ${attempt.timeTaken}s', style: AppTextStyles.bodyLight),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}