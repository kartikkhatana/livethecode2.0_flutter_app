import 'package:flutter/material.dart';

showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 2),
  ));
}

 String capitalizeFirstLetter(String? input) {
    if (input == null || input.isEmpty) {
      return "";
    }
    return input[0].toUpperCase() + input.substring(1);
  }
