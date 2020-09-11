import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cognitiveservice/utils/result_draw.dart';
import 'package:cognitiveservice/utils/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../models/sentiment.dart';
import 'shared/customs.dart';

class Capture extends StatefulWidget {
  @override
  _CaptureState createState() => _CaptureState();
}

class _CaptureState extends State<Capture> {
  GlobalKey<ScaffoldState> _snack = GlobalKey<ScaffoldState>();
  Image _result;
  double size;
  FaceEmotion _emotion = FaceEmotion();
  bool _change = false;

  _load() {
    showDialog(
        context: context,
        child: Center(
          child: CircularProgressIndicator(),
        ));
  }

  _alert(String msg) {
    Fluttertoast.showToast(
        msg: msg, toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.BOTTOM);
  }

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
              _load();
              _emotion = await EmotionApi.instance.emotionReconigtion(file);
              if (_emotion != null) {
                _change = true;
                ByteData bytes = await ResultDrawer().draw(_emotion, file);
                _onCapture(
                    Image.memory(Uint8List.view(bytes.buffer), width: size));
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
                _alert("No se pudo reconocer la emoción");
                _onCapture(null);
              }
            } else {
              _alert("Error al obtener la imagen");
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
                  emotion: _emotion?.faceAttributes?.emotion,
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
          _result,
          change
              ? ResultView(
                  emotion: _emotion,
                )
              : Container(),
          change
              ? IconButton(
                  icon: Icon(
                    Icons.share,
                  ),
                  onPressed: () {},
                  color: Colors.teal,
                  tooltip: "Compartir",
                )
              : Container()
        ],
      ),
    );
  }
}

class ResultView extends StatefulWidget {
  const ResultView({Key key, this.emotion}) : super(key: key);

  final Emotion emotion;

  @override
  _ResultViewState createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  String _details = 'Más detalles';

  MapEntry<String, Text> _buildResults(key, value) {
    String upper = key[0].toUpperCase();
    String percent = (value * 100 as double).toStringAsPrecision(2);
    return MapEntry(key, Text('$upper${key.substring(1)}: $percent%'));
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(_details),
      onExpansionChanged: (value) {
        setState(() {
          _details = value ? 'Menos detalles' : 'Más detalles';
        });
      },
      children: <Widget>[
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children:
                widget.emotion.toJson().map(_buildResults).values.toList())
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
