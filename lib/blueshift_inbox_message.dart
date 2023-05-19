class BlueshiftInboxMessage {
  final int? id; // ID in local DB
  final String? messageId;
  final String? displayOn;
  final String? trigger;
  final String? messageType;
  final String? scope;
  final Map? data;
  final DateTime? createdAt;
  String? status;

  BlueshiftInboxMessage(
      {this.id,
      this.messageId,
      this.displayOn,
      this.trigger,
      this.messageType,
      this.scope,
      this.status,
      this.data,
      this.createdAt});

  BlueshiftInboxMessage.fromJson(Map data)
      : this(
          id: data["id"],
          messageId: data["messageId"],
          displayOn: data["displayOn"],
          trigger: data["trigger"],
          messageType: data["messageType"],
          scope: data["scope"],
          data: data["data"],
          status: data["status"],
          createdAt: DateTime.fromMicrosecondsSinceEpoch(
              (data["createdAt"] as int) * 1000000),
        );

  Map<String, dynamic> toMap() {
    int? ms = createdAt?.millisecondsSinceEpoch;
    double sec = ms! / 1000;

    return {
      'id': id,
      'messageId': messageId,
      'displayOn': displayOn,
      'trigger': trigger,
      'messageType': messageType,
      'scope': scope,
      'data': data,
      'status': status,
      'createdAt': sec,
    };
  }
}
