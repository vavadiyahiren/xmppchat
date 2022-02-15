class Queue {
  String _id;
  String _messageId;
  int _lastAttempted;

  Queue(this._id, this._messageId, this._lastAttempted);

  String get id => _id;

  String get messageId => _messageId;

  int get lastAttempted => _lastAttempted;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = _id;
    map["messageid"] = _messageId;
    map['lastAttempted'] = _lastAttempted;
    return map;
  }

  void setMesssageId(String messageId) {
    this._messageId = messageId;
  }

  void setIndex(String id) {
    this._id = id;
  }

  void setLastAttempted(int lastAttempted) {
    this._lastAttempted = lastAttempted;
  }

  @override
  String toString() {
    return "{ id : $id , message : $messageId , lastAttempted : $lastAttempted}";
  }
}
