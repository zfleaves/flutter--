import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jingdong/components/JdButton.dart';
import 'package:flutter_jingdong/components/JdText.dart';
import 'package:flutter_jingdong/config/Config.dart';
import 'package:flutter_jingdong/pages/tabs/Tabs.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';
import 'package:flutter_jingdong/services/Storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterThirdPage extends StatefulWidget {
  final Map arguments;
  const RegisterThirdPage({super.key, required this.arguments});

  @override
  State<RegisterThirdPage> createState() => _RegisterThirdPageState();
}

class _RegisterThirdPageState extends State<RegisterThirdPage> {
  late String tel;
  late String code;
  String password = '';
  String rpassword = '';

  @override
  void initState() {
    super.initState();
    tel = widget.arguments['tel'];
    code = widget.arguments['code'];
  }

  //注册
  doRegister() async {
    if (password.length < 6) {
      return Fluttertoast.showToast(
        msg: '密码长度不能小于6位',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
    if (rpassword != password) {
      return Fluttertoast.showToast(
        msg: '密码和确认密码不一致',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
    var api = '${Config.domain}api/register';
    var response = await Dio().post(api, data: {
      "tel": widget.arguments['tel'],
      "code": widget.arguments['code'],
      "password": password
    });
    print(response);
    if (response.data["success"]) {
      Storage.setString('userInfo', json.encode(response.data["userinfo"]));
      //返回到根
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const Tabs(),
          ),
          (route) => false);
      return;
    }
    return Fluttertoast.showToast(
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
          title: const Text("用户注册-第三步"),
        ),
        body: Container(
          padding: EdgeInsets.all(ScreenAdapter.width(20)),
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: ScreenAdapter.height(50),
              ),
              JdText(
                text: '请输入密码',
                password: true,
                onChanged: (p0) => password = p0,
              ),
              SizedBox(
                height: ScreenAdapter.height(10),
              ),
              JdText(
                text: '请输入确认密码',
                password: true,
                onChanged: (p0) => rpassword = p0,
              ),
              SizedBox(
                height: ScreenAdapter.height(20),
              ),
              JdButton(
                text: "登录",
                color: Colors.red,
                height: 74,
                cb: doRegister,
              )
            ],
          ),
        ));
  }
}
