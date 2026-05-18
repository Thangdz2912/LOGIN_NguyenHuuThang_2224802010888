import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../admin/user_list_screen.dart';
import 'manage_questions_screen.dart';
import 'view_results_screen.dart';
import 'classroom_management_screen.dart';
import 'teacher_analytics_screen.dart';
import 'schedule_quiz_screen.dart';
import '../auth/login_screen.dart';

class TeacherHomeScreen extends StatelessWidget {
  final User user;

  const TeacherHomeScreen({super.key, required this.user});

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('HỦY')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Giáo viên - Quản trị', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: AppColors.error),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTeacherHeader(),
            const SizedBox(height: 24),
            const Text('HỆ THỐNG QUẢN LÝ', style: AppTextStyles.heading),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                _buildFeatureItem(
                  context, 'Câu hỏi', 'Ngân hàng đề', Icons.library_books, Colors.blue,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManageQuestionsScreen(teacherId: user.id!))),
                ),
                _buildFeatureItem(
                  context, 'Lớp học', 'Mã lớp & SV', Icons.class_outlined, Colors.orange,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClassroomManagementScreen(teacherId: user.id!))),
                ),
                _buildFeatureItem(
                  context, 'Lên lịch', 'Hẹn giờ thi', Icons.timer_outlined, Colors.green,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => ScheduleQuizScreen(teacherId: user.id!))),
                ),
                _buildFeatureItem(
                  context, 'Kết quả', 'Điểm số học sinh', Icons.assessment, Colors.amber,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewResultsScreen())),
                ),
                _buildFeatureItem(
                  context, 'Thống kê', 'Phân tích lỗi', Icons.analytics_outlined, Colors.purple,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherAnalyticsScreen(teacherId: user.id!))),
                ),
                _buildFeatureItem(
                  context, 'Người dùng', 'Quản lý Account', Icons.people_alt_outlined, Colors.red,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserListScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chào mừng,',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                  ),
                  Text(
                    user.fullName,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '👨‍🏫 Quản lý lớp học & Giảng dạy',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
