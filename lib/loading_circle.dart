import 'package:flutter/material.dart';

class LoadingCircle extends StatelessWidget {
  const LoadingCircle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 25,
        width: 25,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
