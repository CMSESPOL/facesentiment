import 'package:flutter/material.dart';

import 'navigator.dart';

void main() {
  runApp(FaceSentiment());
}

class FaceSentiment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FaceSentiment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          color: Colors.teal,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainNavigator(),
    );
  }
}


