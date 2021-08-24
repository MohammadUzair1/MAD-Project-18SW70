import 'package:chat_app/utilities/logos.dart';
import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final Function()? googleClick;

  const SocialButton({
    Key? key,
    this.googleClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: _buildSocialBtn(
        onTap: googleClick!,
        logo: AssetImage(Logos.google),
      ),
    );
  }

  Widget _buildSocialBtn(
      {@required AssetImage? logo, required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60.0,
        height: 60.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: logo!,
            fit: BoxFit.cover,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
