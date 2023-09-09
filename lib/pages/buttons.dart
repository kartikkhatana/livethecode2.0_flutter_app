import 'package:flutter/material.dart';

import '../colors.dart';

Widget primaryButton(String title, Function() onPress) {
  return Container(
    decoration: BoxDecoration(
        // border: Border.all(width: 1,color: Colors.black12),
        gradient: LinearGradient(
          colors: <Color>[MyColors.secondary, MyColors.primary],
        ),
        borderRadius: BorderRadius.circular(10)),
    child: MaterialButton(
      elevation: 0,
      onPressed: () {
        onPress();
      },
      child: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.symmetric(vertical: 15),
    ),
  );
}

Widget secondaryButton(String title, Function() onPress) {
  return MaterialButton(
    elevation: 0,
    onPressed: () {
      onPress();
    },
    child: Text(
      title,
      style: TextStyle(color: Colors.black, fontSize: 16),
    ),
    color: Colors.white,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(width: 1, color: Colors.black)),
    padding: EdgeInsets.symmetric(vertical: 15),
  );
}
