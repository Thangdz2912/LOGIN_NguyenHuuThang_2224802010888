class AnswerRecord {
  final int id;
  final int attemptId;
  final int questionId;
  final int selectedAnswer;
  final bool isCorrect;

  AnswerRecord({
    required this.id,
    required this.attemptId,
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'attemptId': attemptId,
      'questionId': questionId,
      'selectedAnswer': selectedAnswer,
      'isCorrect': isCorrect ? 1 : 0,
    };
  }

  factory AnswerRecord.fromMap(Map<String, dynamic> map) {
    return AnswerRecord(
      id: map['id'],
      attemptId: map['attemptId'],
      questionId: map['questionId'],
      selectedAnswer: map['selectedAnswer'],
      isCorrect: map['isCorrect'] == 1,
    );
  }
}