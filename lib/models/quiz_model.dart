class Question {
  final int? id;
  final String text;
  final String option1;
  final String option2;
  final String option3;
  final String option4;
  final int correctAnswerIndex;
  final String explanation;
  final int createdBy;

  Question({
    this.id,
    required this.text,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.createdBy,
  });

  List<String> get options => [option1, option2, option3, option4];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'option1': option1,
      'option2': option2,
      'option3': option3,
      'option4': option4,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'createdBy': createdBy,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      text: map['text'],
      option1: map['option1'],
      option2: map['option2'],
      option3: map['option3'],
      option4: map['option4'],
      correctAnswerIndex: map['correctAnswerIndex'],
      explanation: map['explanation'],
      createdBy: map['createdBy'],
    );
  }
}

class QuizAttempt {
  final int? id;
  final int studentId;
  final int score;
  final int totalQuestions;
  final int timeTaken; // In seconds
  final DateTime completedAt;
  final int? quizId; // Added quizId

  QuizAttempt({
    this.id,
    required this.studentId,
    required this.score,
    required this.totalQuestions,
    required this.timeTaken,
    required this.completedAt,
    this.quizId,
  });

  double get percentage => (score / totalQuestions) * 100;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'score': score,
      'totalQuestions': totalQuestions,
      'timeTaken': timeTaken,
      'completedAt': completedAt.toIso8601String(),
      'quizId': quizId,
    };
  }

  factory QuizAttempt.fromMap(Map<String, dynamic> map) {
    return QuizAttempt(
      id: map['id'],
      studentId: map['studentId'],
      score: map['score'],
      totalQuestions: map['totalQuestions'],
      timeTaken: map['timeTaken'] ?? 0,
      completedAt: DateTime.parse(map['completedAt']),
      quizId: map['quizId'],
    );
  }
}
