import 'package:event_app/apis/auth.dart';
import 'package:event_app/model/user.dart';
import 'package:event_app/pages/buttons.dart';
import 'package:event_app/pages/organizer/organizer_login.dart';
import 'package:event_app/pages/textfields.dart';
import 'package:event_app/provider/loadingProvider.dart';
import 'package:event_app/snackbar.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import "package:permission_handler/permission_handler.dart" as ph;
import '../../locationService.dart';
import '../map_page.dart';

class OrganizerRegisterPage extends StatefulWidget {
  const OrganizerRegisterPage({super.key});

  @override
  State<OrganizerRegisterPage> createState() => _OrganizerRegisterPageState();
}

class _OrganizerRegisterPageState extends State<OrganizerRegisterPage> {
  final firstNameC = TextEditingController();
  final lastNameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final confirmpassC = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ph.Permission.location.request().then((value) async {
      print(value.toString());
      if (!value.isGranted) {
        LocationService.showLocationBarrier(context);
      } else {
        Location location = Location();
        bool serviceEnabled = await location.serviceEnabled();
        if (!serviceEnabled) {
          serviceEnabled = await location.requestService();
          if (!serviceEnabled) {
            LocationService.showLocationBarrier(context);
            return;
          } else {
            LocationService.getLocation();
          }
        } else {
          LocationService.getLocation();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Text(
                  "Organizer",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                SizedBox(height: 20),
                Text(
                  "Welcome",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 10),
                Text(
                  "Register as Organizer",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(child: formFields("First Name", firstNameC)),
                    SizedBox(width: 10),
                    Expanded(child: formFields("Last Name", lastNameC)),
                  ],
                ),
                SizedBox(height: 20),
                formFields("Email", emailC),
                SizedBox(height: 30),
                passField("Password", passC, obscure: true),
                SizedBox(height: 30),
                passField("Confirm Password", confirmpassC, obscure: true),
                SizedBox(height: 30),
                Consumer(builder: (context, ref, child) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      child: primaryButton("Register", () async {
                        if (firstNameC.text.isNotEmpty &&
                            lastNameC.text.isNotEmpty &&
                            emailC.text.isNotEmpty &&
                            passC.text.isNotEmpty &&
                            confirmpassC.text.isNotEmpty) {
                          ref.read(isLoading.notifier).state = true;
                          try {
                            await AuthAPI.register(
                                    "${firstNameC.text} ${lastNameC.text}",
                                    emailC.text,
                                    "organiser",
                                    passC.text,
                                    confirmpassC.text)
                                .then((value) {
                              if (value != null) {
                                CurrentOrganizer.organizer =
                                    Organizer.fromJson(value);
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MapPage("organizer")),
                                    (context) => false);
                                showSnackBar(context, value['status']);
                              }
                            }).catchError((e) {
                              if (e != null && e['error'] != null) {
                                showSnackBar(context, e['error']['message']);
                              }
                            });
                          } catch (e) {
                            showSnackBar(context, e.toString());
                          }
                          ref.read(isLoading.notifier).state = false;
                        } else {
                          showSnackBar(
                              context, "Please fill all the above fields");
                        }
                      }));
                }),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account ?"),
                    TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OrganizerLoginPage()),
                              (context) => false);
                        },
                        child: Text(
                          "Sign in",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))
                  ],
                ),
                Spacer(),
                Container(
                    width: MediaQuery.of(context).size.width,
                    child: secondaryButton("View Events", () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MapPage("guest")),
                          (context) => false);
                    })),
                SizedBox(height: 20)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
