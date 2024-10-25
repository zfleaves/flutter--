import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jingdong/components/JdButton.dart';
import 'package:flutter_jingdong/components/LoadingWidget.dart';
import 'package:flutter_jingdong/components/favorite_button.dart';
import 'package:flutter_jingdong/components/feedback_widget.dart';
import 'package:flutter_jingdong/config/Config.dart';
import 'package:flutter_jingdong/model/ProductContentModel.dart';
import 'package:flutter_jingdong/pages/ProductContent/Product.dart';
import 'package:flutter_jingdong/pages/ProductContent/ProductComment.dart';
import 'package:flutter_jingdong/pages/ProductContent/ProductDetail.dart';
import 'package:flutter_jingdong/provider/Cart.dart';
import 'package:flutter_jingdong/provider/Collect.dart';
import 'package:flutter_jingdong/services/CartServices.dart';
import 'package:flutter_jingdong/services/CollectServices.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';

// 广播
import 'package:flutter_jingdong/services/EventBus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class ProductContentPage extends StatefulWidget {
  final Map arguments;
  const ProductContentPage({super.key, required this.arguments});

  @override
  State<ProductContentPage> createState() => _ProductContentPageState();
}

class _ProductContentPageState extends State<ProductContentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // 详情页面数据
  final List _productContentList = [];
  

  // 请求数据
  _getProductContent() async {
    var api = '${Config.domain}api/pcontent?id=${widget.arguments['id']}';
    var response = await Dio().get(api);
    print(response);
    var productContent = ProductContentModel.fromJson(response.data);
    // print(response);
    setState(() {
      _productContentList.add(productContent.result);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _getProductContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var cartProvider = Provider.of<Cart>(context);
    var collectProvider = Provider.of<Collect>(context);
    bool isCollect = _productContentList.isNotEmpty ? collectProvider.collectList.any((val) {
      return val['id'] == _productContentList[0].id;
    }) : false;
    ScreenAdapter.init(context);
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: ScreenAdapter.width(400),
                child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.white,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: const [
                      Tab(
                        child: Text("商品"),
                      ),
                      Tab(
                        child: Text("详情"),
                      ),
                      Tab(
                        child: Text("评价"),
                      ),
                    ]),
              )
            ],
          ),
          actions: <Widget>[
            FeedbackWidget(
               onPressed: () async {
                // await CollectServices.removeCollect();
                await CollectServices.toggleCollect(_productContentList[0]);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isCollect ? '已取消收藏' : '已收藏'),
                    duration: const Duration(seconds: 1),
                  )
                );
                collectProvider.updateCollectList();
              }, 
              child: Icon(Icons.favorite, color: isCollect ? Colors.pink : Colors.grey, size: 25,)
            ),
            IconButton(
                onPressed: () {
                  showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                          ScreenAdapter.width(600), 76, 10, 0),
                      items: [
                        PopupMenuItem(
                            onTap: () {
                              Navigator.pushNamed(context, '/');
                            },
                            child: const Row(
                              children: [Icon(Icons.home), Text('首页')],
                            )),
                        PopupMenuItem(
                            onTap: () {
                              Navigator.pushNamed(context, '/search');
                            },
                            child: const Row(
                              children: [Icon(Icons.home), Text('搜索')],
                            ))
                      ]);
                },
                icon: const Icon(Icons.more_horiz))
          ],
        ),
        body: _productContentList.isNotEmpty
            ? Stack(
                children: [
                  TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _tabController,
                      children:  [
                          ProductPage(_productContentList, widget.arguments['imageUrl']),
                          // ProductDetailPage(_productContentList),
                          ProductDetailPage(_productContentList),
                          // Text('2222'),
                          const ProductCommentPage()
                        ]
                      ),
                  Positioned(
                      width: ScreenAdapter.width(750),
                      height: ScreenAdapter.width(146),
                      bottom: 0,
                      child: Container(
                        padding:
                            EdgeInsets.only(bottom: ScreenAdapter.height(26)),
                        decoration: const BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Colors.black26, width: 1))),
                        child: Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(
                                  bottom: ScreenAdapter.height(10)),
                              width: 100,
                              height: ScreenAdapter.height(146),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/cart');
                                },
                                child: const Column(
                                  children: [
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Icon(Icons.shopping_cart),
                                    Text('购物车')
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: JdButton(
                                color: const Color.fromRGBO(253, 1, 0, 0.9),
                                text: "加入购物车",
                                cb: () async {
                                  if (_productContentList[0].attr.length > 0) {
                                    //广播 弹出筛选
                                    eventBus.fire(ProductContentEvent('加入购物车'));
                                  } else {
                                    await CartServices.addCart(
                                        _productContentList[0]);
                                    // 调用Provider更新数据
                                    cartProvider.updateCartList();
                                  }
                                },
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: JdButton(
                                  color: const Color.fromRGBO(255, 165, 0, 0.9),
                                  text: '立即购买',
                                  cb: () async {
                                    if (_productContentList[0].attr.length >
                                        0) {
                                      //广播 弹出筛选
                                      eventBus
                                          .fire(ProductContentEvent('立即购买'));
                                    } else {
                                      print("立即购买");
                                    }
                                  },
                                ))
                          ],
                        ),
                      ))
                ],
              )
            : const LoadingWidget(
                text: '商品详情加载中',
              ));
  }
}
