import 'package:cognitiveservice/views/about.dart';
import 'package:cognitiveservice/views/capture.dart';
import 'package:cognitiveservice/views/history.dart';
import 'package:flutter/material.dart';

class MainNavigator extends StatefulWidget {
  @override
  _MainNavigatorState createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  String _title;
  Widget _page;

  @override
  void initState() {
    _page = Capture();
    _title = "Capturar";
    super.initState();
  }

  _onPageChange(index, title) {
    setState(() {
      switch (index) {
        case 0:
          _page = Capture();
          break;
        case 1:
          _page = History();
          break;
        case 2:
          _page = About();
          break;
        default:
          _page = Text("Error");
          break;
      }
      _title = title;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        centerTitle: true,
      ),
      drawer: NavigatorDrawer(
        onPageChange: _onPageChange,
      ),
      body: _page,
    );
  }
}

class NavigatorDrawer extends StatelessWidget {
  final Function(int index, String title) onPageChange;
  const NavigatorDrawer({Key key, this.onPageChange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          ListTile(
            title: Text("Capturar"),
            leading: Icon(Icons.camera),
            onTap: () => onPageChange(0, "Capturar"),
          ),
          ListTile(
            title: Text("Historial"),
            leading: Icon(Icons.history),
            onTap: () => onPageChange(1, "Historial"),
          ),
          ListTile(
            title: Text("Acerca de"),
            leading: Icon(Icons.info_outline),
            onTap: () => onPageChange(2, "Acerca de"),
          )
        ],
      ),
    );
  }
}
