import 'package:flutter/material.dart';

import '../colors.dart';

Widget formFields(String hint, TextEditingController controller,
    {bool? obscure, int? min, int? max}) {
  return TextField(
    controller: controller,
    obscureText: obscure ?? false,
    minLines: min,
    maxLines: max,
    decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1, color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 2, color: MyColors.primary),
        )),
  );
}

Widget passField(String hint, TextEditingController controller,
    {bool? obscure, int? min, int? max}) {
  return TextField(
    controller: controller,
    obscureText: obscure ?? false,
    decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1, color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 2, color: MyColors.primary),
        )),
  );
}
