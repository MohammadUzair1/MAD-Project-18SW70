import 'dart:async';
import 'dart:io';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/resources/firebase_repository.dart';
import 'package:chat_app/utilities/constants.dart';
import 'package:chat_app/utilities/utils.dart';
import 'package:chat_app/widgets/loading_widgets.dart';
import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.sender, required this.receiver})
      : super(key: key);

  final UserModel receiver;
  final UserModel sender;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseRepository _firebaseRepository = FirebaseRepository();
  final TextEditingController _textEditingController = TextEditingController();
  StreamSubscription<DocumentSnapshot>? subscription;

  DateFormat dateFormat = DateFormat('dd-MM-yy – h:mm a');




  Color _userStateColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _getUserPermissions();
    subscription = FirebaseFirestore.instance
        .collection(USERS_COLLECTION)
        .doc(widget.receiver.uid)
        .snapshots()
        .listen((datasnapshot) {
      if (datasnapshot.exists) {
        setState(() {
          _userStateColor = _getStateColor(datasnapshot.data()!['state']);
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
    subscription?.cancel();
  }

  Color _getStateColor(int state) {
    switch (state) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  void _getUserPermissions() async {
    await [
      Permission.storage,
      Permission.microphone,
    ].request();
  }

  void _sendMessage() {
    if (_textEditingController.text.trim().isNotEmpty) {
      var message = _textEditingController.text;

      Message _message = Message(
        receiverId: widget.receiver.uid,
        senderId: widget.sender.uid,
        message: message,
        timestamp: Timestamp.now(),
        type: MESSAGE_TYPE_TEXT,
        isFavorite: false,
        unread: true,
      );

      _firebaseRepository
          .addMessageToDb(_message, widget.sender, widget.receiver)
          .then((value) {})
          .catchError((error) {});
      _textEditingController.clear();
    }
  }

  void _controlFavorite(Message message) {
    _firebaseRepository
        .updateMessage(message, !message.isFavorite!)
        .then((value) {})
        .catchError((error) {});
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff3594DD),
      appBar: AppBar(
        backgroundColor: Color(0xff3594DD),
        elevation: 0.0,
        title: Text(
          widget.receiver.name!,
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            width: 14.0,
            height: 14.0,
            decoration: BoxDecoration(
              color: _userStateColor,
              shape: BoxShape.circle,
            ),
          ),
          // IconButton(
          //   iconSize: 30.0,
          //   color: Colors.white,
          //   icon: Icon(Icons.more_horiz),
          //   onPressed: () {},
          // ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 32.0, bottom: 10.0),
                child: StreamBuilder<QuerySnapshot>(
                    stream: _firebaseRepository.getMessages(
                        widget.sender.uid!, widget.receiver.uid!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: circularProgress(color: Color(0xff3594DD)),
                        );
                      }
                      return ListView.builder(
                        reverse: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Message message = Message.fromMap(
                              snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>);
                          message.messageId = snapshot.data!.docs[index].id;
                          return message.senderId == widget.sender.uid
                              ? _senderLayout(message)
                              : _receiverLayout(message);
                        },
                      );
                    }),
              ),
            ),
            _chatControls(),
          ],
        ),
      ),
    );
  }

  // Widget _controlSenderLayouts(Message message) {
  //   if (message.type == MESSAGE_TYPE_TEXT)
  //     return _senderLayout(message);
  //   else if (message.type == MESSAGE_TYPE_VOICE) return Text('');
  //   return Text('');
  // }

  // Widget _controlReceiverLayouts(Message message) {
  //   if (message.type == MESSAGE_TYPE_TEXT)
  //     return _receiverLayout(message);
  //   else if (message.type == MESSAGE_TYPE_VOICE) return Text('');
  //   return Text('');
  // }

  Widget _receiverLayout(Message message) {
    return Row(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.7,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12.0),
              bottomRight: Radius.circular(12.0),
            ),
          ),
          margin: const EdgeInsets.only(
            top: 10.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateFormat.format(
                    DateTime.parse(message.timestamp!.toDate().toString())),
                style: TextStyle(color: Colors.blueGrey, fontSize: 16.0),
              ),
              SizedBox(height: 4.0),
               Text(
                      message.message!,
                      style: TextStyle(color: Colors.blueGrey, fontSize: 16.0),
                    ),
                  
            ],
          ),
        ),
        IconButton(
          onPressed: () => _controlFavorite(message),
          icon: Icon(
              message.isFavorite! ? Icons.favorite : Icons.favorite_outline),
          color: Colors.red,
          iconSize: 30.0,
        ),
      ],
    );
  }

  Widget _senderLayout(Message message) {
    return Container(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.0),
            bottomLeft: Radius.circular(12.0),
          ),
        ),
        margin: const EdgeInsets.only(
          top: 10.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateFormat.format(
                  DateTime.parse(message.timestamp!.toDate().toString())),
              style: TextStyle(color: Colors.blueGrey, fontSize: 16.0),
            ),
            SizedBox(height: 4.0),
           Text(
                    message.message!,
                    style: TextStyle(color: Colors.blueGrey, fontSize: 16.0),
                  ),
                          ],
        ),
      ),
    );
  }

  Widget _chatControls() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.black38,
          ),
        ),
      ),
      child:Row(
              children: [
                IconButton(
                  icon: Icon(Icons.image),
                  color: Color(0xff3594DD),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    style: TextStyle(fontSize: 16.0, color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Send a message...',
                      border: InputBorder.none,
                      hintStyle:
                          TextStyle(fontSize: 16.0, color: Colors.black54),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  color: Color(0xff3594DD),
                  onPressed: _sendMessage,
                ),
                
              ],
            ),
    );
  }
}
