import 'package:city_pickers/city_pickers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jingdong/components/JdButton.dart';
import 'package:flutter_jingdong/components/JdText.dart';
import 'package:flutter_jingdong/config/Config.dart';
import 'package:flutter_jingdong/services/AddressServices.dart';
import 'package:flutter_jingdong/services/EventBus.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';
import 'package:flutter_jingdong/services/SignServices.dart';
import 'package:flutter_jingdong/services/UserServices.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddressEditPage extends StatefulWidget {
  final Map arguments;
  const AddressEditPage({super.key, required this.arguments});

  @override
  State<AddressEditPage> createState() => _AddressEditPageState();
}

class _AddressEditPageState extends State<AddressEditPage> {
  String locationCode = '110101';
  String area = '';
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.arguments['name'];
    phoneController.text = widget.arguments['phone'];
    addressController.text = widget.arguments['address'];
    _getAreaInfo();
  }

  _getAreaInfo() async {
    var item = await AddressServices.getAddressItem('${widget.arguments['name']}-${widget.arguments['phone']}-${widget.arguments['address']}', widget.arguments['id']);
    if (item['locationCode'] == '') return;
    setState(() {
      area = '${item['provinceName']}/${item['cityName']}/${item['areaName']}';
      locationCode = item['locationCode'];
    });
  }

  @override
  void dispose() {
    super.dispose();
    eventBus.fire(AddressEvent('修改成功...'));
  }

  // 修改地址
  _editAddress() async {
    if (area == '') {
      return Fluttertoast.showToast(
        msg: '请选择省/市/区',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
    List userinfo = await UserServices.getUserInfo();
    var tempJson = {
      "uid": userinfo[0]["_id"],
      "id": widget.arguments["id"],
      "name": nameController.text,
      "phone": phoneController.text,
      "address": addressController.text,
      "salt": userinfo[0]["salt"]
    };
    var sign = SignServices.getSign(tempJson);
    var api = '${Config.domain}api/editAddress';
    var response = await Dio().post(api, data: {
      "uid": userinfo[0]["_id"],
      "id": widget.arguments["id"],
      "name": nameController.text,
      "phone": phoneController.text,
      "address": addressController.text,
      "sign": sign
    });
    Fluttertoast.showToast(
      msg: '修改成功',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
    List<String> areaList = area.split('/'); 
    var item = {
      "id": widget.arguments["id"],
      'provinceName': areaList[0],
      'cityName': areaList[1],
      'areaName': areaList[2],
      'key': '${nameController.text}-${phoneController.text}-${addressController.text}',
      'locationCode': locationCode
    };
    AddressServices.addItem(item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('修改收货地址'),
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: ScreenAdapter.height(20),
              ),
              JdText(
                controller: nameController,
                text: '收货人姓名',
                onChanged: (p0) => nameController.text = p0,
              ),
              SizedBox(
                height: ScreenAdapter.height(10),
              ),
              JdText(
                controller: phoneController,
                text: '收货人电话',
                onChanged: (p0) => phoneController.text = p0,
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
                    print(result);
                    setState(() {
                      area =
                          "${result?.provinceName}/${result?.cityName}/${result?.areaName}";
                      locationCode = result!.areaId!;
                    });
                  },
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.add_location),
                      Text(
                        area != '' ? area : '省/市/区',
                        style: const TextStyle(color: Colors.black),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: ScreenAdapter.height(10),
              ),
              JdText(
                controller: addressController,
                text: '详细地址',
                onChanged: (p0) => addressController.text = p0,
              ),
              SizedBox(
                height: ScreenAdapter.height(5),
              ),
              JdButton(
                text: '确定',
                color: Colors.red,
                cb: _editAddress,
              )
            ],
          ),
        ));
  }
}
