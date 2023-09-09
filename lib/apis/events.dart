import 'dart:convert';
import 'package:event_app/model/user.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class EventAPI {
  static Future getEvents(
      double lat, double long, double distance, String time) async {
    String url = "$baseURL/v1/events/getEvents";

    Map<String, dynamic> body = {
      "location": [lat, long],
      "distance": distance,
      "time": time
    };

    print(body);

    http.Response response = await http.post(Uri.parse(url),
        headers: headers, body: jsonEncode(body));

    final data = jsonDecode(response.body);

    print(data);

    if (response.statusCode == 200) {
      return data;
    } else {
      return Future.error(data);
    }
  }

  static Future addEvent(String name, String theme, String description,
      double lat, double long, DateTime start, DateTime end) async {
    String url = "$baseURL/v1/events";

    Map<String, dynamic> body = {
      "name": name,
      "theme": theme,
      "description": description,
      "startDate": start.toUtc().toIso8601String(),
      "endDate": end.toUtc().toIso8601String(),
      "location": [lat, long],
      "owner": CurrentOrganizer.organizer != null
          ? CurrentOrganizer.organizer!.email
          : ""
    };

    print(body);

    http.Response response = await http.post(Uri.parse(url),
        headers: headers, body: jsonEncode(body));

    final data = jsonDecode(response.body);

    print(data);

    if (response.statusCode == 201) {
      return data;
    } else {
      return Future.error(data);
    }
  }

  static Future getUserEvents(String name, String theme, String description,
      double lat, double long, DateTime start, DateTime end) async {

    String url = "$baseURL/v1/getUserEvents";

    http.Response response = await http.post(Uri.parse(url), headers: {
      ...headers,
      "Authorization": CurrentOrganizer.organizer!.token!
    });

    final data = jsonDecode(response.body);

    print(data);

    if (response.statusCode == 201) {
      return data;
    } else {
      return Future.error(data);
    }
  }

  static Future deleteEvents(String name, String theme, String description,
      double lat, double long, DateTime start, DateTime end) async {
        
    String url = "$baseURL/v1/deleteEvents";

    http.Response response = await http.post(Uri.parse(url), headers: {
      ...headers,
      "Authorization": CurrentOrganizer.organizer!.token!
    });

    final data = jsonDecode(response.body);

    print(data);

    if (response.statusCode == 201) {
      return data;
    } else {
      return Future.error(data);
    }
  }
}
