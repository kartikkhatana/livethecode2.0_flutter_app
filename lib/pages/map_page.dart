import 'package:event_app/apis/events.dart';
import 'package:event_app/model/locationDetails.dart';
import 'package:event_app/pages/buttons.dart';
import 'package:event_app/pages/organizer/add_event.dart';
import 'package:event_app/pages/organizer/organizer_login.dart';
import 'package:event_app/pages/organizer/organizer_register.dart';
import 'package:event_app/provider/loadingProvider.dart';
import 'package:event_app/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart';
import 'dart:ui' as ui;
import '../colors.dart';
import '../locationService.dart';
import '../model/user.dart';
import 'package:intl/intl.dart';

class MapPage extends ConsumerStatefulWidget {
  String userType;

  MapPage(this.userType);

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  GoogleMapController? mapController;
  List<Marker> markersList = [];
  late Future categories;
  bool init = false;
  late final selectedCat;
  String locationValue = "";
  LatLng locationCoordinates =
      LatLng(LocationDetails.lat!, LocationDetails.long!);
  String selectedType = "On Going";
  double _currentSliderValue = 1;
  Future? events;
  BitmapDescriptor? clothIcon;
  BitmapDescriptor? foodIcon;
  BitmapDescriptor? awarenessIcon;
  BitmapDescriptor? bloodIcon;
  // final selectedName = StateProvider.autoDispose((ref) => "");
  void onMapCreated(controller) async {
    mapController = controller;
    reinitializeLocation();
    // await initMap([]);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void initialLocation() async {
    List<Placemark> location = await convert();
    locationValue =
        "${location.first.name}, ${location.first.subLocality}, ${location.first.subAdministrativeArea}, ${location.first.locality}, ${location.first.postalCode}";
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    addUserMarker();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      getEvents();
    });

    initIcons();
    initialLocation();
    //categories = MapExploreAPI.getCategories();
  }

  void reinitializeLocation() async {
    if (LocationDetails.lat == 0.0 || LocationDetails.long == 0.0) {
      await LocationService.getLocation();
      final currentZoom = await mapController!.getZoomLevel();

      final newCameraPosition = CameraPosition(
        target: LatLng(LocationDetails.lat, LocationDetails.long),
        zoom: currentZoom,
      );
      addUserMarker();
      mapController!
          .animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));

      setState(() {});
    }
  }

  void showDetails(String name, String description, String theme,
      String startDate, String endDate, double lat, double long) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        // This is the content of the bottom sheet.
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                theme,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Text(
                description,
                style: TextStyle(fontSize: 16.0),
              ),
              Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 40, top: 10, bottom: 10),
                  child: Divider()),
              Text(
                "From ${DateFormat.yMMMMd().add_jms().format(DateTime.parse(startDate))} to \n${DateFormat.yMMMMd().add_jms().format(DateTime.parse(endDate).toLocal())}",
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width,
                child: primaryButton("See Route", () async {
                  final availableMaps = await MapLauncher.installedMaps;
                  await availableMaps.first.showMarker(
                    coords: Coords(lat, long),
                    title: name,
                  );
                }),
              ),
              SizedBox(height: 30)
            ],
          ),
        );
      },
    );
  }

  void addUserMarker() {
    Marker startMarker = Marker(
      markerId: MarkerId("1"),
      position: LatLng(LocationDetails.lat, LocationDetails.long),
      infoWindow: InfoWindow(
        title: 'You',
      ),
      icon: BitmapDescriptor.defaultMarker,
    );

    markersList.add(startMarker);
  }

  void initIcons() async {
    final Uint8List food = await getBytesFromAsset('assets/food_icon.png', 100);
    foodIcon = BitmapDescriptor.fromBytes(food);
    final Uint8List blood =
        await getBytesFromAsset('assets/blood_icon.png', 100);
    bloodIcon = BitmapDescriptor.fromBytes(blood);
    final Uint8List awareness =
        await getBytesFromAsset('assets/awareness_icon.png', 100);
    awarenessIcon = BitmapDescriptor.fromBytes(awareness);
    final Uint8List clothes =
        await getBytesFromAsset('assets/clothes_icon.png', 100);
    clothIcon = BitmapDescriptor.fromBytes(clothes);
    setState(() {});
  }

  void getEvents() async {
    ref.read(isLoading.notifier).state = true;
    try {
      markersList.clear();
      addUserMarker();
      await EventAPI.getEvents(LocationDetails.lat!, LocationDetails.long!,
              _currentSliderValue, selectedType)
          .then((value) {
        if (value != null) {
          for (var i in value['data']['filteredEvents']) {
            BitmapDescriptor? icon;
            if (i['theme'] == "Blood Donation") {
              icon = bloodIcon;
            } else if (i['theme'] == "Clothes Donation") {
              icon = clothIcon;
            } else if (i['theme'] == "Awareness Camp") {
              icon = awarenessIcon;
            } else if (i['theme'] == "Food Donation") {
              icon = foodIcon;
            } else {
              icon = BitmapDescriptor.defaultMarker;
            }
            Marker eventMarker = Marker(
              onTap: () {
                showDetails(
                    i['name'],
                    i['description'],
                    i['theme'],
                    i['startDate'],
                    i['endDate'],
                    double.parse(i['location'][0]["\$numberDecimal"]),
                    double.parse(i['location'][1]["\$numberDecimal"]));
              },
              markerId: MarkerId(i["_id"]),
              position: LatLng(
                  double.parse(i['location'][0]["\$numberDecimal"]),
                  double.parse(i['location'][1]["\$numberDecimal"])),
              infoWindow: InfoWindow(
                title: i["name"],
              ),
              icon: icon ?? BitmapDescriptor.defaultMarkerWithHue(10),
            );

            markersList.add(eventMarker);
          }
          setState(() {});
        }
      });
    } catch (e) {
      print(e);
      showSnackBar(context, "Something went wrong! Please try again.");
    }
    ref.read(isLoading.notifier).state = false;
  }

  Future initMap(List<Map<String, dynamic>> data) async {
    // markersList.clear();
    // Marker startMarker = Marker(
    //   markerId: MarkerId("1"),
    //   position: widget.coordinates,
    //   infoWindow: InfoWindow(
    //     title: 'You',
    //   ),
    //   icon: BitmapDescriptor.defaultMarker,
    // );

    // markersList.add(startMarker);

    // if (data.isNotEmpty) {
    //   for (var i in data) {
    //     BitmapDescriptor icon =
    //         BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    //     if (i['map_icon'] != "") {
    //       final File markerImageFile =
    //           await DefaultCacheManager().getSingleFile(i['map_icon']);
    //       final Uint8List markerImageBytes =
    //           await markerImageFile.readAsBytes();
    //       final Codec markerImageCodec = await instantiateImageCodec(
    //         markerImageBytes,
    //         targetWidth: 100,
    //       );
    //       final FrameInfo frameInfo = await markerImageCodec.getNextFrame();
    //       final ByteData? byteData = await frameInfo.image.toByteData(
    //         format: ImageByteFormat.png,
    //       );
    //       final Uint8List resizedMarkerImageBytes =
    //           byteData!.buffer.asUint8List();
    //       icon = BitmapDescriptor.fromBytes(resizedMarkerImageBytes);
    //     }

    //     Marker locationMarkers = Marker(
    //       markerId: MarkerId(i['listing_id']),
    //       position:
    //           LatLng(double.parse(i['latitude']), double.parse(i['longitude'])),
    //       infoWindow: InfoWindow(
    //         title: i['title'],
    //       ),
    //       onTap: () {
    //         showMarkerData(i);
    //       },
    //       icon: icon,
    //     );

    //     markersList.add(locationMarkers);
    //   }
    // }

    // setState(() {});
  }

  // void showMarkerData(final data) {
  //   showModalBottomSheet<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Container(
  //         color: Colors.white,
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 10.0),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               const SizedBox(
  //                 height: 20.0,
  //               ),
  //               Row(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Container(
  //                       height: 100,
  //                       width: 100,
  //                       child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(10),
  //                         child: Image.network(
  //                           data['img'],
  //                           fit: BoxFit.cover,
  //                           loadingBuilder: (context, child, loadingProgress) {
  //                             if (loadingProgress == null) {
  //                               return child;
  //                             } else {
  //                               return Center(
  //                                 child: CircularProgressIndicator(),
  //                               );
  //                             }
  //                           },
  //                         ),
  //                       )),
  //                   SizedBox(width: 20),
  //                   Expanded(
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Row(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Expanded(
  //                                 child: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 Text(
  //                                   data['title'],
  //                                   style: TextStyle(
  //                                       fontSize: 16,
  //                                       fontWeight: FontWeight.bold),
  //                                 ),
  //                                 data['distance'].isNotEmpty
  //                                     ? Padding(
  //                                         padding: EdgeInsets.only(top: 10),
  //                                         child: Text(
  //                                           "Distance: " + data['distance'],
  //                                         ),
  //                                       )
  //                                     : Container(),
  //                                 data['address'].isNotEmpty
  //                                     ? Padding(
  //                                         padding: EdgeInsets.only(top: 10),
  //                                         child: Text(
  //                                           data['address'],
  //                                         ),
  //                                       )
  //                                     : Container(),
  //                               ],
  //                             )),
  //                             SizedBox(width: 20),
  //                             data['mobile'] != ""
  //                                 ? InkWell(
  //                                     onTap: () {
  //                                       _launchUrl(data['mobile']);
  //                                     },
  //                                     child: Container(
  //                                       decoration: BoxDecoration(
  //                                         shape: BoxShape.circle,
  //                                         color: color.blue,
  //                                       ),
  //                                       child: Padding(
  //                                           padding: EdgeInsets.all(10),
  //                                           child: Icon(
  //                                             Icons.phone,
  //                                             color: Colors.white,
  //                                           )),
  //                                     ),
  //                                   )
  //                                 : Container(),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                   )
  //                 ],
  //               ),
  //               SizedBox(height: 20),
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: Padding(
  //                       padding: EdgeInsets.symmetric(horizontal: 10),
  //                       child: MaterialButton(
  //                         onPressed: () {
  //                           MapsLauncher.launchCoordinates(
  //                               double.parse(data['latitude']),
  //                               double.parse(data['longitude']));
  //                         },
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: [
  //                             Icon(
  //                               Icons.directions,
  //                               color: Colors.white,
  //                             ),
  //                             SizedBox(width: 10),
  //                             Text(
  //                               "Directions",
  //                               style: TextStyle(color: Colors.white),
  //                             ).tr()
  //                           ],
  //                         ),
  //                         color: color.blue,
  //                         padding: EdgeInsets.symmetric(vertical: 15),
  //                         shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(10)),
  //                       ),
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: Padding(
  //                       padding: EdgeInsets.symmetric(horizontal: 10),
  //                       child: MaterialButton(
  //                         onPressed: () {
  //                           Navigator.push(
  //                               context,
  //                               MaterialPageRoute(
  //                                   builder: (context) => ExploreDetailsPage(
  //                                       data, widget.coordinates)));
  //                         },
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: [
  //                             Icon(Icons.menu),
  //                             SizedBox(width: 10),
  //                             Text(
  //                               "Details",
  //                             ).tr()
  //                           ],
  //                         ),
  //                         color: Colors.white,
  //                         padding: EdgeInsets.symmetric(vertical: 15),
  //                         shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                             side: BorderSide(color: color.blue, width: 1)),
  //                       ),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //               SizedBox(height: 20),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(

      //  title:  Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Text(
      //               "Welcome Kartik",
      //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      //             ),
      //             InkWell(
      //               borderRadius: BorderRadius.circular(100),
      //               onTap: () {},
      //               child: Container(
      //                 child: Padding(
      //                     padding: EdgeInsets.all(5),
      //                     child: Icon(Icons.person)),
      //                 decoration: BoxDecoration(
      //                     border: Border.all(width: 2,color: Colors.white),
      //                     borderRadius: BorderRadius.circular(100)),
      //               ),
      //             ),
      //           ],
      //         ),
      //   flexibleSpace: Container(
      //     decoration: const BoxDecoration(
      //       gradient: LinearGradient(
      //           begin: Alignment.centerLeft,
      //           end: Alignment.centerRight,
      //           colors: <Color>[MyColors.secondary, MyColors.primary]),
      //     ),
      //   ),
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.userType == "organizer"
                        ? "Welcome ${CurrentOrganizer.organizer!.name}"
                        : "Welcome Guest",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  widget.userType == "organizer"
                      ? InkWell(
                          borderRadius: BorderRadius.circular(100),
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OrganizerLoginPage()),
                                (context) => false);
                          },
                          child: Container(
                            child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Icon(Icons.logout)),
                            decoration: BoxDecoration(
                                border: Border.all(width: 2),
                                borderRadius: BorderRadius.circular(100)),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            SizedBox(height: 5),
            Divider(),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Check Events",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Ink(
                      decoration: BoxDecoration(
                          gradient: selectedType == "On Going"
                              ? LinearGradient(
                                  colors: <Color>[
                                    MyColors.secondary,
                                    MyColors.primary
                                  ],
                                )
                              : null,
                          border: selectedType == "On Going"
                              ? Border.all(width: 0, color: Colors.white)
                              : Border.all(width: 1),
                          borderRadius: BorderRadius.circular(20)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          setState(() {
                            selectedType = "On Going";
                            getEvents();
                          });
                        },
                        child: Container(
                          constraints: BoxConstraints(minWidth: 100),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "On Going",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: selectedType == "On Going"
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Ink(
                      decoration: BoxDecoration(
                          gradient: selectedType == "Upcoming"
                              ? LinearGradient(
                                  colors: <Color>[
                                    MyColors.secondary,
                                    MyColors.primary
                                  ],
                                )
                              : null,
                          border: selectedType == "Upcoming"
                              ? Border.all(width: 0, color: Colors.white)
                              : Border.all(width: 1),
                          borderRadius: BorderRadius.circular(20)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          setState(() {
                            selectedType = "Upcoming";
                            getEvents();
                          });
                        },
                        child: Container(
                          constraints: BoxConstraints(minWidth: 100),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Upcoming",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: selectedType == "Upcoming"
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Ink(
                      decoration: BoxDecoration(
                          gradient: selectedType == "Past"
                              ? LinearGradient(
                                  colors: <Color>[
                                    MyColors.secondary,
                                    MyColors.primary
                                  ],
                                )
                              : null,
                          border: selectedType == "Past"
                              ? Border.all(width: 0, color: Colors.white)
                              : Border.all(width: 1),
                          borderRadius: BorderRadius.circular(20)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          setState(() {
                            selectedType = "Past";
                            getEvents();
                          });
                        },
                        child: Container(
                          constraints: BoxConstraints(minWidth: 100),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Past",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: selectedType == "Past"
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Ink(
                      decoration: BoxDecoration(
                          gradient: selectedType == "All"
                              ? LinearGradient(
                                  colors: <Color>[
                                    MyColors.secondary,
                                    MyColors.primary
                                  ],
                                )
                              : null,
                          border: selectedType == "All"
                              ? Border.all(width: 0, color: Colors.white)
                              : Border.all(width: 1),
                          borderRadius: BorderRadius.circular(20)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          setState(() {
                            selectedType = "All";
                            getEvents();
                          });
                        },
                        child: Container(
                          constraints: BoxConstraints(minWidth: 100),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "All",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: selectedType == "All"
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Select Range",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ))),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Slider(
                      activeColor: MyColors.primary,
                      secondaryActiveColor: MyColors.secondary,
                      value: _currentSliderValue,
                      max: 100,
                      min: 1,
                      divisions: 100,
                      label: _currentSliderValue.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _currentSliderValue = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    _currentSliderValue.round().toString() + " km",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(width: 20),
                  primaryButton("Apply", () {
                    getEvents();
                    _zoomOut();
                  }),
                ],
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: GoogleMap(
                onTap: (argument) async {
                  if (widget.userType == "organizer") {
                    locationCoordinates = argument;
                    List<Placemark> location = await convert();
                    locationValue =
                        "${location.first.name}, ${location.first.subLocality}, ${location.first.subAdministrativeArea}, ${location.first.locality}, ${location.first.postalCode}";
                    markersList.removeWhere(
                        (element) => element.markerId == const MarkerId("1"));
                    Marker startMarker = Marker(
                      markerId: MarkerId("1"),
                      position: argument,
                      infoWindow: InfoWindow(
                        title: 'You',
                      ),
                      icon: BitmapDescriptor.defaultMarker,
                    );

                    markersList.add(startMarker);
                    setState(() {});
                  }
                },
                onMapCreated: onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(LocationDetails.lat!, LocationDetails.long!),
                  zoom: 100,
                ),
                markers: Set.from(markersList),
              ),
            ),
            widget.userType == "organizer"
                ? Column(
                    children: [
                      SizedBox(height: 10),
                      Text(
                        "Location",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Tap anywhere on the map to select a location for hosting an event",
                            textAlign: TextAlign.left,
                          )),
                      Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Divider()),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            locationValue,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: primaryButton("Add Event", () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddEventPage(
                                          locationCoordinates!))).then((value) {
                                if (value) {
                                  getEvents();
                                }
                              });
                            })),
                      ),
                    ],
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: primaryButton("Become Organizer", () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      OrganizerRegisterPage()),
                              (context) => false);
                        })),
                  )
          ],
        ),
      ),
    );
  }

  Future<List<Placemark>> convert() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        locationCoordinates!.latitude, locationCoordinates!.longitude);
    return placemarks;
  }

  void _zoomOut() async {
    // Get the current camera position
    final currentZoom = await mapController!.getZoomLevel();
    final LatLng initialCameraPosition =
        LatLng(LocationDetails.lat!, LocationDetails.long!);
    // Decrease the zoom level (adjust the decrement as needed)
    final newZoom = (100 - _currentSliderValue) / 5;

    // Create a new camera position with the updated zoom level
    final newCameraPosition = CameraPosition(
      target: initialCameraPosition,
      zoom: newZoom,
    );

    // Animate the camera to the new position
    mapController!
        .animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  }
}
