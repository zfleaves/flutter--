import 'package:flutter/material.dart';

class LoadingWidget extends StatefulWidget {
  final String text;
  const LoadingWidget({super.key, this.text =  '加载中'});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.text,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20,),
            const CircularProgressIndicator(
              strokeWidth: 1,
            )
          ],
        ),
      ),
    );
  }
}
