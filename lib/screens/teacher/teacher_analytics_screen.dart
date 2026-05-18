import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Đảm bảo đã chạy flutter pub get
import '../../database/database_helper.dart';
import '../../utils/constants.dart';

class TeacherAnalyticsScreen extends StatefulWidget {
  final int teacherId;
  const TeacherAnalyticsScreen({super.key, required this.teacherId});

  @override
  State<TeacherAnalyticsScreen> createState() => _TeacherAnalyticsScreenState();
}

class _TeacherAnalyticsScreenState extends State<TeacherAnalyticsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _mostMissed = [];
  List<Map<String, dynamic>> _scoreDistribution = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final missed = await DatabaseHelper.instance.getMostMissedQuestions(widget.teacherId);
    final distribution = await DatabaseHelper.instance.getScoreDistribution(widget.teacherId);

    if (mounted) {
      setState(() {
        _mostMissed = missed;
        _scoreDistribution = distribution;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Phân tích & Thống kê'),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Phổ điểm của học sinh', Icons.bar_chart),
            const SizedBox(height: 12),
            _buildScoreChart(),
            const SizedBox(height: 32),
            _buildSectionHeader('Câu hỏi hay sai nhất', Icons.warning_amber_rounded),
            const SizedBox(height: 12),
            _buildMostMissedList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.heading),
      ],
    );
  }

  Widget _buildScoreChart() {
    if (_scoreDistribution.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text('Chưa có dữ liệu bài làm')),
      );
    }

    // Tìm giá trị cao nhất để thiết lập cột Y
    double maxY = 5;
    for (var item in _scoreDistribution) {
      if ((item['count'] as int).toDouble() > maxY) {
        maxY = (item['count'] as int).toDouble() + 1;
      }
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(10, 25, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), // Sửa lỗi opacity
            blurRadius: 10,
          )
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int idx = value.toInt();
                  if (idx >= 0 && idx < _scoreDistribution.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(_scoreDistribution[idx]['range'], style: const TextStyle(fontSize: 10)),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(_scoreDistribution.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: (_scoreDistribution[index]['count'] as int).toDouble(),
                  color: AppColors.primary,
                  width: 25,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMostMissedList() {
    if (_mostMissed.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        child: const Center(child: Text('Chưa ghi nhận lỗi sai nào', style: AppTextStyles.bodyLight)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _mostMissed.length,
      itemBuilder: (context, index) {
        final item = _mostMissed[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              child: Text('${index + 1}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
            title: Text(item['text'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
            subtitle: Text('Làm sai: ${item['missCount']} lần', style: const TextStyle(color: Colors.red, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ),
        );
      },
    );
  }
}