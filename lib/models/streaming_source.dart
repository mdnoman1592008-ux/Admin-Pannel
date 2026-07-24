enum StreamingProvider {
  dailymotion,
  youtube,
  mp4,
  hls,
  dash,
  vimeo,
  custom,
}

enum StreamingSourceStatus {
  active,
  backup,
  disabled,
}

class StreamingSource {
  final String id;
  final StreamingProvider provider;
  final String urlOrId;
  final int priority;
  final String qualityLabel;
  final StreamingSourceStatus status;
  final bool isValidated;

  const StreamingSource({
    required this.id,
    required this.provider,
    required this.urlOrId,
    required this.priority,
    this.qualityLabel = '1080p Full HD',
    this.status = StreamingSourceStatus.active,
    this.isValidated = true,
  });

  String get providerDisplayName {
    switch (provider) {
      case StreamingProvider.dailymotion:
        return 'Dailymotion 4K';
      case StreamingProvider.youtube:
        return 'YouTube Premium HD';
      case StreamingProvider.hls:
        return 'HLS Stream (.m3u8)';
      case StreamingProvider.mp4:
        return 'Direct MP4 Ultra';
      case StreamingProvider.dash:
        return 'MPEG-DASH (.mpd)';
      case StreamingProvider.vimeo:
        return 'Vimeo Pro';
      case StreamingProvider.custom:
        return 'Custom Embed CDN';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'provider': provider.name,
      'urlOrId': urlOrId,
      'priority': priority,
      'qualityLabel': qualityLabel,
      'status': status.name,
      'isValidated': isValidated,
    };
  }

  factory StreamingSource.fromMap(Map<String, dynamic> map, String docId) {
    return StreamingSource(
      id: docId,
      provider: StreamingProvider.values.firstWhere(
        (p) => p.name == map['provider'],
        orElse: () => StreamingProvider.dailymotion,
      ),
      urlOrId: map['urlOrId'] ?? '',
      priority: map['priority'] ?? 1,
      qualityLabel: map['qualityLabel'] ?? '1080p Full HD',
      status: StreamingSourceStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => StreamingSourceStatus.active,
      ),
      isValidated: map['isValidated'] ?? true,
    );
  }
}
