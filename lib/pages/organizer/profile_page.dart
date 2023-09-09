import 'package:flutter/material.dart';

class MyEvents extends StatefulWidget {
  const MyEvents({super.key});

  @override
  State<MyEvents> createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  "My Events",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                )
              ],
            ),
            SizedBox(height: 20),
            FutureBuilder(builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
            return Container();
            } else {
            return Container();
            }
            } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
            child: CircularProgressIndicator(),
            );
            } else {
            return Center(
            child: Text(''),
            );
            }
            })
          ],
        ),
      ),
    );
  }
}
