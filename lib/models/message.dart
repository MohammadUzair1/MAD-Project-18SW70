import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String? messageId;
  String? senderId;
  String? receiverId;
  String? type;
  String? message;
  Timestamp? timestamp;
  String? photoUrl;
  bool? isFavorite;
  bool? unread;
  String? voiceUrl;

  Message({
    this.messageId,
    this.senderId,
    this.receiverId,
    this.type,
    this.message,
    this.timestamp,
    this.isFavorite,
    this.unread,
  });

  // Will be only called when you wish to send an image
  Message.imageMessage({
    this.messageId,
    this.senderId,
    this.receiverId,
    this.message,
    this.type,
    this.timestamp,
    this.photoUrl,
    this.isFavorite,
    this.unread,
  });

  // Will be only called when you wish to send an voice
  Message.voiceMessage({
    this.messageId,
    this.senderId,
    this.receiverId,
    this.message,
    this.type,
    this.timestamp,
    this.voiceUrl,
    this.isFavorite,
    this.unread,
  });

  Map toMap() {
    var map = Map<String, dynamic>();
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['message'] = this.message;
    map['timestamp'] = this.timestamp;
    map['isFavorite'] = this.isFavorite;
    map['unread'] = this.unread;
    return map;
  }

  Map toImageMap() {
    var map = Map<String, dynamic>();
    map['message'] = this.message;
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['timestamp'] = this.timestamp;
    map['photoUrl'] = this.photoUrl;
    map['isFavorite'] = this.isFavorite;
    map['unread'] = this.unread;
    return map;
  }

  Map toVoiceMap() {
    var map = Map<String, dynamic>();
    map['message'] = this.message;
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['timestamp'] = this.timestamp;
    map['voiceUrl'] = this.voiceUrl;
    map['isFavorite'] = this.isFavorite;
    map['unread'] = this.unread;
    return map;
  }

  Message.fromMap(Map<String, dynamic> map) {
    this.senderId = map['senderId'];
    this.receiverId = map['receiverId'];
    this.type = map['type'];
    this.message = map['message'];
    this.timestamp = map['timestamp'];
    this.photoUrl = map['photoUrl'];
    this.voiceUrl = map['voiceUrl'];
    this.isFavorite = map['isFavorite'];
    this.unread = map['unread'];
  }
}
