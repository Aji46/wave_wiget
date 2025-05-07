class TranscriptionSegment {
  final String startTime;
  final String endTime;
  final String text;

  TranscriptionSegment({
    required this.startTime,
    required this.endTime,
    required this.text,
  });

  factory TranscriptionSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptionSegment(
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'text': text,
    };
  }
} 