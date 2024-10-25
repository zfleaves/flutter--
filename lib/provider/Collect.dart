import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:flutter_jingdong/services/Storage.dart';

class Collect with ChangeNotifier {
  // 收藏数据
  List<dynamic> _collectList = <dynamic>[];

  List get collectList => _collectList;

  int get len => _collectList.length;

  int get checkedLen => _collectList.where((element) => element['checked']).toList().length;

  List get checkedList => _collectList.where((element) => element['checked']).toList();

  Collect() {
    init();
  }

  // 初始化获取数据
  init() async {
    try {
      List collectListData = json.decode(await Storage.getString('collectList') as String);
      _collectList = collectListData;
    } catch (e) {
      _collectList = [];
    }
    notifyListeners();
  }

  // 更新数据
  updateCollectList() {
    init();
  }


  // 勾选
  changeItemCheck(id, flag) {
    for (var i = 0; i < _collectList.length; i++) {
      if (_collectList[i]['id'] == id) {
        _collectList[i]["checked"] = flag;
      }
    }
    notifyListeners();
  }

  // 全选， 反选
  changeCheckAll(flag) {
    for (var i = 0; i < _collectList.length; i++) {
      _collectList[i]["checked"] = flag;
    }
    notifyListeners();
  }
}