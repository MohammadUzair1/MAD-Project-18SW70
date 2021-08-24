import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String? buttonText;
  final Color? buttonColor;
  final Color? textColor;
  final Function()? onPressed;

  const AuthButton({
    Key? key,
    this.buttonText,
    this.buttonColor = Colors.white,
    this.textColor = const Color(0xff5036D5),
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: MaterialButton(
        elevation: 5.0,
        color: buttonColor,
        onPressed: onPressed,
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Text(
          buttonText!,
          style: TextStyle(
            letterSpacing: 1.5,
            fontFamily: 'OpenSans',
            fontSize: 18.0,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
