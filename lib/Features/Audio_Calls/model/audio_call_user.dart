class AudioCallUser {
  final String id;
  final String name;
  final String? avatar;
  final String callStatus; // 'connecting', 'connected', 'disconnected', 'ended'

  AudioCallUser({
    required this.id,
    required this.name,
    this.avatar,
    this.callStatus = 'connecting',
  });

  /// Create a copy of this user with modified fields
  AudioCallUser copyWith({
    String? id,
    String? name,
    String? avatar,
    String? callStatus,
  }) {
    return AudioCallUser(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      callStatus: callStatus ?? this.callStatus,
    );
  }

  @override
  String toString() =>
      'AudioCallUser(id: $id, name: $name, callStatus: $callStatus)';
}
