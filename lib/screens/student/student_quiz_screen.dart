import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/quiz_model.dart';
import '../../models/answer_record.dart';
import '../../database/database_helper.dart';
import '../../utils/constants.dart';
import '../../widgets/question_card.dart';
import '../../widgets/option_button.dart';
import 'student_result_screen.dart';

class StudentQuizScreen extends StatefulWidget {
  final User user;
  final bool isPracticeMode;
  final List<Question>? customQuestions;
  final int? quizId; // Added quizId

  const StudentQuizScreen({
    super.key,
    required this.user,
    this.isPracticeMode = false,
    this.customQuestions,
    this.quizId, // Added quizId to constructor
  });

  @override
  State<StudentQuizScreen> createState() => _StudentQuizScreenState();
}

class _StudentQuizScreenState extends State<StudentQuizScreen> {
  List<Question> questions = [];
  int currentIndex = 0;
  List<int?> selectedAnswers = [];
  List<bool> answerStatus = [];
  bool showExplanation = false;
  bool _isLoading = true;

  // Timer logic
  Timer? _timer;
  int _timeLeft = 30; // 30 seconds per question
  int _totalTimeTaken = 0;
  final int _secondsPerQuestion = 30;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    if (widget.customQuestions != null) {
      questions = widget.customQuestions!;
    } else {
      questions = await DatabaseHelper.instance.getAllQuestions();
    }
    
    if (questions.isNotEmpty) {
      selectedAnswers = List.filled(questions.length, null);
      answerStatus = List.filled(questions.length, false);
      _startTimer();
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = _secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
          _totalTimeTaken++;
        } else {
          _timer?.cancel();
          if (selectedAnswers[currentIndex] == null) {
            _selectAnswer(-1); // Auto-fail if time runs out
          }
        }
      });
    });
  }

  void _selectAnswer(int optionIndex) {
    if (selectedAnswers[currentIndex] != null) return;
    _timer?.cancel();

    setState(() {
      selectedAnswers[currentIndex] = optionIndex;
      if (optionIndex != -1) {
        answerStatus[currentIndex] =
            optionIndex == questions[currentIndex].correctAnswerIndex;
      } else {
        answerStatus[currentIndex] = false;
      }
      showExplanation = true;
    });
    
    // In practice mode, if correct, remove from difficult questions
    if (widget.isPracticeMode && answerStatus[currentIndex]) {
      DatabaseHelper.instance.removeFromDifficult(widget.user.id!, questions[currentIndex].id!);
    }
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
        if (!showExplanation) {
          _startTimer();
        }
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    _timer?.cancel();
    int score = answerStatus.where((status) => status == true).length;

    // Create the attempt object with the optional quizId
    final attempt = QuizAttempt(
      studentId: widget.user.id!,
      score: score,
      totalQuestions: questions.length,
      timeTaken: _totalTimeTaken,
      completedAt: DateTime.now(),
      quizId: widget.quizId, // Save the specific quiz ID
    );

    int attemptId = await DatabaseHelper.instance.saveQuizAttempt(attempt);

    List<AnswerRecord> records = [];
    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] != null) {
        records.add(AnswerRecord(
          id: 0,
          attemptId: attemptId,
          questionId: questions[i].id!,
          selectedAnswer: selectedAnswers[i]!,
          isCorrect: answerStatus[i],
        ));
      }
    }

    await DatabaseHelper.instance.saveAnswerRecords(records);
    await DatabaseHelper.instance.checkAndAwardAchievements(widget.user.id!);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StudentResultScreen(
            user: widget.user,
            justCompleted: true,
            attempt: attempt,
            answerStatus: answerStatus,
            questions: questions,
          ),
        ),
      );
    }
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.isPracticeMode ? 'Luyện tập' : 'Làm bài kiểm tra'),
          backgroundColor: AppColors.white,
        ),
        body: const Center(
          child: Text('Không có câu hỏi nào'),
        ),
      );
    }

    final currentQuestion = questions[currentIndex];
    final selectedAnswer = selectedAnswers[currentIndex];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(widget.isPracticeMode ? 'Luyện tập' : 'Làm bài kiểm tra'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '$_timeLeft s',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _timeLeft < 10 ? AppColors.error : AppColors.primary,
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: _timeLeft / _secondsPerQuestion,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              _timeLeft < 10 ? AppColors.error : AppColors.primary,
            ),
          ),
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
                  if (showExplanation) ...[
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
                          Text(
                            answerStatus[currentIndex] ? 'Chính xác!' : 'Chưa đúng!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: answerStatus[currentIndex]
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(currentQuestion.explanation),
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
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      currentIndex == questions.length - 1 ? 'Kết thúc' : 'Câu tiếp theo',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
