import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/resources/firebase_repository.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  FirebaseRepository _firebaseRepository = FirebaseRepository();

  UserModel? get getUser => _user;

  Future<void> refreshUser() async {
    UserModel user = await _firebaseRepository.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
