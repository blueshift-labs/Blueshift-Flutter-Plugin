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
