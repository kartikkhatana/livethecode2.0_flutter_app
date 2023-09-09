import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:permission_handler/permission_handler.dart' as ph;

import 'model/locationDetails.dart';

class LocationService {
  static Future<void> showLocationBarrier(
      BuildContext context) async {
    return showDialog<void>(
      barrierDismissible: false,
      context: context, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Please enable location permission to proceed"),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MaterialButton(
                    onPressed: () async {
                      Location location = Location();

                      PermissionStatus permissionGranted =
                          await location.hasPermission();

                      if (permissionGranted != PermissionStatus.granted) {
                        await ph.openAppSettings();
                      }

                      bool serviceEnabled;

                      serviceEnabled = await location.serviceEnabled();
                      if (!serviceEnabled) {
                        serviceEnabled = await location.requestService();
                        if (!serviceEnabled) {
                          return;
                        }
                      }

                      permissionGranted = await location.hasPermission();

                      if (permissionGranted == PermissionStatus.granted &&
                          serviceEnabled) {
                        LocationService.getLocation();
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Enable"),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  static Future _getAddressFromLatLng(Position position) async {
    final data = await geocoding
        .placemarkFromCoordinates(position.latitude, position.longitude)
        .then((List<geocoding.Placemark> placemarks) {
      geocoding.Placemark place = placemarks[0];
      LocationDetails.lat = position.latitude;
      LocationDetails.long = position.longitude;
    }).catchError((e) {});
    return data;
  }

  static Future getLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    await _getAddressFromLatLng(position);
  }

  // static Future checkPermission() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   // Test if location services are enabled.
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled don't continue
  //     // accessing the position and request users of the
  //     // App to enable the location services.
  //     return Future.error('Location services are disabled.');
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       // Permissions are denied, next time you could try
  //       // requesting permissions again (this is also where
  //       // Android's shouldShowRequestPermissionRationale
  //       // returned true. According to Android guidelines
  //       // your App should show an explanatory UI now.
  //       return Future.error('Location permissions are denied');
  //     }
  //   } else if (permission == LocationPermission.deniedForever) {
  //     await Geolocator.openAppSettings();
  //     // Permissions are denied forever, handle appropriately.
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }

  //   return true;

  //   // When we reach here, permissions are granted and we can
  //   // continue accessing the position of the device.

  //   //return await Geolocator.getCurrentPosition();
  // }

  // static Future determinePosition() async {
  //   Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //   LocationDetails.lat = position.latitude.toString();
  //   LocationDetails.long = position.longitude.toString();
  // }
}
