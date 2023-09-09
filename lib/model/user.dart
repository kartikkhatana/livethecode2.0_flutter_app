class Organizer {
  String? token;
  String? name;
  String? email;

  Organizer.fromJson(Map<String, dynamic> json) {
    token = json["token"]!;
    name = json["data"]['user']["name"];
    email = json["data"]['user']["email"];
  }

  Map<String, dynamic> toJson() {
    return {"token": token, "name": name, "email": email};
  }
}

class CurrentOrganizer {
  static Organizer? organizer;
}
