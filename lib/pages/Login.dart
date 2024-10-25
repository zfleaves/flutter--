import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jingdong/components/JdButton.dart';
import 'package:flutter_jingdong/components/JdText.dart';
import 'package:flutter_jingdong/config/Config.dart';
import 'package:flutter_jingdong/services/EventBus.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';
import 'package:flutter_jingdong/services/Storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String username = '';
  String password = '';

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    eventBus.fire(UserEvent('登录成功...'));
  }

  // 登录
  doLogin() async {
    RegExp reg = RegExp(r"^1\d{10}$");
    if (!reg.hasMatch(username)) {
      Fluttertoast.showToast(
        msg: '手机号格式不对',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }
    if (password.length < 6) {
      Fluttertoast.showToast(
        msg: '密码不能小于6位',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }
    var api = '${Config.domain}api/doLogin';
    var response = await Dio().post(api, data: {"username": username, "password": password});
    if (response.data["success"]) {
        //保存用户信息
        Storage.setString('userInfo', json.encode(response.data["userinfo"]));
        // Navigator.pushReplacementNamed(context, 'user');
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
          msg: '${response.data["message"]}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
  }

  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          icon: Icon(Icons.close)
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {}, 
            child: const Text('客服')
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(ScreenAdapter.width(20)),
        child: ListView(
          children: <Widget>[
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 30),
                height: ScreenAdapter.width(160),
                width: ScreenAdapter.width(160),
                child: Image.network('https://www.itying.com/images/flutter/list5.jpg', fit: BoxFit.cover,),
              ),
            ),
            SizedBox(
              height: ScreenAdapter.height(30),
            ),
            JdText(
              text: '请输入用户名',
              onChanged: (value) {
                username = value;
              },
            ),
            SizedBox(
              height: ScreenAdapter.height(10),
            ),
            JdText(
              text: '请输入密码',
              password: true,
              onChanged: (value) {
                password = value;
              },
            ),
            SizedBox(
              height: ScreenAdapter.height(10),
            ),
            Container(
              padding: EdgeInsets.all(ScreenAdapter.width(20)),
              child: Stack(
                children: <Widget>[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('忘记密码'),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/registerFirst');
                      },
                      child: const Text('新用户注册'),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            JdButton(
              text: '登录',
              color: Colors.red,
              height: 74,
              cb: doLogin,
            )
          ],
        ),
      )
    );
  }
}