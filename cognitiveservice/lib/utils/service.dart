import 'dart:io';

import 'package:dio/dio.dart';
import '../models/sentiment.dart';
import 'const.dart';

class EmotionApi {
  
  final String _api = 'face/v1.0/detect';
  final String _params  = "returnFaceId=true&returnFaceLandmarks=false&returnFaceAttributes=emotion&recognitionModel=recognition_01&returnRecognitionModel=false&detectionModel=detection_01";
  final _dio = Dio();

  static EmotionApi instance = EmotionApi._();

  EmotionApi._(){
    _dio.options.headers['Ocp-Apim-Subscription-Key'] = Const.API_KEY;
    //_dio.options.headers['content-type'] = 'application/octet-stream';
  }

  Future<Emotion> emotionReconigtion(File image) async {
    final url = "${Const.ENDPOINT}$_api?$_params";
    
    String imgUrl = await _getUrlImage(image);
    try {
      Response response = await _dio.post(url, data: {'url': imgUrl});
      if((response.data as List).length > 0){
        FaceEmotion face = FaceEmotion.fromJson(response.data[0]);  
        return face.faceAttributes.emotion;
      }
    } catch (e) {
      print(e);
    }
    return Emotion();
  }

  Future<String> _getUrlImage(File image) async {
    String url = "https://api.imgur.com/3/image";
    Dio client = Dio();
    client.options.headers['Authorization'] = 'Client-ID ' + Const.IMGUR_CLIENT_ID;

    String fileName = image.path.split('/').last;
    FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(image.path, filename: fileName) 
    });
    Response resp = await client.post(url, data: formData);
    return resp.data['data']['link'];
  }

}