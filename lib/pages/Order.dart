import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jingdong/config/Config.dart';
import 'package:flutter_jingdong/model/OrderModel.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';
import 'package:flutter_jingdong/services/SignServices.dart';
import 'package:flutter_jingdong/services/UserServices.dart';

class OrderPage extends StatefulWidget {
  final Map arguments;
  const OrderPage({super.key, required this.arguments});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List _tabs = ['全部', '待付款', '待收货', '已完成', '已取消'];
  List _orderList = [];
  List _orderAllList = [];
  int payStatus = 0;

  @override
  void initState() {
    super.initState();
    payStatus = widget.arguments['payStatus'];
    _getListData();
  }

  // 获取订单列表数据
  void _getListData() async {
    try {
      List userInfo = await UserServices.getUserInfo();
      var tempJson = {"uid": userInfo[0]['_id'], "salt": userInfo[0]["salt"]};
      // print(tempJson);
      var sign = SignServices.getSign(tempJson);
      var api =
          '${Config.domain}api/orderList?uid=${userInfo[0]['_id']}&sign=${sign}';
      var response = await Dio().get(api);
      setState(() {
        var orderMode = OrderModel.fromJson(response.data);
        _orderAllList = orderMode.result;
        _orderList = _orderAllList
            .where((element) => element.payStatus == payStatus)
            .toList();
        ;
        // print(_orderList);
      });
    } catch (e) {
      print(e);
    }
  }

  //自定义商品列表组件
  List<Widget> _orderItemWidget(orderItems) {
    List<Widget> tempList = [];
    for (var i = 0; i < orderItems.length; i++) {
      // 图片转换格式
      String pic = orderItems[i].productImg;
      pic = Config.domain + pic.replaceAll('\\', '/');
      tempList.add(Column(
        children: <Widget>[
          SizedBox(
            height: ScreenAdapter.height(10),
          ),
          ListTile(
            leading: SizedBox(
              width: ScreenAdapter.width(120),
              height: ScreenAdapter.height(120),
              child: Image.network(
                pic,
                fit: BoxFit.cover,
              ),
            ),
            title: Text('${orderItems[i].productTitle}'),
            // trailing: Text('${orderItems[i].productContent}'),
          ),
          const SizedBox(height: 10)
        ],
      ));
    }
    return tempList;
  }

  List<Widget> _orderTabsWidget() {
    List<Widget> list = [];
    for (var i = 0; i < _tabs.length; i++) {
      list.add(
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                payStatus = i;
                _orderList = _orderAllList
                    .where((element) => element.payStatus == i)
                    .toList();
              });
            },
            child: Text(
              _tabs[i],
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: payStatus == i ? Colors.red : Colors.black54),
            ),
          ),
        ),
      );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("我的订单"),
        ),
        body: Stack(
          children: <Widget>[
            Container(
                margin: EdgeInsets.fromLTRB(0, ScreenAdapter.height(80), 0, 0),
                padding: EdgeInsets.all(ScreenAdapter.width(16)),
                child: _orderList.isNotEmpty
                    ? ListView(
                        children: _orderList.map((value) {
                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/orderinfo',
                                arguments: {'id': value.id});
                          },
                          child: Card(
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text("订单编号：${value.id}",
                                      style: const TextStyle(
                                          color: Colors.black54)),
                                ),
                                const Divider(),
                                Column(
                                  children: _orderItemWidget(value.orderItem),
                                ),
                                SizedBox(height: ScreenAdapter.height(10)),
                                ListTile(
                                  leading: Text("合计：￥${value.allPrice}"),
                                  trailing: ElevatedButton(
                                      onPressed: () {},
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                  Colors.blue)),
                                      child: const Text("申请售后")),
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList())
                    : const SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text('暂无订单'),
                        ),
                      )),
            Positioned(
                top: 0,
                width: ScreenAdapter.width(750),
                height: ScreenAdapter.height(76),
                child: Container(
                    width: ScreenAdapter.width(750),
                    height: ScreenAdapter.height(76),
                    color: Colors.white,
                    child: Row(children: [..._orderTabsWidget()])))
          ],
        ));
  }
}
