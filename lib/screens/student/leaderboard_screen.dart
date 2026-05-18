import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../utils/constants.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bảng xếp hạng Top 10')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getLeaderboard(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: index < 3 ? Colors.orange : AppColors.primary,
                  child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                ),
                title: Text(item['fullName']),
                subtitle: Text('Tổng điểm: ${item['totalScore']} | Lần làm: ${item['totalAttempts']}'),
                trailing: index == 0 ? const Icon(Icons.emoji_events, color: Colors.orange) : null,
              );
            },
          );
        },
      ),
    );
  }
}