class QuizModel {
  final String quizId;
  final String title;
  final int questionCount;
  final List<QuizQuestionModel> quiz;

  const QuizModel({
    required this.quizId,
    required this.title,
    required this.questionCount,
    required this.quiz,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      quizId: json['quiz_id'] as String,
      title: json['title'] as String,
      questionCount: json['question_count'] as int,
      quiz: (json['quiz'] as List<dynamic>)
          .map(
            (item) => QuizQuestionModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quiz_id': quizId,
      'title': title,
      'question_count': questionCount,
      'quiz': quiz.map((question) => question.toJson()).toList(),
    };
  }
}

class QuizQuestionModel {
  final int id;
  final String question;
  final List<String> options;
  final String answer;
  final String explanation;

  const QuizQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id'] as int,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      answer: json['answer'] as String,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'answer': answer,
      'explanation': explanation,
    };
  }
}
