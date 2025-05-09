class TranscriptionSegment {
  final String startTime;
  final String endTime;
  final String transcriptText;

  TranscriptionSegment({
    required this.startTime,
    required this.endTime,
    required this.transcriptText,
  });

  factory TranscriptionSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptionSegment(
      startTime: json['startTime'],
      endTime: json['endTime'],
      transcriptText: json['transcriptText'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'transcriptText': transcriptText,
    };
  }
}

class AudioTranscription {
  final String guid;
  final String fileName;
  final DateTime receivedAt;
  final DateTime convertedAt;
  final String transcription;
  final String folderPath;
  final String? type;
  final String status;
  final List<TranscriptionSegment> srtSegments;

  AudioTranscription({
    required this.guid,
    required this.fileName,
    required this.receivedAt,
    required this.convertedAt,
    required this.transcription,
    required this.folderPath,
    required this.type,
    required this.status,
    required this.srtSegments,
  });

  factory AudioTranscription.fromJson(Map<String, dynamic> json) {
    return AudioTranscription(
      guid: json['guid'],
      fileName: json['fileName'],
      receivedAt: DateTime.parse(json['receivedAt']),
      convertedAt: DateTime.parse(json['convertedAt']),
      transcription: json['transcription'],
      folderPath: json['folderPath'],
      type: json['type'],
      status: json['status'],
      srtSegments: (json['srtSegments'] as List)
          .map((segment) => TranscriptionSegment.fromJson(segment))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guid': guid,
      'fileName': fileName,
      'receivedAt': receivedAt.toIso8601String(),
      'convertedAt': convertedAt.toIso8601String(),
      'transcription': transcription,
      'folderPath': folderPath,
      'type': type,
      'status': status,
      'srtSegments': srtSegments.map((segment) => segment.toJson()).toList(),
    };
  }
}
