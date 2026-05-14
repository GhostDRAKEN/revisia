class DocumentModel {
  final String documentId;
  final String title;
  final int pageCount;
  final int wordCount;
  final String extractedText;

  const DocumentModel({
    required this.documentId,
    required this.title,
    required this.pageCount,
    required this.wordCount,
    required this.extractedText,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      documentId: json['document_id'] as String,
      title: json['title'] as String,
      pageCount: json['page_count'] as int,
      wordCount: json['word_count'] as int,
      extractedText: json['extracted_text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_id': documentId,
      'title': title,
      'page_count': pageCount,
      'word_count': wordCount,
      'extracted_text': extractedText,
    };
  }
}
