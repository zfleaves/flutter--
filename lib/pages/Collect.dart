import 'package:flutter/material.dart';
import 'package:flutter_jingdong/config/Config.dart';
import 'package:flutter_jingdong/model/ProductContentModel.dart';
import 'package:flutter_jingdong/provider/Cart.dart';
import 'package:flutter_jingdong/provider/Collect.dart';
import 'package:flutter_jingdong/services/CartServices.dart';
import 'package:flutter_jingdong/services/CollectServices.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class CollectPage extends StatefulWidget {
  const CollectPage({super.key});

  @override
  State<CollectPage> createState() => _CollectPageState();
}

class _CollectPageState extends State<CollectPage> {
  final globalKey = GlobalKey<AnimatedListState>();
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
  }

  // Widget _selectAttr

  @override
  Widget build(BuildContext context) {
    var cartProvider = Provider.of<Cart>(context);
    var collectProvider = Provider.of<Collect>(context);
    List collectList = collectProvider.collectList;
    int len = collectList.length;
    bool checkAll = len == collectProvider.checkedLen;
    // print(collectList);

    ScreenAdapter.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('我的收藏（${collectProvider.len}）'),
        actions: [
          TextButton(
              onPressed: () {
                setState(() {
                  isEdit = !isEdit;
                });
                collectProvider.init();
              },
              child: Text(
                isEdit ? '完成' : '编辑',
                style: const TextStyle(color: Color.fromRGBO(70, 98, 217, 1)),
              ))
        ],
      ),
      body: collectList.isNotEmpty
          ? Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, isEdit ? ScreenAdapter.height(96) : 16),
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color.fromARGB(255, 241, 241, 241),
                  child: AnimatedList(
                    key: globalKey,
                    initialItemCount: len,
                    itemBuilder: (context, index, animation) {
                      var item = collectList[index];
                      String pic = item['pic'];
                      pic = Config.domain + pic.replaceAll('\\', '/');
                      return SizeTransition(
                        axis: Axis.vertical,
                        sizeFactor: animation,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/productContent',
                                arguments: {'id': item['id'], 'imageUrl': pic});
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                bottom: 10,
                                top: 20,
                                right: 10,
                                left: isEdit ? 0 : 10),
                            margin: const EdgeInsets.only(top: 10),
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                border: Border(
                                    bottom: BorderSide(
                                        width: 1, color: Colors.black12))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                isEdit
                                    ? Container(
                                        margin: const EdgeInsets.only(top: 50),
                                        child: Checkbox(
                                          value: item['checked'],
                                          onChanged: (val) {
                                            collectProvider.changeItemCheck(
                                                item['id'], val);
                                          },
                                          activeColor: Colors.red,
                                        ),
                                      )
                                    : const Text(''),
                                Container(
                                  margin: const EdgeInsets.only(right: 20),
                                  width: ScreenAdapter.width(200),
                                  height: ScreenAdapter.height(180),
                                  child: Image.network(pic, fit: BoxFit.cover),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(item['title'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        SizedBox(
                                          height: 40,
                                          child: Text(
                                            item['subTitle'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(item['selectedAttr']),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Expanded(
                                              flex: 1,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    '￥${item['price']} ',
                                                    style: const TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                  Text(
                                                    '￥${item['oldPrice']}',
                                                    style: const TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        color: Colors.black26),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // IconButton(
                                            //     onPressed: () async {
                                            //       // item['checked'] = true;
                                            //       await CartServices.addCart(item);
                                            //       cartProvider.updateCartList();
                                            //       Fluttertoast.showToast(
                                            //           msg: "加入购物车成功",
                                            //           toastLength:
                                            //               Toast.LENGTH_SHORT,
                                            //           gravity:
                                            //               ToastGravity.CENTER,
                                            //           timeInSecForIosWeb: 1,
                                            //           backgroundColor:
                                            //               Colors.red,
                                            //           textColor: Colors.white,
                                            //           fontSize: 16);
                                            //     },
                                            //     icon: const Icon(
                                            //       Icons.shopping_cart,
                                            //       size: 20,
                                            //       color: Colors.red,
                                            //     ))
                                          ],
                                        )
                                      ],
                                    ))
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                    width: isEdit ? ScreenAdapter.width(750) : 0,
                    bottom: 0,
                    left: 0,
                    height: ScreenAdapter.height(80),
                    child: Container(
                      width: ScreenAdapter.width(750),
                      height: ScreenAdapter.height(80),
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              top:
                                  BorderSide(width: 1, color: Colors.black26))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Checkbox(
                              value: checkAll,
                              activeColor: Colors.red,
                              onChanged: (val) {
                                collectProvider.changeCheckAll(val);
                              }),
                          collectProvider.checkedLen > 0
                              ? ElevatedButton(
                                  onPressed: () async {
                                    List ids = collectProvider.checkedList.map((item) => item['id']).toList();
                                    await CollectServices.deleteCollect(ids);
                                    collectProvider.updateCollectList();
                                    setState(() {
                                      isEdit = false;
                                    });
                                  },
                                  style: const ButtonStyle(
                                    backgroundColor:
                                        WidgetStatePropertyAll(Colors.red),
                                    foregroundColor:
                                        WidgetStatePropertyAll(Colors.white),
                                  ),
                                  child: Text('取消收藏(${collectProvider.checkedLen})'))
                              : ElevatedButton(
                                  onPressed: null, child: Text('取消收藏(${collectProvider.checkedLen})'))
                        ],
                      ),
                    ))
              ],
            )
          : const Center(
              child: Text('暂无收藏'),
            ),
    );
  }
}
