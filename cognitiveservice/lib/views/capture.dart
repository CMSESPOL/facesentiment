import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../models/sentiment.dart';
import '../utils/service.dart';
import 'shared/customs.dart';

class Capture extends StatefulWidget {
  @override
  _CaptureState createState() => _CaptureState();
}

class _CaptureState extends State<Capture> {
  GlobalKey<ScaffoldState> _snack = GlobalKey<ScaffoldState>();
  Image _result;
  double size;
  Emotion _emotion = Emotion();
  bool _change = false;

  _takePicture() async {
    _change = false;
    _snack.currentState.showSnackBar(SnackBar(
      content: ActionCapture(width: size, onCapture: (file) async {
        if (file != null){
          _onCapture(Image.file(file, width: size,));
          _emotion = await EmotionApi.instance.emotionReconigtion(file);
          _change = true;
          setState(() {});
        }else {
          Fluttertoast.showToast(
              msg: "Error al obtener la imagen",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM);
          _onCapture(null);
        }
      }),
    ));
  }

  _onCapture(Image image) async {
    setState(() {
      _result = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      key: _snack,
      body: Container(
        child: Center(
          child: ListView(
            children: <Widget>[
              _result == null ?
                NotImageFound(size: size)
              : ResultImageValue(size: size, result: _result, emotion: _emotion, change: _change,)
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

class ResultImageValue extends StatelessWidget {
  const ResultImageValue({
    Key key,
    @required this.size,
    @required Image result,
    @required Emotion emotion,
    this.change
  }) : _result = result, _emotion = emotion, super(key: key);

  final double size;
  final Image _result;
  final Emotion _emotion;
  final bool change;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      child: Column(
        children: [
          Stack(
            alignment: AlignmentDirectional.topCenter,
            children: [
              _result,
              change ?
                Image.asset('assets/emojies/${_emotion.resolute()}.png', width: size*0.5,)
              : Visibility(child: Container(), visible: false,)
            ],
          ),
          SizedBox(height: 10,),
          Text('Resultados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
          SizedBox(height: 5,),
          change ?
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: _emotion.toJson()
              .map((key, value) => 
              MapEntry(key, Text('${key[0].toUpperCase()}${key.substring(1)}: $value'))).values.toList())
          : Center(
            child: CircularProgressIndicator(),
          )
        ],
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
  final double width;

  ActionCapture({Key key, this.onCapture, this.width}) : super(key: key);

  _onCapture(ImageSource source) async {
    final image = await _picker.getImage(source: source, maxWidth: width);
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
