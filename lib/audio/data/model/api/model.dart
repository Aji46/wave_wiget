class AudioModel {
  final String guid;
  final String fileName;
  final String receivedAt;
  final String convertedAt;
  final String transcription;
  final String folderPath;
  final String? type;
  final String? status;

  AudioModel({
    required this.guid,
    required this.fileName,
    required this.receivedAt,
    required this.convertedAt,
    required this.transcription,
    required this.folderPath,
    this.type,
    this.status,
  });

  factory AudioModel.fromJson(Map<String, dynamic> json) {
    return AudioModel(
      guid: json['guid'] ?? '',
      fileName: json['fileName'] ?? '',
      receivedAt: json['receivedAt'] ?? '',
      convertedAt: json['convertedAt'] ?? '',
      transcription: json['transcription'] ?? '',
      folderPath: json['folderPath'] ?? '',
      type: json['type'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guid': guid,
      'fileName': fileName,
      'receivedAt': receivedAt,
      'convertedAt': convertedAt,
      'transcription': transcription,
      'folderPath': folderPath,
      'type': type,
      'status': status,
    };
  }
}
