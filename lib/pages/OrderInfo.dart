import 'package:date_format/date_format.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jingdong/config/Config.dart';
import 'package:flutter_jingdong/model/OrderModel.dart';
import 'package:flutter_jingdong/services/AddressServices.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';
import 'package:flutter_jingdong/services/SignServices.dart';
import 'package:flutter_jingdong/services/UserServices.dart';

class OrderInfoPage extends StatefulWidget {
  final Map arguments;
  const OrderInfoPage({super.key, required this.arguments});

  @override
  State<OrderInfoPage> createState() => _OrderInfoPageState();
}

class _OrderInfoPageState extends State<OrderInfoPage> {
  Result? _orderItem;
  List _orderList = [];

  String addressInfo = '';

  @override
  void initState() {
    super.initState();
    // _orderItem =
    _getOrderInfo();
  }

  // 获取订单详情
  _getOrderInfo() async {
    try {
      List userInfo = await UserServices.getUserInfo();
      var tempJson = {"uid": userInfo[0]['_id'], "salt": userInfo[0]["salt"]};
      // print(tempJson);
      var sign = SignServices.getSign(tempJson);
      var api =
          '${Config.domain}api/orderList?uid=${userInfo[0]['_id']}&sign=${sign}';
      var response = await Dio().get(api);
      // print(response.data['result']);
      var orderMode = OrderModel.fromJson(response.data);
      var item =
          orderMode.result.firstWhere((v) => v.id == widget.arguments['id']);
      var addressItem = await AddressServices.getAddressItem('${item.name}-${item.phone}-${item.address}', '');
      // print(addressItem);
      setState(() {
        if (addressItem['locationCode'] != '') {
          addressInfo = '${addressItem['provinceName']} ${addressItem['cityName']} ${addressItem['areaName']} ${item.address}';
        } else {
          addressInfo = item.address;
        }
        _orderItem = item;
        print(_orderItem);
      });
    } catch (e) {
      print(e);
    }
  }

  List<Widget> _orderItemWidget() {
    if (_orderItem == null) return [];
    List<Widget> list = [];
    for (var i = 0; i < _orderItem!.orderItem.length; i++) {
      var item = _orderItem!.orderItem[i];
      // 图片转换格式
      String pic = item.productImg;
      pic = Config.domain + pic.replaceAll('\\', '/');
      list.add(Column(
        children: <Widget>[
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: ScreenAdapter.width(200),
                height: ScreenAdapter.height(150),
                margin: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(pic),
                    fit: BoxFit.fill,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            child: Text(
                              item.productTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenAdapter.size(28)),
                            ),
                          )),
                          Text('￥${item.productPrice}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenAdapter.size(28))),
                        ],
                      ),
                      Text(
                        '数量 x ${item.productCount} (${item.selectedAttr})',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.left,
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                        margin: const EdgeInsets.only(top: 16),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 231, 153, 51),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '支持7填无理由退货',
                              style:
                                  TextStyle(fontSize: ScreenAdapter.size(20)),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              size: 20,
                            )
                          ],
                        ),
                      ),
                    ],
                  ))
            ],
          ),
          const Divider()
        ],
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('订单详情'),
        ),
        body: ListView(
          children: <Widget>[
            // 收货地址
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  SizedBox(height: ScreenAdapter.height(10)),
                  ..._orderItemWidget(),
                  _orderItem != null ? Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '应付款',
                              style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              '合计￥${_orderItem?.allPrice}',
                              style: const TextStyle(color: Colors.black54),
                            )
                          ],
                        ),
                        SizedBox(height: ScreenAdapter.height(10)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '订单编号',
                              style: TextStyle(color: Colors.black),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${_orderItem?.id}  |  ',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(
                                        text: '${_orderItem?.id}'));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text('复制成功'),
                                      duration: Duration(seconds: 1),
                                    ));
                                  },
                                  child: const Text(
                                    '复制',
                                    style: TextStyle(color: Colors.lightBlue),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: ScreenAdapter.height(10)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '支付方式',
                              style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              _orderItem?.payStatus == 0 ? '微信' : '支付宝',
                              style: const TextStyle(color: Colors.black54),
                            )
                          ],
                        ),
                        SizedBox(height: ScreenAdapter.height(10)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '下单时间',
                              style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              formatDate(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      _orderItem!.orderItem[0].addTime),
                                  [
                                    yyyy,
                                    '-',
                                    mm,
                                    '-',
                                    dd,
                                    ' ',
                                    HH,
                                    ':',
                                    nn,
                                    ':',
                                    ss
                                  ]),
                              style: const TextStyle(color: Colors.black54),
                            )
                          ],
                        ),
                        SizedBox(height: ScreenAdapter.height(10)),
                        const Divider(),
                        SizedBox(height: ScreenAdapter.height(10)),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '配送方式',
                              style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              '快递运输',
                              style: TextStyle(color: Colors.black54),
                            )
                          ],
                        ),
                        SizedBox(height: ScreenAdapter.height(10)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '收货信息',
                              style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              '${_orderItem?.name} ${_orderItem?.phone.substring(0, 3)}****${_orderItem?.phone.substring(7)}',
                              style: const TextStyle(color: Colors.black54),
                            )
                          ],
                        ),
                        SizedBox(height: ScreenAdapter.height(10)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '收货地址',
                              style: TextStyle(color: Colors.black),
                            ),
                            Expanded(
                                flex: 1,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 20),
                                  child: Text(
                                    addressInfo,
                                    maxLines: 2,
                                    textAlign: TextAlign.right,
                                    style:
                                        const TextStyle(color: Colors.black54),
                                  ),
                                ))
                          ],
                        )
                      ],
                    ),
                  ) : const Text('')
                ],
              ),
            )
          ],
        ));
  }
}
