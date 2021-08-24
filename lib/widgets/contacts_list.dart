import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/resources/firebase_repository.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/utilities/images.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'loading_widgets.dart';

class FavoriteContacts extends StatelessWidget {
  final FirebaseRepository _firebaseRepository = FirebaseRepository();
  UserProvider? _userProvider;

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Contacts',
                  style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            height: 120.0,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: _userProvider?.getUser == null
                  ? Center(
                      child: circularProgress(color: Color(0xff3594DD)),
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: _firebaseRepository.getAllUsers(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: circularProgress(color: Color(0xff3594DD)),
                          );
                        }
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            UserModel userModel = UserModel.fromMap(
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>);
                            if (_userProvider!.getUser!.uid != userModel.uid) {
                              return GestureDetector(
                                onTap: () => Get.to(ChatScreen(
                                  receiver: userModel,
                                  sender: _userProvider!.getUser!,
                                )),
                                child: _userColumn(userModel),
                              );
                            } else
                              return Container();
                          },
                        );
                      }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userColumn(UserModel userModel) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35.0,
            backgroundImage: userModel.profileImage! == ''
                ? AssetImage(Images.avatar)
                : NetworkImage(userModel.profileImage!) as ImageProvider,
          ),
          SizedBox(height: 6.0),
          Text(
            userModel.name!,
            style: TextStyle(color: Colors.blueGrey, fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}
