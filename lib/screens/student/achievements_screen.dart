import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';

class AchievementsScreen extends StatefulWidget {
  final User user;
  const AchievementsScreen({super.key, required this.user});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Map<String, dynamic>> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final data = await DatabaseHelper.instance.getUserAchievements(widget.user.id!);
    setState(() {
      _achievements = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Thành tựu & Huy hiệu'),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _achievements.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _achievements.length,
                  itemBuilder: (context, index) {
                    final a = _achievements[index];
                    return _buildAchievementCard(a);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Chưa có huy hiệu nào',
            style: AppTextStyles.heading,
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy tích cực làm bài để nhận thưởng!',
            style: AppTextStyles.bodyLight,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _getBadgeIcon(achievement['badgeCode']),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              achievement['name'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              achievement['description'],
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLight.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getBadgeIcon(String code) {
    IconData icon;
    Color color;
    switch (code) {
      case 'FIRST_QUIZ':
        icon = Icons.star;
        color = Colors.blue;
        break;
      case 'PERFECT_SCORE':
        icon = Icons.workspace_premium;
        color = Colors.amber;
        break;
      case 'FAST_LEARNER':
        icon = Icons.bolt;
        color = Colors.orange;
        break;
      case 'HARD_WORKING':
        icon = Icons.local_fire_department;
        color = Colors.red;
        break;
      default:
        icon = Icons.emoji_events;
        color = Colors.amber;
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 40),
    );
  }
}
