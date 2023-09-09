import 'package:event_app/apis/auth.dart';
import 'package:event_app/pages/buttons.dart';
import 'package:event_app/pages/map_page.dart';
import 'package:event_app/pages/organizer/organizer_register.dart';
import 'package:event_app/pages/textfields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import "package:permission_handler/permission_handler.dart" as ph;
import '../../locationService.dart';
import '../../model/user.dart';
import '../../provider/loadingProvider.dart';
import '../../snackbar.dart';

class OrganizerLoginPage extends ConsumerStatefulWidget {
  const OrganizerLoginPage({super.key});

  @override
  ConsumerState<OrganizerLoginPage> createState() => _OrganizerLoginPageState();
}

class _OrganizerLoginPageState extends ConsumerState<OrganizerLoginPage> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
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
                  "Welcome Back",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 10),
                Text(
                  "Sign in to continue",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 30),
                formFields("Email", emailC),
                SizedBox(height: 30),
                passField("Password", passC, obscure: true),
                SizedBox(height: 30),
                Consumer(
                  builder: (context, ref, child) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      child: primaryButton("Login", () async {
                        if (emailC.text.isNotEmpty && passC.text.isNotEmpty) {
                          ref.read(isLoading.notifier).state = true;
                          try {
                            await AuthAPI.login(emailC.text, passC.text)
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
                      }),
                    );
                  },
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Dont have an account ?"),
                    TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      OrganizerRegisterPage()),
                              (context) => false);
                        },
                        child: Text(
                          "Create Organizer Account",
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
