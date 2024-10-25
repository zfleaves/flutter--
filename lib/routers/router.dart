import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jingdong/pages/Collect.dart';
import 'package:flutter_jingdong/pages/Welcome.dart';

import '../pages/ProductContent.dart';
import '../pages/ProductList.dart';
import '../pages/tabs/Cart.dart';
import '../pages/Address/AddressAdd.dart';
import '../pages/Address/AddressEdit.dart';
import '../pages/Address/AddressList.dart';
import '../pages/CheckOut.dart';
import '../pages/Login.dart';
import '../pages/Order.dart';
import '../pages/OrderInfo.dart';
import '../pages/Pay.dart';
import '../pages/RegisterFirst.dart';
import '../pages/RegisterSecond.dart';
import '../pages/RegisterThird.dart';
import '../pages/tabs/Tabs.dart';

// 引入Search 页面
import '../pages/Search.dart';
// 商品列表页面

final routes = {
  '/': (context) => const WelcomePage(),
  '/home': (context) => const Tabs(),
  '/search': (context, {arguments}) => SearchPage(arguments: arguments),
  '/cart': (context) => const CartPage(),
  '/login': (context) => const LoginPage(),
  '/registerFirst': (context) => const RegisterFirstPage(),
  '/registerSecond': (context, {arguments}) =>
      RegisterSecondPage(arguments: arguments),
  '/registerThird': (context, {arguments}) =>
      RegisterThirdPage(arguments: arguments),
  '/productList': (context, {arguments}) =>
      ProductListPage(arguments: arguments),
  '/productContent': (context, {arguments}) =>
      ProductContentPage(arguments: arguments),
  '/checkOut': (context, {arguments}) => CheckOutPage(arguments: arguments),
  '/addressAdd': (context) => const AddressAddPage(),
  '/addressEdit': (context, {arguments}) =>
      AddressEditPage(arguments: arguments),
  '/addressList': (context, {arguments}) =>
      AddressListPage(arguments: arguments),
  '/pay': (context) => const PayPage(),
  '/order': (context, {arguments}) => OrderPage(arguments: arguments),
  '/orderinfo': (context, {arguments}) => OrderInfoPage(arguments: arguments),
  '/collect': (context) => const CollectPage(),
};

// Material组件库中提供了一个MaterialPageRoute组件，它可以使用和平台风格一致的路由切换动画，
// 如在iOS上会左右滑动切换，而在Android上会上下滑动切换 , CupertinoPageRoute是Cupertino组件
// 库提供的iOS风格的路由切换组件如果在Android上也想使用左右切换风格，可以使用
// CupertinoPageRoute。

// 固定写法，也可以相当于一个中间件，这里可以做权限判断
var onGenerateRoute = (RouteSettings settings) {
// 统一处理
  final String? name = settings.name;
  final Function? pageContentBuilder = routes[name];
  if (pageContentBuilder != null) {
    if (settings.arguments != null) {
      final Route route = CupertinoPageRoute(
          builder: (context) =>
              pageContentBuilder(context, arguments: settings.arguments));
      return route;
    } else {
      final Route route =
          CupertinoPageRoute(builder: (context) => pageContentBuilder(context));
      return route;
    }
  }
  return null;
};
