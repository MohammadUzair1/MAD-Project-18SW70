import 'package:chat_app/utilities/constants.dart';
import 'package:chat_app/utilities/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'auth_screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final int _numOfPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  void _moveToLoginScreen() {
    Get.offAll(LoginScreen());
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numOfPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Color(0xFF7B51D3),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPage != _numOfPages - 1) {
      Future.delayed(Duration(seconds: 5), () {
        _pageController.nextPage(
            duration: Duration(microseconds: 1000), curve: Curves.ease);
      });
    }

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Color(0xff4563DB)),
    );

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff3594DD),
                Color(0xff4563DB),
                Color(0xff5036D5),
                Color(0xff5B16D0),
              ],
              stops: [0.1, 0.4, 0.7, 0.9],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Column(
              children: [
                _currentPage == _numOfPages - 1
                    ? Container(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: null,
                          child: Text(
                            '',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'CM Sans Serif',
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _moveToLoginScreen,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'CM Sans Serif',
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                Container(
                  height: 600.0,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (value) {
                      setState(() {
                        _currentPage = value;
                      });
                    },
                    physics: ClampingScrollPhysics(),
                    children: [
                      BuildPage(
                        imagePath: Images.onboarding0,
                        title: 'About Programmers',
                        subtitle:
                            'Any fool can write code that a computer can understand. Good programmers'
                            ' write code that humans can understand.',
                      ),
                      BuildPage(
                        imagePath: Images.onboarding1,
                        title: 'Motivation',
                        subtitle: 'while( !( succeed = try() ) );',
                      ),
                      BuildPage(
                        imagePath: Images.onboarding2,
                        title: 'Always Help',
                        subtitle:
                            'Helping others is the way we help ourselves.',
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: _currentPage == _numOfPages - 1
          ? GestureDetector(
              onTap: _moveToLoginScreen,
              child: Container(
                height: 60.0,
                alignment: Alignment.center,
                width: double.infinity,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'GET STARTED',
                    style: TextStyle(
                      color: Color(0xff4563DB),
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          : Text(''),
    );
  }
}

class BuildPage extends StatelessWidget {
  final String? imagePath;
  final String? title;
  final String? subtitle;

  const BuildPage({
    Key? key,
    this.imagePath,
    this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image(
              image: AssetImage(imagePath!),
              width: 300.0,
              height: 300.0,
            ),
          ),
          SizedBox(height: 30.0),
          Text(title!, style: kTitleStyle),
          SizedBox(height: 15.0),
          Text(subtitle!, style: kSubTitleStyle),
        ],
      ),
    );
  }
}
