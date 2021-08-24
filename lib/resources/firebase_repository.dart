import 'dart:io';

import 'package:chat_app/enum/user_state.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_methods.dart';

class FirebaseRepository {
  final FirebaseMethods _firebaseMethods = FirebaseMethods();

  User? getCurrentUser() => _firebaseMethods.getCurrentUser();

  Future<UserModel> getUserDetails() => _firebaseMethods.getUserDetails();

  Future<User?> signUp(String email, String password) =>
      _firebaseMethods.signUp(email, password);

  Future<void> saveUserDataToFirestore(UserModel userModel) =>
      _firebaseMethods.saveUserDataToFirestore(userModel);

  Future<User?> login(String email, String password) =>
      _firebaseMethods.login(email, password);

  Future<User> googleLogin() => _firebaseMethods.googleLogin();

  Future<bool> authenticateUser(User user) =>
      _firebaseMethods.authenticateUser(user);

  Future<void> signOut() => _firebaseMethods.signOut();

  Stream<QuerySnapshot> getAllUsers() => _firebaseMethods.getAllUsers();

  Future<void> addMessageToDb(
          Message message, UserModel sender, UserModel receiver) =>
      _firebaseMethods.addMessageToDb(message, sender, receiver);

  Stream<QuerySnapshot> getMessages(String senderId, String receiverId) =>
      _firebaseMethods.getMessages(senderId, receiverId);

  Future<void> updateMessage(Message message, bool favorite) =>
      _firebaseMethods.updateMessage(message, favorite);

  Stream<QuerySnapshot> fetchContacts(String userId) =>
      _firebaseMethods.fetchContacts(userId);

  Future<void> markAsRead(UserModel sender, UserModel receiver) =>
      _firebaseMethods.markAsRead(sender, receiver);

  Future<List<UserModel>> fetchAllUsers(User currentUser) =>
      _firebaseMethods.fetchAllUsers(currentUser);

  Future<String> uploadRecording({required File audioFile}) =>
      _firebaseMethods.uploadRecording(audioFile: audioFile);

  Future<void> setUserState(
          {required String userId, required UserState userState}) =>
      _firebaseMethods.setUserState(userId: userId, userState: userState);

  Future<UserModel> getUserDetailsById(String uid) =>
      _firebaseMethods.getUserDetailsById(uid);
}
