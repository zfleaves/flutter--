import 'dart:convert';

import 'Storage.dart';

class UserServices {
  // 获取用户信息
  static getUserInfo() async {
    List userInfo;
    try {
      List userInfoData = json.decode(await Storage.getString('userInfo') as String);
      userInfo = userInfoData;
    } catch (e) { 
      userInfo = [];
    }
    return userInfo;
  }

  // 用户登录状态
  static getUserLoginState<bool>() async {
    var userInfo = await UserServices.getUserInfo();
    return userInfo.length > 0 && userInfo[0]['userName'] != '';
  }

  // 退出登录
  static loginOut() {
    Storage.remove('userInfo');
  }
}