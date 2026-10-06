class BlueshiftInboxMessage {
  final int? id; // ID in local DB
  final String messageId;
  final String title;
  final String details;
  final String imageUrl;
  String status;
  final Map data;
  final DateTime createdAt;
  final String objectId;

  BlueshiftInboxMessage({
    this.id,
    required this.messageId,
    required this.title,
    required this.details,
    required this.imageUrl,
    required this.status,
    required this.data,
    required this.createdAt,
    required this.objectId,
  });

  BlueshiftInboxMessage.fromJson(Map data)
      : this(
          id: data["id"],
          messageId: data["messageId"] ?? "",
          title: data["title"] ?? "",
          details: data["details"] ?? "",
          imageUrl: data["imageUrl"] ?? "",
          status: data["status"] ?? "",
          data: data["data"] ?? {},
          createdAt: DateTime.fromMicrosecondsSinceEpoch(
            (data["createdAt"] as int) * 1000000,
          ),
          objectId: data["objectId"] ?? "",
        );

  /// Returns the custom metadata attached to this message in the campaign,
  /// or `null` if the message carries none.
  ///
  /// ```dart
  /// final metadata = message.getMetaData();
  /// final name = metadata?['name'];
  /// ```
  Map<String, dynamic>? getMetaData() {
    // Android hands over the message's `data` node as is, whereas iOS hands
    // over the whole message payload, which keeps that node under `data`.
    final inner = data['data'];
    final metadata =
        data['metadata'] ?? (inner is Map ? inner['metadata'] : null);

    return metadata is Map ? Map<String, dynamic>.from(metadata) : null;
  }

  Map<String, dynamic> toMap() {
    int ms = createdAt.millisecondsSinceEpoch;
    double sec = ms / 1000;

    return {
      'id': id,
      'messageId': messageId,
      'title': title,
      'details': details,
      'imageUrl': imageUrl,
      'data': data,
      'status': status,
      'createdAt': sec,
      'objectId': objectId,
    };
  }
}
