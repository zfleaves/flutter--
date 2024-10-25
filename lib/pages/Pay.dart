import 'package:flutter/material.dart';
import 'package:flutter_jingdong/components/JdButton.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';

class PayPage extends StatefulWidget {
  const PayPage({super.key});

  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  List payList = [
    {
      "title": "支付宝支付",
      "checked": true,
      "image": "https://www.itying.com/themes/itying/images/alipay.png"
    },
    {
      "title": "微信支付",
      "checked": false,
      "image": "https://www.itying.com/themes/itying/images/weixinpay.png"
    }
  ];
  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('去支付'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: ScreenAdapter.height(400),
            padding: const EdgeInsets.all(20),
            child: ListView.builder(
              itemCount: payList.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      onTap: () {
                        setState(() {
                          for (var i = 0; i < payList.length; i++) {
                            payList[i]['checked'] = false;
                          }
                          payList[index]["checked"] = true;
                        });
                      },
                      leading: Image.network("${payList[index]["image"]}"),
                      title: Text("${payList[index]["title"]}"),
                      trailing: payList[index]["checked"]
                            ? const Icon(Icons.check)
                            : const Text(""),
                    ),
                    const Divider(),
                  ],
                );
              }
            ),
          ),
          JdButton(
            text: '支付',
            color: Colors.red,
            height: ScreenAdapter.height(74),
            cb: () {
              print('支付1111');
            },
          )
        ],
      )
    );
  }
}