import 'package:flutter/material.dart';
import '../utils/constants.dart';

class OptionButton extends StatelessWidget {
  final String text;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool showResult;
  final VoidCallback onTap;

  const OptionButton({
    super.key,
    required this.text,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.showResult,
    required this.onTap,
  });

  Color _getBackgroundColor() {
    if (!showResult) {
      return isSelected ? AppColors.primary : AppColors.white;
    }

    if (isSelected && isCorrect) {
      return AppColors.success;
    }

    if (isSelected && !isCorrect) {
      return AppColors.error;
    }

    if (!isSelected && isCorrect) {
      return AppColors.success.withOpacity(0.3);
    }

    return AppColors.white;
  }

  Color _getTextColor() {
    if (!showResult) {
      return isSelected ? AppColors.white : AppColors.textDark;
    }

    if ((isSelected && isCorrect) || (isSelected && !isCorrect)) {
      return AppColors.white;
    }

    if (!isSelected && isCorrect) {
      return AppColors.success;
    }

    return AppColors.textDark;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (!showResult && !isSelected) ? onTap : null,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.grey.shade200,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.white : AppColors.textDark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: _getTextColor(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}