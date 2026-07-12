class Score {
  Score({
    required this.id,
    required this.title,
    required this.format,
    required this.fileUrl,
    this.composer,
    this.keySignature,
  });

  final String id;
  final String title;
  final String format; // musicxml | pdf
  final String fileUrl;
  final String? composer;
  final String? keySignature;

  bool get isMusicXml => format == 'musicxml';

  factory Score.fromJson(Map<String, dynamic> j) => Score(
        id: j['id'] as String,
        title: j['title'] as String,
        format: j['format'] as String,
        fileUrl: j['file_url'] as String,
        composer: j['composer'] as String?,
        keySignature: j['key_signature'] as String?,
      );
}
