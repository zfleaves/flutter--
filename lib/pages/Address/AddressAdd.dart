import 'package:city_pickers/city_pickers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jingdong/components/JdButton.dart';
import 'package:flutter_jingdong/components/JdText.dart';
import 'package:flutter_jingdong/config/Config.dart';
import 'package:flutter_jingdong/model/CateModel.dart';
import 'package:flutter_jingdong/services/AddressServices.dart';
import 'package:flutter_jingdong/services/EventBus.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';
import 'package:flutter_jingdong/services/SignServices.dart';
import 'package:flutter_jingdong/services/UserServices.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddressAddPage extends StatefulWidget {
  const AddressAddPage({super.key});

  @override
  State<AddressAddPage> createState() => _AddressAddPageState();
}

class _AddressAddPageState extends State<AddressAddPage> {
  String locationCode = '';
  String area = '';
  // 用户名
  String name = '';
  // 电话
  String phone = '';
  // 详细地址
  String address = '';

  @override
  void dispose() {
    super.dispose();
    eventBus.fire(AddressEvent('增加成功...'));
    eventBus.fire(CheckOutEvent('改收货地址成功...'));
  }

  // 增加地址
  _handleAdd() async {
    if (area == '') {
      return Fluttertoast.showToast(
        msg: '请选择省/市/区',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
    List userInfo = await UserServices.getUserInfo();
    var tempJson = {
      "uid": userInfo[0]["_id"],
      "name": this.name,
      "phone": this.phone,
      "address": this.address,
      // 'area': this.area,
      "salt": userInfo[0]["salt"]
    };
    var sign = SignServices.getSign(tempJson);
    var api = '${Config.domain}api/addAddress';
    var response = await Dio().post(api, data: {
      "uid": userInfo[0]["_id"],
      "name": name,
      "phone": phone,
      "address": address,
      // "area": area,
      "sign": sign
    });
    List<String> areaList = area.split('/'); 
    var item = {
      "id": '',
      'provinceName': areaList[0],
      'cityName': areaList[1],
      'areaName': areaList[2],
      'key': '${name}-${phone}-${address}',
      'locationCode': locationCode
    };
    AddressServices.addItem(item);
    print(response);
    if (response.data["success"]) {
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
        msg: '${response.data["message"]}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("增加收货地址"),
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: ScreenAdapter.height(20),
              ),
              JdText(
                text: '收货人姓名',
                onChanged: (p0) => name = p0,
              ),
              SizedBox(
                height: ScreenAdapter.height(10),
              ),
              JdText(
                text: '收货人电话',
                onChanged: (p0) => phone = p0,
              ),
              SizedBox(
                height: ScreenAdapter.height(10),
              ),
              Container(
                padding: const EdgeInsets.only(left: 5),
                height: ScreenAdapter.height(68),
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(width: 1, color: Colors.black12))),
                child: InkWell(
                  onTap: () async {
                    var result = await CityPickers.showCityPicker(
                      context: context,
                      locationCode: locationCode,
                      cancelWidget: const Text('取消',
                          style: TextStyle(color: Colors.black54)),
                      confirmWidget: const Text('确定',
                          style: TextStyle(color: Colors.blue)),
                    );
                    setState(() {
                      area =
                          "${result?.provinceName}/${result?.cityName}/${result?.areaName}";
                      locationCode = result!.areaId!;  
                    });
                  },
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.add_location),
                      area != ''
                          ? Text(
                              area,
                              style: const TextStyle(color: Colors.black54),
                            )
                          : const Text('省/市/区',
                              style: TextStyle(color: Colors.black54))
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: ScreenAdapter.height(10),
              ),
              JdText(
                text: '详细地址',
                maxLines: 4,
                height: 200,
                onChanged: (p0) => address = p0,
              ),
              SizedBox(
                height: ScreenAdapter.height(10),
              ),
              SizedBox(
                height: ScreenAdapter.height(40),
              ),
              JdButton(
                text: '增加',
                color: Colors.red,
                cb: _handleAdd,
              )
            ],
          ),
        ));
  }
}
