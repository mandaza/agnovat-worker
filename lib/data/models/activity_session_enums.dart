/// Participant engagement level during activity session
enum ParticipantEngagement {
  disengaged(1, 'Disengaged', 'Showed little to no interest', '😐'),
  minimal(2, 'Minimal', 'Showed some reluctance or limited participation', '🙁'),
  moderate(3, 'Moderate', 'Participated adequately', '😊'),
  engaged(4, 'Engaged', 'Actively participated with interest', '😄'),
  highlyEngaged(5, 'Highly Engaged', 'Enthusiastically participated throughout', '🤩');

  final int value;
  final String displayName;
  final String description;
  final String emoji;

  const ParticipantEngagement(this.value, this.displayName, this.description, this.emoji);

  static ParticipantEngagement fromValue(int value) {
    return ParticipantEngagement.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ParticipantEngagement.moderate,
    );
  }

  /// Convert to JSON-serializable map
  Map<String, dynamic> toJson() => {
    'value': value,
    'displayName': displayName,
    'description': description,
    'emoji': emoji,
  };
}

/// Client mood during the shift
enum ClientMood {
  positive('positive', 'Positive', '😊'),
  neutral('neutral', 'Neutral', '😐'),
  negative('negative', 'Negative', '😞'),
  mixed('mixed', 'Mixed', '😕'),
  anxious('anxious', 'Anxious', '😰'),
  withdrawn('withdrawn', 'Withdrawn', '😶');

  final String value;
  final String displayName;
  final String emoji;

  const ClientMood(this.value, this.displayName, this.emoji);

  static ClientMood fromString(String value) {
    return ClientMood.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ClientMood.neutral,
    );
  }

  /// Convert to JSON-serializable map
  Map<String, dynamic> toJson() => {
    'value': value,
    'displayName': displayName,
    'emoji': emoji,
  };
}

/// Sync status for offline-first implementation
enum SyncStatus {
  pending('pending', 'Pending sync', '⏳'),
  syncing('syncing', 'Syncing...', '🔄'),
  synced('synced', 'Synced', '✅'),
  failed('failed', 'Sync failed', '❌');

  final String value;
  final String displayName;
  final String emoji;

  const SyncStatus(this.value, this.displayName, this.emoji);

  static SyncStatus fromString(String value) {
    return SyncStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SyncStatus.pending,
    );
  }

  /// Convert to JSON-serializable map
  Map<String, dynamic> toJson() => {
    'value': value,
    'displayName': displayName,
    'emoji': emoji,
  };
}
