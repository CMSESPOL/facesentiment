import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import 'shared/customs.dart';

class Capture extends StatefulWidget {
  @override
  _CaptureState createState() => _CaptureState();
}

class _CaptureState extends State<Capture> {
  GlobalKey<ScaffoldState> _snack = GlobalKey<ScaffoldState>();
  Image _result;

  _takePicture() {
    _snack.currentState.showSnackBar(SnackBar(
      content: ActionCapture(onCapture: (file) {
        if (file != null)
          _onCapture(Image.file(file));
        else {
          Fluttertoast.showToast(
              msg: "Error al obtener la imagen",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM);
          _onCapture(null);
        }
      }),
    ));
  }

  _onCapture(Image image) {
    setState(() {
      _result = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      body: Container(
        key: _snack,
        child: Center(
          child: ListView(
            children: <Widget>[
              _result == null ?
                NotImageFound(size: size)
              : Container(child: _result, width: size,)
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: Icon(Icons.camera),
      ),
    );
  }
}

class NotImageFound extends StatelessWidget {
  const NotImageFound({
    Key key,
    @required this.size,
  }) : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Icon(
            Icons.image,
            size: size,
            color: Color.fromRGBO(0, 0, 0, 0.2),
          ),
          Text(
            "No ha seleccionado una imagen",
            style: TextStyle(fontSize: 16, color: Colors.blueGrey),
          )
        ],
      ),
    );
  }
}

class ActionCapture extends StatelessWidget {
  final Function(File result) onCapture;

  final ImagePicker _picker = ImagePicker();

  ActionCapture({Key key, this.onCapture}) : super(key: key);

  _onCapture(ImageSource source) async {
    final image = await _picker.getImage(source: source);
    if (image != null) {
      File file = File(image.path);
      onCapture(file);
    } else
      onCapture(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ActionItem(
          icon: Icons.camera_alt,
          title: "Cámara",
          onTap: () => _onCapture(ImageSource.camera),
        ),
        ActionItem(
          icon: Icons.photo,
          title: "Fotos",
          onTap: () => _onCapture(ImageSource.gallery),
        )
      ],
    );
  }
}
