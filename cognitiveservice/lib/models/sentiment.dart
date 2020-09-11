class FaceEmotion {
  FaceEmotion({
    this.faceRectangle,
    this.faceAttributes,
  });

  FaceRectangle faceRectangle;
  FaceAttributes faceAttributes;

  factory FaceEmotion.fromJson(Map<String, dynamic> json) => FaceEmotion(
        faceRectangle: FaceRectangle.fromJson(json["faceRectangle"]),
        faceAttributes: FaceAttributes.fromJson(json["faceAttributes"]),
      );

  Map<String, dynamic> toJson() => {
        "faceRectangle": faceRectangle.toJson(),
        "faceAttributes": faceAttributes.toJson(),
      };
}

class FaceAttributes {
  FaceAttributes({
    this.emotion,
  });

  Emotion emotion;

  factory FaceAttributes.fromJson(Map<String, dynamic> json) => FaceAttributes(
        emotion: Emotion.fromJson(json["emotion"]),
      );

  Map<String, dynamic> toJson() => {
        "emotion": emotion.toJson(),
      };
}

class Emotion {
  Emotion({
    this.anger = 0,
    this.contempt = 0,
    this.disgust = 0,
    this.fear = 0,
    this.happiness = 0,
    this.neutral = 0,
    this.sadness = 0,
    this.surprise = 0,
  });

  double anger;
  double contempt;
  double disgust;
  double fear;
  double happiness;
  double neutral;
  double sadness;
  double surprise;

  factory Emotion.fromJson(Map<String, dynamic> json) => Emotion(
        anger: json["anger"].toDouble(),
        contempt: json["contempt"].toDouble(),
        disgust: json["disgust"].toDouble(),
        fear: json["fear"].toDouble(),
        happiness: json["happiness"].toDouble(),
        neutral: json["neutral"].toDouble(),
        sadness: json["sadness"].toDouble(),
        surprise: json["surprise"].toDouble(),
      );

  Map<String, double> toJson() => {
        "anger": anger,
        "contempt": contempt,
        "disgust": disgust,
        "fear": fear,
        "happiness": happiness,
        "neutral": neutral,
        "sadness": sadness,
        "surprise": surprise,
      };

  String get compute {
    final emotions = this.toJson().entries.toList()
      ..sort((a, b) => a.value < b.value ? 1 : -1);
    return emotions[0].value == 0 ? null : emotions[0].key;
  }
}

class FaceRectangle {
  FaceRectangle({
    this.top = 0,
    this.left = 0,
    this.width = 0,
    this.height = 0,
  });

  int top;
  int left;
  int width;
  int height;

  factory FaceRectangle.fromJson(Map<String, dynamic> json) => FaceRectangle(
        top: json["top"],
        left: json["left"],
        width: json["width"],
        height: json["height"],
      );

  Map<String, dynamic> toJson() => {
        "top": top,
        "left": left,
        "width": width,
        "height": height,
      };
}
