import 'package:flutter/material.dart';

class PlusButton extends StatelessWidget {
  final child;
  final function;

  PlusButton({this.child, this.function});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: function,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          width: 75,
          height: 75,
          child: Center(
            child: child,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[400],
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
