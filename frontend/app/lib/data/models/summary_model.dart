class SummaryModel {
  final String summaryId;
  final String title;
  final List<String> keyPoints;
  final String fullSummary;
  final int wordCount;

  const SummaryModel({
    required this.summaryId,
    required this.title,
    required this.keyPoints,
    required this.fullSummary,
    required this.wordCount,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      summaryId: json['summary_id'] as String,
      title: json['title'] as String,
      keyPoints: (json['key_points'] as List<dynamic>).cast<String>(),
      fullSummary: json['full_summary'] as String,
      wordCount: json['word_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary_id': summaryId,
      'title': title,
      'key_points': keyPoints,
      'full_summary': fullSummary,
      'word_count': wordCount,
    };
  }
}
