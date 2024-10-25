import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_jingdong/pages/tabs/Tabs.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  int _timeCount = 6;
  Timer? _timer;
  String adStr = '广告5秒跳过';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  ///打开计时器
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        adStr = "广告$_timeCount秒跳过";
      });
      if (_timeCount <= 1) {
        openHomePage();
        return;
      }
      _timeCount--;
    });
  }

  ///停止计时器
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void openHomePage() {
    _stopTimer();
    //返回到根
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const Tabs(),
        ),
        (route) => false);
  }

  @override
  void dispose() {
    super.dispose();
    _stopTimer();
  }

  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('images/launch_image.png'),
                    fit: BoxFit.cover)),
          ),
          Positioned(
            right: ScreenAdapter.width(16),
            top: ScreenAdapter.height(30),
            child: InkWell(
              onTap: openHomePage,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Text(
                  adStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
        ],
      )),
    );
  }
}
