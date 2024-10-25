import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_jingdong/config/Config.dart';
import 'package:flutter_jingdong/model/sendInsecureRequest.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import '../../model/FocusModel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  // 轮播数据
  List _focusData = [];

  // 猜你喜欢数据
  List _hotProductData = [];

  // 获取热门推荐商品
  List _bestProductData = [];

  @override
  void initState() {
    super.initState();
    // 获取轮播图数据
    _getFocusData();
    // 获取猜你喜欢数据
    _getHotProductData();
    // 获取热门推荐商品
    _getBestProductData();
  }

  // 获取轮播图数据
  _getFocusData() async {
    var api = '${Config.domain}api/focus';
    var result = await Dio().get(api);
    // var result = await sendInsecureRequest(api);
    setState(() {
      _focusData = result.data['result'];
    });
  }

  // 轮播组件
  Widget _swiperBuilder() {
    if (_focusData.isNotEmpty) {
      return AspectRatio(
        aspectRatio: 2 / 1,
        child: Swiper(
          itemBuilder: (BuildContext context, int index) {
            // print(_focusData[index]);
            String pic = _focusData[index]['pic'];
            pic = Config.domain + pic.replaceAll('\\', '/');
            return Image.network(
              pic,
              fit: BoxFit.fill,
            );
          },
          itemCount: _focusData.length,
          autoplay: true,
          pagination: const SwiperPagination(),
        ),
      );
    }
    return const Text('加载中...');
  }

  // 标题组件
  Widget _titleBuilder(String title) {
    return Container(
      height: ScreenAdapter.height(32),
      margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
      padding: EdgeInsets.only(left: ScreenAdapter.width(20)),
      decoration: BoxDecoration(
          border: Border(
              left: BorderSide(
                  color: Colors.red, width: ScreenAdapter.width(10)))),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black54,
          fontSize: ScreenAdapter.size(24),
          height: ScreenAdapter.height(2.4),
        ),
      ),
    );
  }

  // 获取猜你喜欢数据
  _getHotProductData() async {
    try {
      var api = '${Config.domain}api/plist?is_hot=1';
      var result = await Dio().get(api);
      // print(result);
      setState(() {
        _hotProductData = result.data['result'];
      });
    } catch (e) {
      print(e);
    }
  }

  // 猜你喜欢
  Widget _hotProductList() {
    if (_hotProductData.isNotEmpty) {
      return Container(
          height: ScreenAdapter.height(234),
          padding: EdgeInsets.all(ScreenAdapter.width(20)),
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _hotProductData.length,
              itemBuilder: (BuildContext context, int index) {
                // 图片转换格式
                String pic = _hotProductData[index]['pic'];
                pic = Config.domain + pic.replaceAll('\\', '/');
                return GestureDetector(
                  onTap: () {
                    // print(_hotProductData[index]);
                    Navigator.pushNamed(context, '/productContent', arguments: {
                      'id': _hotProductData[index]['_id'],
                      'imageUrl': pic
                    });
                  },
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: ScreenAdapter.width(21)),
                        height: ScreenAdapter.height(140),
                        width: ScreenAdapter.width(140),
                        child: Image.network(
                          pic,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        height: ScreenAdapter.height(44),
                        alignment: Alignment.center,
                        width: ScreenAdapter.width(140),
                        child: Text(
                          '${_hotProductData[index]['title']}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: ScreenAdapter.size(24),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }));
    }
    return const Text('加载中...');
  }

  // 获取热门推荐商品
  _getBestProductData() async {
    try {
      var api = '${Config.domain}api/plist?is_best=1';
      // var result = await sendInsecureRequest(api);
      var result = await Dio().get(api);
      setState(() {
        _bestProductData = result.data['result'];
      });
    } catch (e) {
      print(e);
    }
  }

  // 热门推荐
  Widget _recProductList() {
    if (_bestProductData.isNotEmpty) {
      return Container(
          padding: const EdgeInsets.all(10),
          child: Wrap(
            runSpacing: 10,
            spacing: 10,
            children: _recProductWrapList(),
          ));
    }
    return const Text('加载中...');
  }

  List<Widget> _recProductWrapList() {
    double itemWidth = (ScreenAdapter.getScreenWidth() - 30) / 2;
    List<Widget> list = [];
    for (var i = 0; i < _bestProductData.length; i++) {
      var item = _bestProductData[i];
      // 图片转换格式
      String pic = item['pic'];
      pic = Config.domain + pic.replaceAll('\\', '/');
      list.add(InkWell(
        onTap: () {
          // 路由跳转
          Navigator.pushNamed(context, '/productContent',
              arguments: {'id': item['_id'], 'imageUrl': pic});
        },
        child: Container(
          padding: const EdgeInsets.all(5),
          width: itemWidth,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromRGBO(233, 233, 233, 0.9),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: ScreenAdapter.height(280),
                // 自适应宽度
                width: double.infinity,
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: Image.network(
                    pic,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  item['title'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: ScreenAdapter.size(24),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '¥${item['price']}',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: ScreenAdapter.size(26),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "¥${item['old_price']}",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: ScreenAdapter.size(22),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/search');
          },
          child: Container(
            padding: const EdgeInsets.only(left: 10),
            height: ScreenAdapter.height(56),
            decoration: BoxDecoration(
              // color: const Color.fromRGBO(233, 233, 233, 0.8),
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.search,
                  size: 24,
                  color: Colors.black87,
                ),
                Text(
                  '笔记本',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.center_focus_weak,
            size: 28,
          ),
          onPressed: () {
            print('扫一扫');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.message,
              size: 28,
            ),
            onPressed: () {
              print('消息');
            },
          ),
        ],
      ),
      body: Center(
        child: ListView(
          children: [
            // 轮播
            _swiperBuilder(),
            const SizedBox(
              height: 10,
            ),
            _titleBuilder('猜你喜欢'),
            const SizedBox(
              height: 10,
            ),
            _hotProductList(),
            // 热门推荐
            _titleBuilder('热门推荐'),
            const SizedBox(
              height: 10,
            ),
            _recProductList()
          ],
        ),
      ),
    );
  }

  // 状态保持
  @override
  bool get wantKeepAlive => true;
}
