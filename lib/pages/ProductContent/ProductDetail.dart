import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_jingdong/config/Config.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';

class ProductDetailPage extends StatefulWidget {
  final List _productContentList;
  const ProductDetailPage(this._productContentList, {super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  var id;

  @override
  void initState() {
    super.initState();
    id = widget._productContentList[0].id;
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey webViewKey = GlobalKey();
    return Container(
      padding: EdgeInsets.only(bottom: ScreenAdapter.height(106),),
      child: Column(
        children: <Widget>[
          Expanded(
              child: InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(
              url: Uri.parse('${Config.domain}pcontent?id=$id'),
              // url: Uri.parse('https://www.baidu.com'),
            ),
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
              useShouldInterceptAjaxRequest: true,
            )),
            onProgressChanged:
                (InAppWebViewController controller, int progress) {},
            // onLoadError: () {},
          ))
        ],
      ),
    );
  }
}
