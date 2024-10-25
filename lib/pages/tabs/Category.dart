import 'package:flutter/material.dart';
import 'package:flutter_jingdong/config/Config.dart';
import 'package:flutter_jingdong/model/CateModel.dart';
import 'package:flutter_jingdong/model/sendInsecureRequest.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  int _selectIndex = 0;

  // 左侧数据
  List _leftCateData = [];

  // 右侧数据
  List _rightCateData = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 获取左侧数据
    _getLeftCateData();
  }

  _getLeftCateData() async {
    var api = '${Config.domain}api/pcate';
    var result = await sendInsecureRequest(api);
    setState(() {
      _leftCateData = result;
    });

    // 请求右侧数据
    _getRightCateData(result[0]['_id']);
  }

  Widget _leftCateWidget(leftWidth) {
    if (_leftCateData.isEmpty) {
      return SizedBox(
        width: leftWidth,
        height: double.infinity,
        child: const Center(
          child: Text('加载中...'),
        ),
      );
    }
    return SizedBox(
      width: leftWidth,
      height: double.infinity,
      child: ListView.builder(
        itemCount: _leftCateData.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _selectIndex = index;
                    _getRightCateData(_leftCateData[index]['_id']);
                  });
                },
                child: Container(
                  width: double.infinity,
                  height: ScreenAdapter.height(84),
                  padding: EdgeInsets.only(top: ScreenAdapter.height(30)),
                  color: _selectIndex == index ? const Color.fromRGBO(240, 246, 246, 0.9) : Colors.white,
                  child: Text('${_leftCateData[index]['title']}', textAlign: TextAlign.center,),
                )
              )
            ],
          );
        }
      )
    );
  }

  _getRightCateData(id) async {
    var api = '${Config.domain}api/pcate?pid=$id';
    var result = await sendInsecureRequest(api);
    setState(() {
      _rightCateData = result;
    });
  }

  Widget _rightCateWidget(rightItemWidth, rightItemHeight) {
    if (_rightCateData.isEmpty) {
      return Expanded(
        flex: 1,
        child: Container(
          padding: const EdgeInsets.all(10),
          height: double.infinity,
          color: const Color.fromRGBO(240, 246, 246, 0.9),
          child: const Center(
            child: Text('暂无该类商品'),
          ),
        ),
      );;
    }
    return Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.all(10),
        height: double.infinity,
        color: const Color.fromRGBO(240, 246, 246, 0.9),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: rightItemWidth / rightItemHeight,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10
          ), 
          itemCount: _rightCateData.length,
          itemBuilder: (BuildContext context, int index) {
            // 图片转换格式
            String pic = _rightCateData[index]['pic'];
            pic = Config.domain + pic.replaceAll('\\', '/');
            return InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/productList', arguments: {
                  'cid': _rightCateData[index]['_id']
                }); 
              },
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Image.network(pic, fit: BoxFit.cover,),
                  ),
                  SizedBox(
                    height: ScreenAdapter.height(40),
                    child: Text('${_rightCateData[index]['title']}', maxLines: 1,),
                  )
                ],
              ),
            );
          }
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 初始化屏幕适配
    ScreenAdapter.init(context);

    // 计算GridView 宽高比
    var leftWidth = ScreenAdapter.getScreenWidth() / 4;
    var rightItemWidth =
        (ScreenAdapter.getScreenWidth() - leftWidth - 20 - 30) / 3;
    rightItemWidth = ScreenAdapter.width(rightItemWidth);
    var rightItemHeight = rightItemWidth + ScreenAdapter.height(28);
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
      body: Row(
        children: [
          _leftCateWidget(leftWidth),
          _rightCateWidget(rightItemWidth, rightItemHeight),
        ],
      ),
    );
  }
}
