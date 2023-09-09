import 'package:event_app/constants.dart';
import "package:http/http.dart" as http;
import 'dart:convert';

class AuthAPI {
  static Future login(String email, String pass) async {
    String url = "$baseURL/v1/users/login";

    Map<String, String> body = {"email": email, "password": pass};
    http.Response response = await http.post(Uri.parse(url), body: jsonEncode(body),headers: headers);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      return Future.error(data);
    }
  }

  static Future register(String name, String email, String role, String pass,
      String confirmpass) async {
    String url = "$baseURL/v1/users/signup";

    Map<String, dynamic> body = {
      "name": name,
      "email": email,
      "password": pass,
      "passwordConfirm": confirmpass,
      "role": role
    };
    print(body);
    http.Response response = await http.post(Uri.parse(url),body: jsonEncode(body),headers: headers);
    print(response);
    final data = jsonDecode(response.body);
    print(data);
    if (response.statusCode == 201) {
      return data;
    } else {
      return Future.error(data);
    }
  }
}
