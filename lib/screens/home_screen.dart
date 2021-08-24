import 'package:chat_app/enum/user_state.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/resources/firebase_repository.dart';
import 'package:chat_app/widgets/contacts_list.dart';
import 'package:chat_app/widgets/flush_bar.dart';
import 'package:chat_app/widgets/recent_chats.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'auth_screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final FirebaseRepository _firebaseRepository = FirebaseRepository();

  UserProvider? _userProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addObserver(this);

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      // Because init state called after one frame and there is no context
      _userProvider = Provider.of<UserProvider>(context, listen: false);
      _userProvider!.refreshUser().then((value) {
        _firebaseRepository.setUserState(
          userId: _userProvider!.getUser!.uid!,
          userState: UserState.Online,
        );
      }).catchError((error) {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String? currentUserId =
        (_userProvider != null && _userProvider!.getUser != null)
            ? _userProvider!.getUser!.uid!
            : '';

    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        currentUserId != ''
            ? _firebaseRepository.setUserState(
                userId: currentUserId, userState: UserState.Online)
            : print("resume state");
        break;
      case AppLifecycleState.inactive:
        currentUserId != ''
            ? _firebaseRepository.setUserState(
                userId: currentUserId, userState: UserState.Offline)
            : print("inactive state");
        break;
      case AppLifecycleState.paused:
        currentUserId != ''
            ? _firebaseRepository.setUserState(
                userId: currentUserId, userState: UserState.Waiting)
            : print("paused state");
        break;
      case AppLifecycleState.detached:
        currentUserId != ''
            ? _firebaseRepository.setUserState(
                userId: currentUserId, userState: UserState.Offline)
            : print("detached state");
        break;
    }
  }

  void _signOut() {
    _firebaseRepository.signOut().then((value) {
      _firebaseRepository.setUserState(
          userId: _userProvider!.getUser!.uid!, userState: UserState.Offline);
      print('Going back to login');
      Get.offAll(LoginScreen());
    }).catchError((error) {
      showFailureDialog(context, error.message.toString())..show(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff3594DD),
      appBar: AppBar(
        backgroundColor: Color(0xff3594DD),
        elevation: 0.0,
        title: Text(
          'Chats',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            iconSize: 30.0,
            color: Colors.white,
            icon: Icon(Icons.exit_to_app),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFFEF9EB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: Column(
                children: [
                  Contacts(),
                  RecentChats(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
