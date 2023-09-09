import 'package:event_app/apis/events.dart';
import 'package:event_app/pages/buttons.dart';
import 'package:event_app/pages/textfields.dart';
import 'package:event_app/provider/loadingProvider.dart';
import 'package:event_app/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class AddEventPage extends StatefulWidget {
  LatLng coord;
  AddEventPage(this.coord);

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final nameC = TextEditingController();
  final descC = TextEditingController();
  String? eventType;
  DateTime? startDate;
  DateTime? endDate;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios)),
                  Text(
                    "Add Event",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  )
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    formFields("Event Name", nameC),
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 1.5,
                            color: Colors.black12,
                          )),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 14),
                        child: DropdownButton<String>(
                          value: eventType,
                          isDense: true,
                          isExpanded: true,
                          hint: const Text(
                            "Select Event Type",
                            style: TextStyle(fontSize: 16),
                          ),
                          icon: const Icon(Icons.arrow_drop_down),
                          underline: Container(
                            height: 0,
                          ),
                          style: const TextStyle(color: Colors.blue),
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              eventType = value;
                            });
                          },
                          items: [
                            'Food Donation',
                            'Blood Donation',
                            'Clothes Donation',
                            'Awareness Camp'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    formFields("Event Description", descC, min: 4),
                    SizedBox(height: 30),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        DatePicker.showDateTimePicker(context,
                            showTitleActions: true,
                            minTime: DateTime.now(),
                            maxTime: DateTime.now().add(Duration(days: 30)),
                            onChanged: (date) {}, onConfirm: (date) {
                          setState(() {
                            startDate = date;
                          });
                        }, currentTime: DateTime.now(), locale: LocaleType.en);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black12, width: 1),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: startDate != null
                              ? Text(
                                  DateFormat.yMMMMd()
                                      .add_jms()
                                      .format(startDate!),
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                )
                              : Text(
                                  "Start Date",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black54),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        DatePicker.showDateTimePicker(context,
                            showTitleActions: true,
                            minTime: DateTime.now(),
                            maxTime: DateTime.now().add(Duration(days: 30)),
                            onChanged: (date) {}, onConfirm: (date) {
                          setState(() {
                            endDate = date;
                          });
                        }, currentTime: DateTime.now(), locale: LocaleType.en);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black12, width: 1),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: endDate != null
                              ? Text(
                                  DateFormat.yMMMMd()
                                      .add_jms()
                                      .format(endDate!),
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                )
                              : Text(
                                  "End Date",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black54),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Consumer(builder: (context, ref, child) {
                      return Container(
                          width: MediaQuery.of(context).size.width,
                          child: primaryButton("Add", () async {
                            if (nameC.text.isNotEmpty &&
                                eventType != null &&
                                startDate != null &&
                                endDate != null) {
                              ref.read(isLoading.notifier).state = true;
                              try {
                                await EventAPI.addEvent(
                                        nameC.text,
                                        eventType!,
                                        descC.text,
                                        widget.coord.latitude,
                                        widget.coord.longitude,
                                        startDate!,
                                        endDate!)
                                    .then((value) {
                                  if (value != null) {
                                    showSnackBar(
                                        context, "Event added successfully");
                                    Navigator.pop(context, true);
                                  }
                                }).catchError((e) {
                                  if (e != null && e['error'] != null) {
                                    showSnackBar(
                                        context, e['error']['message']);
                                  }
                                });
                              } catch (e) {
                                showSnackBar(context, e.toString());
                              }
                              ref.read(isLoading.notifier).state = false;
                            } else {
                              showSnackBar(context,
                                  "Please fill all the compulsory fields");
                            }
                          }));
                    })
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
