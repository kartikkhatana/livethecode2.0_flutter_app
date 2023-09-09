import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../locationService.dart';
import 'buttons.dart';
import 'map_page.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
class IntroductionPage extends StatefulWidget {
  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: MediaQuery.of(context).size.height / 3,child: Image.asset("assets/relief_icon.png")),
              SizedBox(height: 20),
              Text("Welcome To Relief",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24),),
              SizedBox(height: 20),
              Text(
                  "\"Service to world is service to god.\"\n\nRelief helps you in finding nearest camps for donation or social services. Lets make the world a better place!",textAlign: TextAlign.center,style: TextStyle(fontSize: 16),),
              SizedBox(height: 30),
              Container(
                  width: MediaQuery.of(context).size.width,
                  child: secondaryButton("View Events", () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MapPage("guest")),
                        (context) => false);
                  })),
              SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }
}
