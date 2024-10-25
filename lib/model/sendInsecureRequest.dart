import 'dart:io';  
import 'dart:convert';

import 'package:flutter_jingdong/model/FocusModel.dart';
import 'package:flutter_jingdong/model/Product.dart';
  
Future sendInsecureRequest(String url) async {  
  // 创建一个自定义的HttpClient实例，禁用SSL证书验证  
  HttpClient httpClient = HttpClient()  
    ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;  
  
  // 创建一个URI对象  
  Uri uri = Uri.parse(url);  
  
  // 发送GET请求  
  HttpClientRequest request = await httpClient.getUrl(uri);  
  HttpClientResponse response = await request.close();
  
  // 读取响应体  
  String responseBody = await response.transform(Utf8Decoder()).join();  

  Map<String, dynamic> jsonMap = jsonDecode(responseBody);

  List<dynamic> resultList = jsonMap['result'] as List<dynamic>;

  return resultList;
  
  // // 关闭HttpClient  
  // httpClient.close();  
  
  // // 返回响应体  
  // return jsonMap;
  // return responseBody;  
  // return response;
}   

Future sendInsecureRequestObject(String url) async {  
  // 创建一个自定义的HttpClient实例，禁用SSL证书验证  
  HttpClient httpClient = HttpClient()  
    ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;  
  
  // 创建一个URI对象  
  Uri uri = Uri.parse(url);  
  
  // 发送GET请求  
  HttpClientRequest request = await httpClient.getUrl(uri);  
  HttpClientResponse response = await request.close();
  
  // 读取响应体  
  String responseBody = await response.transform(Utf8Decoder()).join();  
  // 假设你的JSON数据是嵌套在"result"字段下的  
  Map<String, dynamic> jsonMap = jsonDecode(responseBody)['result'];
  Product product = Product.fromMap(jsonMap);
  return product;
}     
