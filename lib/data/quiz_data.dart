import '../models/quiz_model.dart';

class QuizData {
  static List<Question> getQuestions() {
    return [
      Question(
        id: 1,
        text: 'Thủ đô của Việt Nam là gì?',
        option1: 'Hà Nội',
        option2: 'TP. Hồ Chí Minh',
        option3: 'Đà Nẵng',
        option4: 'Hải Phòng',
        correctAnswerIndex: 0,
        explanation: 'Hà Nội là thủ đô của Việt Nam từ năm 1945.',
        createdBy: 1,
      ),
      Question(
        id: 2,
        text: 'Ngôn ngữ lập trình nào được sử dụng để phát triển Flutter?',
        option1: 'Java',
        option2: 'Kotlin',
        option3: 'Dart',
        option4: 'Swift',
        correctAnswerIndex: 2,
        explanation: 'Flutter sử dụng ngôn ngữ Dart do Google phát triển.',
        createdBy: 1,
      ),
      Question(
        id: 3,
        text: 'Đâu không phải là một widget trong Flutter?',
        option1: 'Container',
        option2: 'Row',
        option3: 'Variable',
        option4: 'Column',
        correctAnswerIndex: 2,
        explanation: 'Variable (biến) là một khái niệm trong lập trình, không phải là một UI component (widget) trong Flutter.',
        createdBy: 1,
      ),
    ];
  }
}
