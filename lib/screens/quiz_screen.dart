import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../data/quiz_data.dart';
import '../utils/constants.dart';
import '../widgets/question_card.dart';
import '../widgets/option_button.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Question> questions;
  int currentIndex = 0;
  List<int?> selectedAnswers = [];
  List<bool> answerStatus = [];
  List<int?> selectedAnswerIndices = []; // Lưu index đáp án đã chọn
  bool showExplanation = false;

  @override
  void initState() {
    super.initState();
    questions = QuizData.getQuestions();
    selectedAnswers = List.filled(questions.length, null);
    answerStatus = List.filled(questions.length, false);
    selectedAnswerIndices = List.filled(questions.length, null);
  }

  void _selectAnswer(int optionIndex) {
    if (selectedAnswers[currentIndex] != null) return;

    setState(() {
      selectedAnswers[currentIndex] = optionIndex;
      selectedAnswerIndices[currentIndex] = optionIndex;
      answerStatus[currentIndex] =
          optionIndex == questions[currentIndex].correctAnswerIndex;
      showExplanation = true;
    });
  }

  void _nextQuestion() {
    if (selectedAnswers[currentIndex] == null) {
      _showSnackBar('Vui lòng chọn đáp án trước khi tiếp tục');
      return;
    }

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        showExplanation = selectedAnswers[currentIndex] != null;
      });
    } else {
      _finishQuiz();
    }
  }

  void _previousQuestion() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        showExplanation = selectedAnswers[currentIndex] != null;
      });
    }
  }

  void _finishQuiz() {
    int score = answerStatus.where((status) => status == true).length;

    // Tạo kết quả với đầy đủ thông tin
    final resultData = {
      'score': score,
      'totalQuestions': questions.length,
      'userAnswers': answerStatus,
      'questions': questions,
      'selectedAnswers': selectedAnswerIndices,
      'completedAt': DateTime.now(),
    };

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(resultData: resultData),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentIndex];
    final selectedAnswer = selectedAnswers[currentIndex];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Bài kiểm tra'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  QuestionCard(
                    questionText: currentQuestion.text,
                    currentIndex: currentIndex + 1,
                    totalQuestions: questions.length,
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(
                    currentQuestion.options.length,
                        (index) => OptionButton(
                      text: currentQuestion.options[index],
                      index: index,
                      isSelected: selectedAnswer == index,
                      isCorrect: index == currentQuestion.correctAnswerIndex,
                      showResult: showExplanation,
                      onTap: () => _selectAnswer(index),
                    ),
                  ),
                  if (showExplanation && selectedAnswer != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: answerStatus[currentIndex]
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: answerStatus[currentIndex]
                                      ? AppColors.success
                                      : AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    answerStatus[currentIndex] ? '✓' : '✗',
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                answerStatus[currentIndex] ? 'Đúng rồi!' : 'Sai rồi!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: answerStatus[currentIndex]
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentQuestion.explanation,
                            style: AppTextStyles.body,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                if (currentIndex > 0)
                  Expanded(
                    child: GestureDetector(
                      onTap: _previousQuestion,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'Câu trước',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (currentIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _nextQuestion,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          currentIndex == questions.length - 1 ? 'Hoàn thành' : 'Câu tiếp',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}