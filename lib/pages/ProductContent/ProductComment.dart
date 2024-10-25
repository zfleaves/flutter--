import 'package:flutter/material.dart';

class ProductCommentPage extends StatefulWidget {
  const ProductCommentPage({super.key});

  @override
  State<ProductCommentPage> createState() => _ProductCommentPageState();
}

class _ProductCommentPageState extends State<ProductCommentPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('商品评价'),
      ),
    );
  }
}