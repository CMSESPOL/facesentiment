import 'package:flutter/material.dart';

import 'navigator.dart';

void main() {
  runApp(FaceSentiment());
}

class FaceSentiment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FaceSentiment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainNavigator(),
    );
  }
}


