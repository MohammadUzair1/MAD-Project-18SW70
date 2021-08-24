import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  UserModel? userModel;
  Timestamp? addedOn;
  String? message;
  String? senderId;
  bool? unread;
  Timestamp? lastMessageAdded;

  Contact({
    this.userModel,
    this.addedOn,
    this.message,
    this.senderId,
    this.unread,
    this.lastMessageAdded,
  });

  Map toMap(Contact contact) {
    var data = Map<String, dynamic>();
    data['user_contact'] = contact.userModel!.toMap(contact.userModel!);
    data['added_on'] = contact.addedOn;
    data['message'] = contact.message;
    data['sender_id'] = contact.senderId;
    data['unread'] = contact.unread;
    data['last_message_added'] = contact.lastMessageAdded;
    return data;
  }

  Contact.fromMap(Map<String, dynamic> mapData) {
    this.userModel = UserModel.fromMap(mapData['user_contact']);
    this.addedOn = mapData["added_on"];
    this.message = mapData["message"];
    this.senderId = mapData["sender_id"];
    this.unread = mapData["unread"];
    this.lastMessageAdded = mapData["last_message_added"];
  }
}
