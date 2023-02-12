import 'dart:io' show File;
import 'package:flutter/material.dart';

class DetailImage extends StatefulWidget {
  const DetailImage({
    required this.files,
    required this.index,
    super.key,
  });

  final List<File> files;
  final int index;

  @override
  State<DetailImage> createState() => _DetailImageState();
}

class _DetailImageState extends State<DetailImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Image.file(widget.files[0])),
    );
  }
}
