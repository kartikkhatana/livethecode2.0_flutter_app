import 'package:event_app/pages/intro.dart';
import 'package:event_app/pages/map_page.dart';
import 'package:event_app/pages/organizer/add_event.dart';
import 'package:event_app/pages/organizer/organizer_login.dart';
import 'package:event_app/provider/loadingProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'colors.dart';

void main() {
   runApp(ProviderScope(child: MyApp()));

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Relief',
      builder: (context, child) {
        return Scaffold(
          body: Stack(
            children: [
              child!,
              Consumer(builder: (context, ref, child) {
                return Visibility(
                  visible: ref.watch(isLoading),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.black12),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: MyColors.primary,
                      ),
                    ),
                  ),
                );
              })
            ],
          ),
        );
      },
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: IntroductionPage(),
    );
  }
}