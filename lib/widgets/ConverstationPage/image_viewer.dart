import 'dart:io';

import 'package:chatsample/models/Message.dart';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final Message message;

  ImageViewer(this.message);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
            Expanded(
              child: Image.file(
                File(message.mediaURL),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                message?.message ?? "",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}