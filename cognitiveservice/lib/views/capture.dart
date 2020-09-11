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
      content: ActionCapture(
          width: size,
          onCapture: (file) async {
            if (file != null) {
              _onCapture(Image.file(
                file,
                width: size,
              ));
              showDialog(
                  context: context,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ));
              _emotion = await EmotionApi.instance.emotionReconigtion(file);
              _change = true;
              setState(() {});
              Navigator.pop(context);
            } else {
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
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: _result == null
            ? NotImageFound(size: size)
            : Center(
                child: ResultImageValue(
                  size: size,
                  result: _result,
                  emotion: _emotion,
                  change: _change,
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _takePicture,
        child: Icon(Icons.camera),
      ),
    );
  }
}

class ResultImageValue extends StatelessWidget {
  const ResultImageValue(
      {Key key,
      @required this.size,
      @required Image result,
      @required Emotion emotion,
      this.change})
      : _result = result,
        _emotion = emotion,
        super(key: key);

  final double size;
  final Image _result;
  final Emotion _emotion;
  final bool change;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      child: ListView(
        shrinkWrap: true,
        children: [
          change
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Center(
                      child: Text("${_emotion.compute?.toUpperCase()}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ))),
                )
              : Container(),
          Stack(
            alignment: AlignmentDirectional.topCenter,
            children: [
              _result,
              change
                  ? Image.asset(
                      'assets/emojies/${_emotion.compute}.png',
                      width: size * 0.5,
                    )
                  : Visibility(
                      child: Container(),
                      visible: false,
                    )
            ],
          ),
          change
              ? ResultView(
                  emotion: _emotion,
                )
              : Container(),
          IconButton(
            icon: Icon(Icons.share,),
            onPressed: () {},
            color: Colors.teal,
            tooltip: "Compartir",
          )
        ],
      ),
    );
  }
}

class ResultView extends StatelessWidget {
  const ResultView({Key key, this.emotion}) : super(key: key);

  final Emotion emotion;

  MapEntry<String, Text> _buildResults(key, value) {
    String upper = key[0].toUpperCase();
    String percent = (value * 100 as double).toStringAsPrecision(2);
    return MapEntry(key, Text('$upper${key.substring(1)}: $percent%'));
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text('Más detalles'),
      children: <Widget>[
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: emotion.toJson().map(_buildResults).values.toList())
      ],
    );
  }
}

class NotImageFound extends StatelessWidget {
  NotImageFound({
    Key key,
    @required this.size,
  }) : super(key: key);

  final double size;
  final List<String> emojies = [
    "anger",
    "disgust",
    "fear",
    "happiness",
    "neutral",
    "sadness",
    "surprise"
  ];

  Widget _buildEmojie(String emojie) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image.asset(
          'assets/emojies/$emojie.png',
          width: size * 0.5,
        ),
        Center(
          child: Text(emojie),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: size,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text(
                  "¿Quiéres saber que sentimiento expresa tu rostro?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: 1.0,
                crossAxisCount: 4,
                children: emojies.map(_buildEmojie).toList(),
              )
            ],
          ),
        ));
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
