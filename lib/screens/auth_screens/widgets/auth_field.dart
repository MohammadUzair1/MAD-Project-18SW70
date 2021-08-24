import 'package:chat_app/utilities/constants.dart';
import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final IconData? leadingIconData;
  final IconData? suffixIconData;
  final bool? obscureText;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final Function()? suffixIconPressed;

  const AuthField({
    Key? key,
    this.controller,
    this.label,
    this.hintText,
    this.leadingIconData,
    this.suffixIconData,
    this.obscureText = false,
    this.textInputType,
    this.textInputAction,
    this.suffixIconPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: controller,
            cursorColor: Color(0xff5B16D0),
            keyboardType: textInputType,
            textInputAction: textInputAction,
            obscureText: obscureText!,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              suffixIcon: suffixIconData == null
                  ? Container(
                      width: 0.0,
                      height: 0.0,
                    )
                  : GestureDetector(
                      onTap: suffixIconPressed,
                      child: Icon(
                        suffixIconData,
                        color: Colors.white,
                      ),
                    ),
              prefixIcon: Icon(
                leadingIconData,
                color: Colors.white,
              ),
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }
}
