class BlueshiftInboxMessage {
  final int? id; // ID in local DB
  final String? messageId;
  final String? title;
  final String? detail;
  final String? imageUrl;
  String? status;
  final Map? data;
  final DateTime? createdAt;

  BlueshiftInboxMessage({
    this.id,
    this.messageId,
    this.title,
    this.detail,
    this.imageUrl,
    this.status,
    this.data,
    this.createdAt,
  });

  BlueshiftInboxMessage.fromJson(Map data)
      : this(
          id: data["id"],
          messageId: data["messageId"],
          title: data["title"],
          detail: data["detail"],
          imageUrl: data["imageUrl"],
          status: data["status"],
          data: data["data"],
          createdAt: DateTime.fromMicrosecondsSinceEpoch(
              (data["createdAt"] as int) * 1000000),
        );

  Map<String, dynamic> toMap() {
    int? ms = createdAt?.millisecondsSinceEpoch;
    double sec = ms! / 1000;

    return {
      'id': id,
      'messageId': messageId,
      'title': title,
      'detail': detail,
      'imageUrl': imageUrl,
      'data': data,
      'status': status,
      'createdAt': sec,
    };
  }
}