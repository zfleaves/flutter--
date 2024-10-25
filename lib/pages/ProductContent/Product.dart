import 'package:flutter/material.dart';
import 'package:flutter_jingdong/components/JdButton.dart';
import 'package:flutter_jingdong/model/Product.dart';
import 'package:flutter_jingdong/model/ProductContentModel.dart';
import 'package:flutter_jingdong/pages/ProductContent/CartNum.dart';
import 'package:flutter_jingdong/provider/Cart.dart';
import 'package:flutter_jingdong/services/CartServices.dart';
import 'package:flutter_jingdong/services/EventBus.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class ProductPage extends StatefulWidget {
  final List _productContentList;
  final String pic;
  const ProductPage(
    this._productContentList,
    this.pic, {
    super.key,
  });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // 详情页面数据
  late ProductItemModel _productContent;

  // 选中的值
  late String _selectedValue;

  // 属性
  late List _attr = [];

  // 监听广播
  // ignore: prefer_typing_uninitialized_variables
  var actionEventBus;

  var _cartProvider;

  @override
  void initState() {
    super.initState();
    // 详情页面数据
    _productContent = widget._productContentList[0];
    // 属性赋值
    _attr = _productContent.attr;
    // 初始化Attr 格式化数据
    _initAttr();

    actionEventBus = eventBus.on<ProductContentEvent>().listen((str) {
      _attrBottomSheet();
    });
  }

  //初始化Attr 格式化数据
  _initAttr() {
    var attr = _attr;
    for (var i = 0; i < attr.length; i++) {
      for (var j = 0; j < attr[i].list.length; j++) {
        attr[i].attrList.add({"title": attr[i].list[j], "checked": j == 0});
      }
    }

    _getSelectedAttrValue();
  }

  //获取选中的值
  _getSelectedAttrValue() {
    var list = _attr;
    List tempArr = [];
    for (var i = 0; i < list.length; i++) {
      for (var j = 0; j < list[i].attrList.length; j++) {
        if (list[i].attrList[j]['checked'] == true) {
          tempArr.add(list[i].attrList[j]["title"]);
        }
      }
    }
    setState(() {
      _selectedValue = tempArr.join('，');
      _productContent.selectedAttr = _selectedValue;
    });
  }

  //改变属性值
  _changeAttr(cate, title, setBottomState) {
    var attr = _attr;
    for (var i = 0; i < attr.length; i++) {
      if (attr[i].cate == cate) {
        for (var j = 0; j < attr[i].attrList.length; j++) {
          attr[i].attrList[j]["checked"] = false;
          if (title == attr[i].attrList[j]["title"]) {
            attr[i].attrList[j]["checked"] = true;
          }
        }
      }
    }
    setBottomState(() {
      //注意  改变showModalBottomSheet里面的数据 来源于StatefulBuilder
      _attr = attr;
      _getSelectedAttrValue();
    });
  }

  // 循环具体属性
  List<Widget> _getAttrItemWidget(attrItem, setBottomState) {
    List<Widget> attrItemList = [];
    attrItem.attrList.forEach((item) {
      attrItemList.add(Container(
        margin: const EdgeInsets.all(10),
        child: InkWell(
          onTap: () {
            _changeAttr(attrItem.cate, item["title"], setBottomState);
          },
          child: Chip(
            label: Text(
              item['title'],
              style: TextStyle(
                  color: item["checked"] ? Colors.white : Colors.black54),
            ),
            padding: const EdgeInsets.all(10),
            backgroundColor: item["checked"] ? Colors.red : Colors.black26,
          ),
        ),
      ));
    });
    return attrItemList;
  }

  //封装一个组件 渲染attr
  List<Widget> _getAttrWidget(setBottomState) {
    List<Widget> attrList = [];
    for (var attrItem in _attr) {
      attrList.add(Wrap(
        children: <Widget>[
          SizedBox(
            width: ScreenAdapter.width(120),
            child: Padding(
              padding: EdgeInsets.only(top: ScreenAdapter.height(22)),
              child: Text('${attrItem.cate}: ',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(
            width: ScreenAdapter.width(590),
            child: Wrap(
              children: _getAttrItemWidget(attrItem, setBottomState),
            ),
          )
        ],
      ));
    }
    return attrList;
  }

  //底部弹出框
  _attrBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, setBottomState) {
            return GestureDetector(
              onTap: () {
                return;
              },
              child: Stack(children: <Widget>[
                Container(
                  padding: EdgeInsets.all(ScreenAdapter.width(20)),
                  child: ListView(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _getAttrWidget(setBottomState),
                      ),
                      const Divider(),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        height: ScreenAdapter.height(80),
                        child: Row(
                          children: <Widget>[
                            const Text(
                              '数量：',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            CartNum(_productContent)
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                    bottom: 0,
                    width: ScreenAdapter.width(750),
                    height: ScreenAdapter.height(76),
                    child: Row(children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: JdButton(
                              color: const Color.fromRGBO(253, 1, 0, 0.9),
                              text: "加入购物车",
                              cb: () async {
                                await CartServices.addCart(_productContent);
                                _cartProvider.updateCartList();
                                //关闭底部筛选属性
                                Navigator.of(context).pop();
                                Fluttertoast.showToast(
                                    msg: "加入购物车成功",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16);
                              },
                            )),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: JdButton(
                              color: const Color.fromRGBO(255, 165, 0, 0.9),
                              text: "立即购买",
                              cb: () {
                                print('立即购买');
                              },
                            )),
                      )
                    ]))
              ]),
            );
          });
        });
  }

  @override
  void dispose() {
    super.dispose();
    actionEventBus.cancel();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _cartProvider = Provider.of<Cart>(context);
    // 处理图片显示
    String pic = widget.pic;
    return Container(
      padding: const EdgeInsets.all(10),
      child: ListView(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(pic, fit: BoxFit.fill),
          ),
          //标题
          Container(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              _productContent.title,
              style: TextStyle(
                  color: Colors.black87, fontSize: ScreenAdapter.size(36)),
            ),
          ),
          Container(
              padding: const EdgeInsets.only(top: 10),
              child: Text(_productContent.subTitle,
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: ScreenAdapter.size(28)))),
          // 价格
          Container(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      const Text("特价: "),
                      Text(
                        '￥${_productContent.price}',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: ScreenAdapter.size(46)),
                      )
                    ],
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text("原价: "),
                        Text('￥${_productContent.oldPrice}',
                            style: TextStyle(
                                color: Colors.black38,
                                decoration: TextDecoration.lineThrough,
                                fontSize: ScreenAdapter.size(28)))
                      ],
                    ))
              ],
            ),
          ),
          //筛选
          Container(
            margin: const EdgeInsets.only(top: 10),
            height: ScreenAdapter.height(80),
            child: InkWell(
              onTap: () {
                _attrBottomSheet();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          const Text(
                            '已选：',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                              '${_productContent.selectedAttr}，${_productContent.count}件'),
                        ],
                      )),
                  const Icon(Icons.chevron_right)
                ],
              ),
            ),
          ),
          const Divider(),
          SizedBox(
            height: ScreenAdapter.height(80),
            child: const Row(
              children: <Widget>[
                Text("运费: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("免运费")
              ],
            ),
          ),
        ],
      ),
    );
  }
}
