import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/quiz_model.dart';
import '../../database/database_helper.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';
import 'student_quiz_screen.dart';
import 'student_result_screen.dart';
import 'leaderboard_screen.dart';
import 'achievements_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  final User user;
  const StudentHomeScreen({super.key, required this.user});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _difficultCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDifficultCount();
  }

  Future<void> _loadDifficultCount() async {
    final questions = await DatabaseHelper.instance.getDifficultQuestions(widget.user.id!);
    setState(() {
      _difficultCount = questions.length;
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HỦY'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('ĐĂNG XUẤT', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showJoinClassDialog() {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nhập mã lớp học'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
            hintText: 'Ví dụ: MATH101',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('HỦY')),
          ElevatedButton(
            onPressed: () async {
              final code = codeController.text.trim();
              if (code.isEmpty) return;
              
              final quizzes = await DatabaseHelper.instance.getQuizzesByClass(code);
              
              if (mounted) {
                if (quizzes.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mã lớp không tồn tại hoặc không có đề thi hiện tại')),
                  );
                } else {
                  // Get the most recent quiz for this class
                  final quiz = quizzes.first;
                  final quizId = quiz['id'] as int;
                  
                  // Fetch specific questions for this quiz
                  final quizQuestions = await DatabaseHelper.instance.getQuestionsForQuiz(quizId);
                  
                  if (mounted) {
                    if (quizQuestions.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đề thi này chưa có câu hỏi nào')),
                      );
                      return;
                    }
                    
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentQuizScreen(
                          user: widget.user,
                          customQuestions: quizQuestions,
                          quizId: quizId,
                        ),
                      ),
                    ).then((_) => _loadDifficultCount());
                  }
                }
              }
            },
            child: const Text('VÀO LỚP'),
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
        title: const Text('Học sinh - Trang chủ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events, color: Colors.orange),
            tooltip: 'Thành tựu',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AchievementsScreen(user: widget.user)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            tooltip: 'Đăng xuất',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 24),
            const Text('CHẾ ĐỘ HỌC TẬP', style: AppTextStyles.heading),
            const SizedBox(height: 12),
            _buildFeatureGrid(),
            const SizedBox(height: 24),
            const Text('TIẾN ĐỘ CỦA BẠN', style: AppTextStyles.heading),
            const SizedBox(height: 12),
            _buildProgressCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chào mừng, ${widget.user.fullName}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Hôm nay bạn muốn học gì?',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildFeatureItem('Làm bài mới', Icons.quiz, Colors.blue, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => StudentQuizScreen(user: widget.user)),
          ).then((_) => _loadDifficultCount());
        }),
        _buildFeatureItem('Vào lớp (Mã)', Icons.meeting_room, Colors.teal, _showJoinClassDialog),
        _buildFeatureItem('Luyện tập ($_difficultCount)', Icons.psychology, Colors.orange, () async {
          final questions = await DatabaseHelper.instance.getDifficultQuestions(widget.user.id!);
          if (questions.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bạn chưa có câu hỏi khó nào!')),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentQuizScreen(
                  user: widget.user,
                  isPracticeMode: true,
                  customQuestions: questions,
                ),
              ),
            ).then((_) => _loadDifficultCount());
          }
        }),
        _buildFeatureItem('Bảng xếp hạng', Icons.leaderboard, Colors.green, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
          );
        }),
        _buildFeatureItem('Lịch sử', Icons.history, Colors.purple, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => StudentResultScreen(user: widget.user)),
          );
        }),
      ],
    );
  }

  Widget _buildFeatureItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Câu hỏi đã sai'),
              Text(
                '$_difficultCount câu',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _difficultCount > 0 ? 0.3 : 1.0,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _difficultCount > 10 ? Colors.red : Colors.orange,
            ),
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}
