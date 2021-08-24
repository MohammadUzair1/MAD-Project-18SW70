import 'package:chat_app/enum/view_state.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/provider/login_loading_provider.dart';
import 'package:chat_app/resources/firebase_repository.dart';
import 'package:chat_app/screens/auth_screens/signup_screen.dart';
import 'package:chat_app/screens/auth_screens/widgets/auth_field.dart';
import 'package:chat_app/screens/auth_screens/widgets/or_text.dart';
import 'package:chat_app/screens/auth_screens/widgets/social_buttons_row.dart';
import 'package:chat_app/utilities/constants.dart';
import 'package:chat_app/widgets/flush_bar.dart';
import 'package:chat_app/widgets/loading_widgets.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../home_screen.dart';
import 'widgets/auth_button.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseRepository _firebaseRepository = FirebaseRepository();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  IconData _suffixIcon = Icons.visibility_off;
  bool _obscureText = true;
  bool _rememberMe = false;

  LoginLoadingProvider? _loginLoadingProvider;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateFields() {
    if (_emailController.text.isEmpty && _passwordController.text.isEmpty) {
      showFailureDialog(context, 'Enter your Email and Password')
        ..show(context);
    } else if (_emailController.text.isEmpty) {
      showFailureDialog(context, 'Enter your Email')..show(context);
    } else if (_passwordController.text.isEmpty) {
      showFailureDialog(context, 'Enter your Password')..show(context);
    } else if (!EmailValidator.validate(_emailController.text)) {
      showFailureDialog(context, 'Invalid Email')..show(context);
    } else {
      _loginLoadingProvider!.setToLoading();
      _login();
    }
  }

  void _login() {
    FocusScope.of(context).unfocus();
    _firebaseRepository
        .login(_emailController.text, _passwordController.text)
        .then((User? user) {
      if (user != null) {
        _loginLoadingProvider!.setToIdle();
        Get.offAll(HomeScreen());
      } else {
        _loginLoadingProvider!.setToIdle();
        showFailureDialog(context, 'Failed to Sign In')..show(context);
      }
    }).catchError((error) {
      _loginLoadingProvider!.setToIdle();
      showFailureDialog(context, error.message.toString())..show(context);
    });
  }

  void _googleLogin() {
    _firebaseRepository.googleLogin().then((User? user) {
      if (user != null) {
        _firebaseRepository.authenticateUser(user).then((isNewUser) {
          if (isNewUser) {
            _saveUserData(user);
          } else {
            Get.offAll(HomeScreen());
          }
        }).catchError((error) {
          showFailureDialog(context, error.message.toString())..show(context);
        });
      } else {
        showFailureDialog(context, 'Failed to Sign In')..show(context);
      }
    }).catchError((error) {
      showFailureDialog(context, 'Failed to Sign In')..show(context);
    });
  }

  void _saveUserData(User user) {
    UserModel userModel = UserModel(
      uid: user.uid,
      name: user.displayName,
      email: user.email,
      profileImage: user.photoURL,
      state: 1,
    );
    _firebaseRepository.saveUserDataToFirestore(userModel).then((value) {
      Get.offAll(HomeScreen());
    }).catchError((error) {
      showFailureDialog(context, error.message.toString())..show(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    _loginLoadingProvider = Provider.of<LoginLoadingProvider>(context);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Color(0xff4563DB)),
    );

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                Container(
                  height: double.infinity,
                  width: double.infinity,
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
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 40.0,
                          vertical: constraints.maxHeight * 0.1,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'OpenSans',
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            AuthField(
                              controller: _emailController,
                              label: 'Email',
                              leadingIconData: Icons.email,
                              hintText: 'Enter your Email',
                              textInputType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                            SizedBox(height: 10.0),
                            AuthField(
                              controller: _passwordController,
                              label: 'Password',
                              obscureText: _obscureText,
                              leadingIconData: Icons.lock,
                              hintText: 'Enter your Password',
                              suffixIconData: _suffixIcon,
                              suffixIconPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                  _suffixIcon = _suffixIcon == Icons.visibility
                                      ? Icons.visibility_off
                                      : Icons.visibility;
                                });
                              },
                              textInputAction: TextInputAction.done,
                            ),
                            _buildForgetPasswordBtn(),
                            _buildRememberMeCheckBox(),
                            _loginLoadingProvider!.getViewState ==
                                    ViewState.LOADING
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    child: circularProgress(),
                                  )
                                : AuthButton(
                                    onPressed: _validateFields,
                                    buttonText: 'LOGIN',
                                  ),
                            OrText(text: 'Sign in with'),
                            SocialButton(
                              googleClick: _googleLogin,
                            ),
                            _buildSignupButton(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgetPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => print('Forgot Button Pressed'),
        child: Text(
          'Forgot Password',
          style: kLabelStyle,
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckBox() {
    return Container(
      height: 20.0,
      child: Row(
        children: [
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: _rememberMe,
              checkColor: Color(0xff5036D5),
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value!;
                });
              },
            ),
          ),
          Text('Remember me', style: kLabelStyle),
        ],
      ),
    );
  }

  Widget _buildSignupButton() {
    // Not using RichText because I just want Sign Up to be clickable not complete row
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account?',
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
        TextButton(
          onPressed: () => Get.off(SignupScreen()),
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
