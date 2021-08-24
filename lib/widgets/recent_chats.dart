import 'package:chat_app/models/contact.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/resources/firebase_repository.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/utilities/images.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'loading_widgets.dart';

class RecentChats extends StatelessWidget {
  final FirebaseRepository _firebaseRepository = FirebaseRepository();

  DateFormat dateFormat = DateFormat('h:mm a');

  void _moveToChatScreen(UserModel receiver, UserModel sender) {
    _firebaseRepository
        .markAsRead(sender, receiver)
        .then((value) {})
        .catchError((error) {});

    Get.to(ChatScreen(
      receiver: receiver,
      sender: sender,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          child: userProvider.getUser == null
              ? Center(
                  child: circularProgress(color: Color(0xff3594DD)),
                )
              : StreamBuilder<QuerySnapshot>(
                  stream: _firebaseRepository
                      .fetchContacts(userProvider.getUser!.uid!),
                  builder: (context, snapshot) {
                    return ListView.builder(
                      itemCount: snapshot.data == null
                          ? 0
                          : snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Contact contact = Contact.fromMap(
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>);
                        return GestureDetector(
                          onTap: () => _moveToChatScreen(
                            contact.userModel!,
                            userProvider.getUser!,
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 5.0,
                              right: 20.0,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 15.0),
                            decoration: BoxDecoration(
                              color:
                                  contact.senderId != userProvider.getUser!.uid
                                      ? contact.unread!
                                          ? Colors.blue[100]
                                          : Colors.white
                                      : Colors.white,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 35.0,
                                          backgroundImage:
                                              contact.userModel!.profileImage ==
                                                      null
                                                  ? AssetImage(Images.avatar)
                                                  : NetworkImage(contact
                                                          .userModel!
                                                          .profileImage!)
                                                      as ImageProvider,
                                        ),
                                        // Positioned(
                                        //   bottom: 0,
                                        //   right: 4,
                                        //   child: Container(
                                        //     width: 14.0,
                                        //     height: 14.0,
                                        //     decoration: BoxDecoration(
                                        //       color: _userStateColor,
                                        //       shape: BoxShape.circle,
                                        //     ),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                    SizedBox(width: 10.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          contact.userModel!.name!,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5.0),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          child: Text(
                                            contact.message!,
                                            style: TextStyle(
                                              color: Colors.blueGrey,
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(dateFormat.format(DateTime.parse(
                                        contact.lastMessageAdded!
                                            .toDate()
                                            .toString()))),
                                    SizedBox(height: 5.0),
                                    contact.senderId !=
                                            userProvider.getUser!.uid
                                        ? contact.unread!
                                            ? Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                        vertical: 4.0),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Text(
                                                  'NEW',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10.0),
                                                ),
                                              )
                                            : Text('')
                                        : Text(''),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
        ),
      ),
    );
  }
}
