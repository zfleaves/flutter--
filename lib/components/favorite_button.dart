import 'dart:ffi';

import 'package:flutter/material.dart';  
import 'package:flutter/cupertino.dart';  // For CupertinoIcons  
  
class FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final Function? onToggle;
  const FavoriteButton({super.key, required this.isFavorite, this.onToggle});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> with SingleTickerProviderStateMixin {  
  bool isFavorite = false;  
  late AnimationController _controller;  
  late Animation<double> _animation;  
  
  @override  
  void initState() {  
    super.initState();  
    isFavorite = widget.isFavorite;
    _controller = AnimationController(  
      duration: const Duration(milliseconds: 300),  
      vsync: this,  
    )..repeat(reverse: true);  
  
    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(_controller);  
  }  
  
  @override  
  void dispose() {  
    _controller.dispose();  
    super.dispose();  
  }  
  
  void toggleFavorite() {  
    // setState(() {  
    //   isFavorite = !isFavorite;  
    //   _controller.reset();  
    //   _controller.forward();  
    // });
    widget.onToggle!(_controller); 
  }  
  
  @override  
  Widget build(BuildContext context) {  
    return GestureDetector(  
      onTap: toggleFavorite,  
      child: AnimatedBuilder(  
        animation: _animation,  
        child: Icon(  
          isFavorite ? CupertinoIcons.heart_solid : CupertinoIcons.heart,  
          color: isFavorite ? Colors.red : Colors.grey,  
          size: 30.0,  
        ),  
        builder: (context, child) {  
          return Transform.scale(  
            scale: _animation.value,  
            child: child,  
          );  
        },  
      ),  
    );  
  }  
}