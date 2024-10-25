import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jingdong/config/Config.dart';
import 'package:flutter_jingdong/services/AddressServices.dart';
import 'package:flutter_jingdong/services/EventBus.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';
import 'package:flutter_jingdong/services/SignServices.dart';
import 'package:flutter_jingdong/services/UserServices.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddressListPage extends StatefulWidget {
  final Map? arguments;
  const AddressListPage({super.key, this.arguments});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  List addressList = [];
  late String uid;

  @override
  void initState() {
    super.initState();
    uid = widget.arguments?['uid'];
    print(uid);
    _getAddressList();

    //监听增加收货地址的广播
    eventBus.on<AddressEvent>().listen((event) {
      _getAddressList();
    });
  }

  _getAddressList() async {
    List userInfo = await UserServices.getUserInfo();
    var tempJson = {"uid": userInfo[0]['_id'], "salt": userInfo[0]["salt"]};
    var sign = SignServices.getSign(tempJson);
    var api =
        '${Config.domain}api/addressList?uid=${userInfo[0]['_id']}&sign=$sign';
    var response = await Dio().get(api);
    for (var i = 0; i < response.data['result'].length; i++) {
      var id = response.data['result'][i]['_id'];
      var val = response.data['result'][i];
      var key = '${val['name']}-${val['phone']}-${val['address']}';
      var item = await AddressServices.getAddressItem(key, id);
      if (item['locationCode'] != '') {
        response.data['result'][i]['addressInfo'] =
            '${item['provinceName']} ${item['cityName']} ${item['areaName']} ${response.data['result'][i]['address']}';
      } else {
        response.data['result'][i]['addressInfo'] =
            '${response.data['result'][i]['address']}';
      }
      response.data['result'][i]['locationCode'] = item['locationCode'];
    }
    setState(() {
      addressList = response.data['result'];
      // print(addressList);
    });
  }

  //修改默认收货地址
  _changeDefaultAddress(id) async {
    int index = addressList.indexWhere((item) => item['_id'] == id);
    if (addressList[index]['default_address'] == 1) {
      return Fluttertoast.showToast(
        msg: '该地址已为默认地址',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
    List userinfo = await UserServices.getUserInfo();
    var tempJson = {
      "uid": userinfo[0]['_id'],
      "id": id,
      "salt": userinfo[0]["salt"]
    };
    var sign = SignServices.getSign(tempJson);
    var api = '${Config.domain}api/changeDefaultAddress';
    var response = await Dio()
        .post(api, data: {"uid": userinfo[0]['_id'], "id": id, "sign": sign});
    if (response.data['success']) {
      Fluttertoast.showToast(
        msg: '已设为默认',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      List<Map<String, dynamic>> newAddressList = List.from(addressList);
      for (var i = 0; i < newAddressList.length; i++) {
        newAddressList[i]['default_address'] = 0;
        if (newAddressList[i]['_id'] == id) {
          newAddressList[i]['default_address'] = 1;
        }
      }
      setState(() {
        addressList = newAddressList;
      });
      // _getAddressList();
    } else {
      Fluttertoast.showToast(
        msg: '${response.data["message"]}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  //删除收货地址
  _delAddress(id) async {
    var result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('删除'),
            content: const Text('您确定要删除吗?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, "Cancle");
                  },
                  child: const Text(
                    "取消",
                    style: TextStyle(color: Colors.black87),
                  )),
              TextButton(
                  onPressed: () async {
                    _deleteCallback(id);
                    Navigator.pop(context, "ok");
                  },
                  child: const Text(
                    "确定",
                    style: TextStyle(color: Color.fromRGBO(122, 179, 207, 1)),
                  ))
            ],
          );
        });
  }

  _deleteCallback(id) async {
    List userinfo = await UserServices.getUserInfo();
    var tempJson = {
      "uid": userinfo[0]["_id"],
      "id": id,
      "salt": userinfo[0]["salt"]
    };
    var sign = SignServices.getSign(tempJson);
    var api = '${Config.domain}api/deleteAddress';
    var response = await Dio()
        .post(api, data: {"uid": userinfo[0]["_id"], "id": id, "sign": sign});
    if (response.data['success']) {
      Fluttertoast.showToast(
        msg: '删除成功',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      int index = addressList.indexWhere((item) => item['_id'] == id);
      List<Map<String, dynamic>> newAddressList = List.from(addressList);
      newAddressList.removeAt(index);
      setState(() {
        addressList = newAddressList;
      });
      // _getAddressList();
    } else {
      Fluttertoast.showToast(
        msg: '${response.data["message"]}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
    _getAddressList(); //删除收货地址完成后重新获取列表
  }

  //弹出框
  _showDelAlertDialog(id) async {}

  //监听页面销毁的事件
  @override
  void dispose() {
    super.dispose();
    // eventBus.fire(CheckOutEvent('改收货地址成功...'));
  }

  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('收货地址'),
        ),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              addressList.isNotEmpty
                  ? ListView.builder(
                      itemCount: addressList.length,
                      itemBuilder: (BuildContext context, int index) {
                        var is_default =
                            addressList[index]["default_address"] == 1;
                        return Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: GestureDetector(
                              onTap: () {
                                print('GestureDetector');
                                // 返回数据到上一个页面  
                                Navigator.pop(context, addressList[index]['_id']);  
                              },
                              child: Card(
                                color: Colors.white,
                                margin: EdgeInsets.only(
                                    bottom: ScreenAdapter.height(16)),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border:
                                          // Border.all(color: Colors.red, width: 1)),
                                          Border.all(
                                              color: uid ==
                                                      addressList[index]['_id']
                                                  ? Colors.red
                                                  : Colors.white,
                                              width: 1)),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          uid == addressList[index]['_id']
                                              ? Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10),
                                                  child: const Icon(
                                                    Icons.check_circle,
                                                    color: Colors.red,
                                                    size: 20,
                                                  ),
                                                )
                                              : const Text(''),
                                          Text(
                                            '${addressList[index]['name']}',
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenAdapter.size(32),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: ScreenAdapter.width(10),
                                          ),
                                          Text(
                                            '${addressList[index]['phone']}',
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenAdapter.size(32),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          is_default
                                              ? Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          6, 0, 6, 0),
                                                  margin: const EdgeInsets.only(
                                                      left: 8),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                      border: Border.all(
                                                          width: 1,
                                                          color: Colors.red)),
                                                  child: const Text(
                                                    '默认',
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 12),
                                                  ),
                                                )
                                              : const Text('')
                                        ],
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            bottom: ScreenAdapter.height(20)),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            '${addressList[index]['addressInfo']}'),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: InkWell(
                                                onTap: () {
                                                  _changeDefaultAddress(
                                                      addressList[index]
                                                          ["_id"]);
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Icon(
                                                      is_default
                                                          ? Icons.check_box
                                                          : Icons
                                                              .check_box_outline_blank,
                                                      color: is_default
                                                          ? Colors.red
                                                          : Colors.black54,
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          ScreenAdapter.width(
                                                              6),
                                                    ),
                                                    Text(is_default
                                                        ? '已默认'
                                                        : '设为默认')
                                                  ],
                                                )),
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      _delAddress(
                                                          addressList[index]
                                                              ["_id"]);
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(8, 2, 8, 2),
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 12),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: Colors.red,
                                                      ),
                                                      child: const Text(
                                                        '删除',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.pushNamed(
                                                          context,
                                                          '/addressEdit',
                                                          arguments: {
                                                            "id": addressList[
                                                                index]["_id"],
                                                            "name": addressList[
                                                                index]["name"],
                                                            "phone":
                                                                addressList[
                                                                        index]
                                                                    ["phone"],
                                                            "address":
                                                                addressList[
                                                                        index]
                                                                    ["address"],
                                                          });
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(8, 2, 8, 2),
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 12),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 207, 204, 204),
                                                      ),
                                                      child: const Text(
                                                        '修改',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ))
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ));
                      })
                  : const Center(
                      child: Text('暂无收货地址'),
                    ),
              Positioned(
                  bottom: 0,
                  width: ScreenAdapter.width(750),
                  height: ScreenAdapter.height(88),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    width: ScreenAdapter.width(750),
                    height: ScreenAdapter.height(88),
                    decoration: const BoxDecoration(
                        color: Colors.red,
                        border: Border(
                            top: BorderSide(width: 1, color: Colors.black26))),
                    child: InkWell(
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.add, color: Colors.white),
                          Text("增加收货地址", style: TextStyle(color: Colors.white))
                        ],
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/addressAdd');
                      },
                    ),
                  ))
            ],
          ),
        ));
  }
}
