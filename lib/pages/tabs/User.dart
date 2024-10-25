import 'package:flutter/material.dart';
import 'package:flutter_jingdong/components/JdButton.dart';
import 'package:flutter_jingdong/provider/Counter.dart';
import 'package:flutter_jingdong/services/EventBus.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';
import 'package:flutter_jingdong/services/UserServices.dart';
import 'package:provider/provider.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool isLogin = false;
  List userInfo = [];

  @override
  void initState() {
    super.initState();
    _getUserInfo();

    //监听登录页面改变的事件
    eventBus.on<UserEvent>().listen((event) {
      _getUserInfo();
    });
  }

  _getUserInfo() async {
    var _isLogin = await UserServices.getUserLoginState();
    var _userInfo = await UserServices.getUserInfo();
    setState(() {
      isLogin = _isLogin;
      userInfo = _userInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    var counterProvider = Provider.of<Counter>(context);
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
            height: ScreenAdapter.height(220),
            width: double.infinity,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('images/user_bg.jpg'),
                    fit: BoxFit.cover)),
            child: Row(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ClipOval(
                    child: Image.asset(
                      'images/user.png',
                      fit: BoxFit.cover,
                      width: ScreenAdapter.width(100),
                      height: ScreenAdapter.width(100),
                    ),
                  ),
                ),
                !isLogin
                    ? Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            '登录/注册',
                            style: TextStyle(color: Colors.white),
                          ),
                        ))
                    : Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('用户名：${userInfo[0]['username']}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenAdapter.size(32),
                                )),
                            Text(
                              '普通会员',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenAdapter.size(24)),
                            ),
                          ],
                        ))
              ],
            ),
          ),
            ListTile(
            leading: const Icon(Icons.dns, color: Colors.grey),
            title: const Text("我的收货地址"),
            onTap: () => Navigator.pushNamed(context, '/addressList', arguments: {
              'uid': ''
            }),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.assignment, color: Colors.red),
            title: const Text("全部订单"),
            onTap: () => Navigator.pushNamed(context, '/order', arguments: {
              'payStatus': 0
            }),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.payment,
              color: Colors.green,
            ),
            title: const Text('待付款'),
            onTap: () => Navigator.pushNamed(context, '/order', arguments: {
              'payStatus': 1
            }),
          ),
          ListTile(
            leading: const Icon(
              Icons.local_car_wash,
              color: Colors.orange,
            ),
            title: const Text('待收货'),
            onTap: () => Navigator.pushNamed(context, '/order', arguments: {
              'payStatus': 2
            }),
          ),
          Container(
              width: double.infinity,
              height: 10,
              color: const Color.fromRGBO(242, 242, 242, 0.9)),
          ListTile(
            leading: const Icon(
              Icons.favorite,
              color: Colors.lightGreen,
            ),
            title: const Text('我的收藏'),
            onTap: () => Navigator.pushNamed(context, '/collect'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.people, color: Colors.black54),
            title: Text("在线客服2"),
          ),
          const Divider(),
          isLogin
              ? JdButton(
                  text: '退出登录',
                  cb: () {
                    UserServices.loginOut();
                    _getUserInfo();
                    // Navigator.pushReplacementNamed(context, '/login');
                  },
                )
              : const Text('')
        ],
      ),
    );
  }
}
