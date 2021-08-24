import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

// Firebase Collections
const String USERS_COLLECTION = 'users';
const String MESSAGES_COLLECTION = 'messages';
const String CONTACTS_COLLECTION = 'contacts';

// Normal Strings
const String MESSAGE_TYPE_TEXT = 'text';

// Styles
final kTitleStyle = TextStyle(
  color: Colors.white,
  fontFamily: 'CM Sans Serif',
  fontSize: 26,
  height: 1.5,
);

final kSubTitleStyle = TextStyle(
  color: Colors.white,
  fontFamily: 'CM Sans Serif',
  fontSize: 18,
  height: 1.2,
);

final kLabelStyle = TextStyle(
  color: Colors.white,
  fontFamily: 'OpenSans',
  fontWeight: FontWeight.bold,
);

final kHintTextStyle = TextStyle(
  color: Colors.white,
  fontFamily: 'OpenSans',
);

final kBoxDecorationStyle = BoxDecoration(
  color: Color(0xff3594DD),
  borderRadius: BorderRadius.circular(8.0),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);
