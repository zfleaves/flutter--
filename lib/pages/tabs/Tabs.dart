import 'package:flutter/material.dart';
import 'package:flutter_jingdong/components/KeepAliveWrapper.dart';
import 'package:flutter_jingdong/pages/tabs/Cart.dart';
import 'package:flutter_jingdong/pages/tabs/Category.dart';
import 'package:flutter_jingdong/pages/tabs/Home.dart';
import 'package:flutter_jingdong/pages/tabs/User.dart';
import 'package:flutter_jingdong/provider/Cart.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';
import 'package:provider/provider.dart';

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _currentIndex = 0;
  var _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  final List<Widget> _pageList = [
    // 首页
    const HomePage(),
    // 分类
    const KeepAliveWrapper(keepAlive: true, child: CategoryPage()),
    // 购物车
    const CartPage(),
    // 个人中心
    const UserPage()
  ];

  // 标题
  final List<String> _titleList = [
    '京东首页',
    '商品分类',
    '购物车',
    '用户中心',
  ];


  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    // 获取购物车数据
    var cartProvider = Provider.of<Cart>(context);
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // 不滑动
        physics: const NeverScrollableScrollPhysics(),
        children: _pageList,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
            _pageController.jumpToPage(index);
          });
        },
        type: BottomNavigationBarType.fixed,
        fixedColor: Colors.red,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: '分类',
          ),
          BottomNavigationBarItem(
            // icon: Icon(Icons.shopping_cart),
            icon: cartProvider.cartList.isNotEmpty ? Badge(
              label: Text('${cartProvider.cartList.length}'),
              backgroundColor: Colors.red,
              textStyle: const TextStyle(fontSize: 10, color: Colors.red),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: const Icon(Icons.shopping_cart),
            ) : const Icon(Icons.shopping_cart),
            label: '购物车',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '我的',
          ),
        ]
      ),
    );
  }
}