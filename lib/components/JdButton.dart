import 'package:flutter/material.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';

class JdButton extends StatelessWidget {
  final Color color;
  final String text;
  final void Function() ? cb;
  final double height;

  const JdButton({super.key, this.color = Colors.black, this.text = '按钮', this.cb, this.height = 68});

  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    return InkWell(
      onTap: cb,
      child: Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(5),
        height: ScreenAdapter.height(68),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Center(
          child:  Text(text, style: const TextStyle(color: Colors.white),),
        ),
      ),
    );
  }
}