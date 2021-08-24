import 'dart:io';

import 'package:chat_app/enum/user_state.dart';
import 'package:chat_app/models/contact.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/utilities/constants.dart';
import 'package:chat_app/utilities/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static final CollectionReference _userCollection =
      firestore.collection(USERS_COLLECTION);
  final CollectionReference _messageCollection =
      firestore.collection(MESSAGES_COLLECTION);

  Reference _storageReference = FirebaseStorage.instance.ref();

  User? getCurrentUser() => _auth.currentUser;

  Future<UserModel> getUserDetails() async {
    User? currentUser = getCurrentUser();

    DocumentSnapshot documentSnapshot =
        await _userCollection.doc(currentUser!.uid).get();

    return UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
  }

  Future<UserModel> getUserDetailsById(String uid) async {
    DocumentSnapshot documentSnapshot = await _userCollection.doc(uid).get();
    return UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
  }

  Future<User?> signUp(String email, String password) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    return userCredential.user;
  }

  Future<void> saveUserDataToFirestore(UserModel userModel) async {
    await _userCollection.doc(userModel.uid).set(userModel.toMap(userModel));
  }

  Future<User?> login(String email, String password) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return userCredential.user;
  }

  Future<User> googleLogin() async {
    GoogleSignInAccount? _signInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication _signInAuthentication =
        await _signInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: _signInAuthentication.accessToken,
      idToken: _signInAuthentication.idToken,
    );

    UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    return userCredential.user!;
  }

  Future<bool> authenticateUser(User user) async {
    QuerySnapshot result =
        await _userCollection.where('email', isEqualTo: user.email).get();

    final List<DocumentSnapshot> docs = result.docs;

    return docs.length == 0 ? true : false;
  }

  Future<void> signOut() async {
    if (_googleSignIn.currentUser != null) await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Stream<QuerySnapshot> getAllUsers() {
    return _userCollection.snapshots();
  }

  Future<void> addMessageToDb(
      Message message, UserModel sender, UserModel receiver) async {
    message.messageId = DateTime.now().millisecondsSinceEpoch.toString();
    var map;
    if (message.type == MESSAGE_TYPE_TEXT)
      map = message.toMap();
    else if (message.type == MESSAGE_TYPE_VOICE) map = message.toVoiceMap();

    await _messageCollection
        .doc(message.senderId)
        .collection(message.receiverId!)
        .doc(message.messageId)
        .set(map);

    await _messageCollection
        .doc(message.receiverId)
        .collection(message.senderId!)
        .doc(message.messageId)
        .set(map);

    addToContacts(
      sender: sender,
      receiver: receiver,
      message: message,
    );
  }

  Stream<QuerySnapshot> getMessages(String senderId, String receiverId) {
    return _messageCollection
        .doc(senderId)
        .collection(receiverId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> updateMessage(Message message, bool favorite) async {
    await _messageCollection
        .doc(message.senderId)
        .collection(message.receiverId!)
        .doc(message.messageId)
        .update({'isFavorite': favorite});

    await _messageCollection
        .doc(message.receiverId)
        .collection(message.senderId!)
        .doc(message.messageId)
        .update({'isFavorite': favorite});
  }

  DocumentReference getContactsDocument({String? of, String? forContact}) =>
      _userCollection.doc(of).collection(CONTACTS_COLLECTION).doc(forContact);

  addToContacts(
      {UserModel? sender, UserModel? receiver, Message? message}) async {
    Timestamp currentTime = Timestamp.now();

    await addToSenderContacts(sender!, receiver!, currentTime, message!);
    await addToReceiverContacts(sender, receiver, currentTime, message);
  }

  Future<void> addToSenderContacts(UserModel sender, UserModel receiver,
      currentTime, Message message) async {
    DocumentSnapshot senderSnapshot =
        await getContactsDocument(of: sender.uid, forContact: receiver.uid)
            .get();

    if (!senderSnapshot.exists) {
      //does not exists
      Contact receiverContact = Contact(
        userModel: receiver,
        addedOn: currentTime,
        message: message.message,
        senderId: message.senderId,
        unread: true,
        lastMessageAdded: message.timestamp,
      );

      var receiverMap = receiverContact.toMap(receiverContact);

      await getContactsDocument(of: sender.uid, forContact: receiver.uid)
          .set(receiverMap);
    } else {
      await getContactsDocument(of: sender.uid, forContact: receiver.uid)
          .update({
        'message': message.message,
        'sender_id': message.senderId,
        'last_message_added': message.timestamp,
        'unread': true,
      });
    }
  }

  Future<void> addToReceiverContacts(UserModel sender, UserModel receiver,
      currentTime, Message message) async {
    DocumentSnapshot receiverSnapshot =
        await getContactsDocument(of: receiver.uid, forContact: sender.uid)
            .get();

    if (!receiverSnapshot.exists) {
      //does not exists
      Contact senderContact = Contact(
        userModel: sender,
        addedOn: currentTime,
        message: message.message,
        senderId: message.senderId,
        unread: true,
        lastMessageAdded: message.timestamp,
      );

      var senderMap = senderContact.toMap(senderContact);

      await getContactsDocument(of: receiver.uid, forContact: sender.uid)
          .set(senderMap);
    } else {
      await getContactsDocument(of: receiver.uid, forContact: sender.uid)
          .update({
        'message': message.message,
        'sender_id': message.senderId,
        'last_message_added': message.timestamp,
        'unread': true,
      });
    }
  }

  Stream<QuerySnapshot> fetchContacts(String userId) => _userCollection
      .doc(userId)
      .collection(CONTACTS_COLLECTION)
      .orderBy('last_message_added', descending: true)
      .snapshots();

  Future<void> markAsRead(UserModel sender, UserModel receiver) async {
    await _userCollection
        .doc(sender.uid)
        .collection(CONTACTS_COLLECTION)
        .doc(receiver.uid)
        .update({'unread': false});

    await _userCollection
        .doc(receiver.uid)
        .collection(CONTACTS_COLLECTION)
        .doc(sender.uid)
        .update({'unread': false});
  }

  Future<List<UserModel>> fetchAllUsers(User currentUser) async {
    List<UserModel> userList = [];

    QuerySnapshot querySnapshot = await firestore.collection('users').get();

    querySnapshot.docs.forEach((DocumentSnapshot userDocument) {
      if (userDocument.id != currentUser.uid)
        userList.add(
            UserModel.fromMap(userDocument.data() as Map<String, dynamic>));
    });

    return userList;
  }

  Future<String> uploadRecording({@required File? audioFile}) async {
    String randomId = 'rec/${Utils.randomString(10)}.aac';
    await _storageReference.child(randomId).putFile(audioFile!);
    String downloadURL =
        await _storageReference.child(randomId).getDownloadURL();
    return downloadURL;
  }

  Future<void> setUserState(
      {required String userId, required UserState userState}) async {
    int stateNum = Utils.stateToNum(userState);
    _userCollection.doc(userId).update({'state': stateNum});
  }
}
