import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jingdong/components/JdButton.dart';
import 'package:flutter_jingdong/components/JdText.dart';
import 'package:flutter_jingdong/config/Config.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterSecondPage extends StatefulWidget {
  final Map arguments;
  const RegisterSecondPage({super.key, required this.arguments});

  @override
  State<RegisterSecondPage> createState() => _RegisterSecondPageState();
}

class _RegisterSecondPageState extends State<RegisterSecondPage> {
  late String tel;
  bool sendCodeBtn = false;
  int seconds = 30;
  late String code;

  @override
  void initState() {
    super.initState();
    tel = widget.arguments['tel'];
    _showTimer();
  }

  //重新发送验证码
  sendCode() async {
    setState(() {
      sendCodeBtn = false;
      seconds = 30;
      _showTimer();
    });
    var api = '${Config.domain}api/sendCode';
    var response = await Dio().post(api, data: {"tel": tel});
    if (response.data["success"]) {
      print(response); //演示期间服务器直接返回  给手机发送的验证码
    }
  }

  _showTimer() {
    Timer? t;
    t = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds > 0) {
        setState(() {
          seconds--;
        });
      } else {
        if (seconds == 0) {
          // 清除定时器
          t!.cancel();
          setState(() {
            sendCodeBtn = true;
            seconds = 30;
          });
        }
      }
    });
  }

  //验证验证码
  validateCode() async {
    var api = '${Config.domain}api/validateCode';
    var response = await Dio().post(api, data: {'tel': tel, 'code': code});
    if (response.data["success"]) {
      return Navigator.pushNamed(context, '/registerThird',
          arguments: {'tel': tel, "code": code});
    }
    Fluttertoast.showToast(
      msg: '${response.data["message"]}',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("用户注册-第二步"),
        ),
        body: Container(
            padding: EdgeInsets.all(ScreenAdapter.width(20)),
            child: ListView(
              children: <Widget>[
                SizedBox(height: ScreenAdapter.height(50)),
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text("验证码已经发送到了您的$tel手机，请输入$tel手机号收到的验证码"),
                ),
                SizedBox(height: ScreenAdapter.height(40)),
                Stack(
                  children: <Widget>[
                    JdText(
                      text: '请输入验证码',
                      onChanged: (p0) => code = p0,
                    ),
                    Positioned(
                        right: 0,
                        top: 0,
                        child: sendCodeBtn
                            ? ElevatedButton(
                                onPressed: sendCode, child: const Text('重新发送'))
                            : ElevatedButton(
                                onPressed: null, child: Text('$seconds秒后重发')))
                  ],
                ),
                SizedBox(height: ScreenAdapter.height(20)),
                JdButton(
                  text: "下一步",
                  color: Colors.red,
                  height: 74,
                  cb: validateCode,
                )
              ],
            )));
  }
}
