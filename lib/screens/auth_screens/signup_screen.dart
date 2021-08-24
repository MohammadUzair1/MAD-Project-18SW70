import 'package:chat_app/enum/view_state.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/provider/signup_loading_provider.dart';
import 'package:chat_app/resources/firebase_repository.dart';
import 'package:chat_app/screens/auth_screens/widgets/auth_button.dart';
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
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseRepository _firebaseRepository = FirebaseRepository();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  IconData _suffixIcon = Icons.visibility_off;
  bool _obscureText = true;
  bool _acceptTerms = false;

  SignupLoadingProvider? _signupLoadingProvider;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateFields() {
    if (_nameController.text.trim().isEmpty &&
        _emailController.text.trim().isEmpty &&
        _passwordController.text.isEmpty) {
      showFailureDialog(context, 'Enter your complete details')..show(context);
    } else if (_nameController.text.trim().isEmpty) {
      showFailureDialog(context, 'Enter your Name')..show(context);
    } else if (_emailController.text.trim().isEmpty) {
      showFailureDialog(context, 'Enter your Email')..show(context);
    } else if (_passwordController.text.isEmpty) {
      showFailureDialog(context, 'Enter your Password')..show(context);
    } else if (!EmailValidator.validate(_emailController.text)) {
      showFailureDialog(context, 'Invalid Email')..show(context);
    } else if (!_acceptTerms) {
      showFailureDialog(context, 'Please Accept Terms and Conditions')
        ..show(context);
    } else {
      _signupLoadingProvider!.setToLoading();
      _signup();
    }
  }

  void _signup() {
    FocusScope.of(context).unfocus();
    _firebaseRepository
        .signUp(_emailController.text, _passwordController.text)
        .then((User? user) {
      if (user != null) {
        _saveUserData(user);
      } else {
        _signupLoadingProvider!.setToIdle();
        showFailureDialog(context, 'Failed to Sign Up')..show(context);
      }
    }).catchError((error) {
      _signupLoadingProvider!.setToIdle();
      showFailureDialog(context, error.message.toString())..show(context);
    });
  }

  void _saveUserData(User user) {
    UserModel userModel = UserModel(
      uid: user.uid,
      name: _nameController.text,
      email: _emailController.text,
      state: 1,
      profileImage: '',
    );
    _firebaseRepository.saveUserDataToFirestore(userModel).then((value) {
      _signupLoadingProvider!.setToIdle();
      Get.offAll(HomeScreen());
    }).catchError((error) {
      _signupLoadingProvider!.setToIdle();
      showFailureDialog(context, error.message.toString())..show(context);
    });
  }

  void _googleLogin() {
    _firebaseRepository.googleLogin().then((User? user) {
      if (user != null) {
        _firebaseRepository.authenticateUser(user).then((isNewUser) {
          if (isNewUser) {
            _saveSocialUserData(user);
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

  void _saveSocialUserData(User user) {
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
    _signupLoadingProvider = Provider.of<SignupLoadingProvider>(context);

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
                          vertical: constraints.maxHeight * 0.02,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'OpenSans',
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            AuthField(
                              controller: _nameController,
                              label: 'Name',
                              leadingIconData: Icons.person,
                              hintText: 'Enter your Name',
                              textInputType: TextInputType.name,
                              textInputAction: TextInputAction.next,
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
                              textInputType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                            ),
                            SizedBox(height: 10.0),
                            _buildAcceptTermsCheckBox(),
                            _signupLoadingProvider!.getViewState ==
                                    ViewState.LOADING
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    child: circularProgress(),
                                  )
                                : AuthButton(
                                    onPressed: _validateFields,
                                    buttonText: 'SIGN UP',
                                  ),
                            OrText(text: 'Sign up with'),
                            SocialButton(
                              googleClick: _googleLogin,
                            ),
                            _buildLoginButton(),
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

  Widget _buildAcceptTermsCheckBox() {
    return Container(
      height: 20.0,
      child: Row(
        children: [
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: _acceptTerms,
              checkColor: Color(0xff5036D5),
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value!;
                });
              },
            ),
          ),
          Text('Accept Terms and Conditions', style: kLabelStyle),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    // Not using RichText because I just want Sign Up to be clickable not complete row
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
        TextButton(
          onPressed: () => Get.off(LoginScreen()),
          child: Text(
            'Login',
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
