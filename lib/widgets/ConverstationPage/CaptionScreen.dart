import 'dart:io';

import 'package:chatsample/ui/widgets/ConversationPage.dart';
import 'package:flutter/material.dart';
class CaptionScreen extends StatefulWidget {
  List<ImageWithCaption> imageWithCaptionList = [];

  CaptionScreen(this.imageWithCaptionList);

  @override
  _CaptionScreenState createState() => _CaptionScreenState();
}
class _CaptionScreenState extends State<CaptionScreen> {
  PageController _pageController;
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(() {
      textEditingController.text =
          widget.imageWithCaptionList[_pageController.page.toInt()].caption ?? "";
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
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
                    }),
                Text("Image Name"),
              ],
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.imageWithCaptionList.length,
                itemBuilder: (context, index) {
                  return Container(
//                    color: Colors.amber,
                    child: Image.file(
                      File(widget.imageWithCaptionList[index].filePath),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 150,
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: widget.imageWithCaptionList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: Colors.white,
                      width: 100,
                      height: 100,
                      child: Image.file(
                        File(widget.imageWithCaptionList[index].filePath),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: textEditingController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter caption',
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                      onChanged: (value) {
                        widget.imageWithCaptionList[_pageController.page.toInt()].caption = value;
                      },
                    ),
                  ),
                ),
//                IconButton(
//                  icon: Icon(
//                    Icons.camera,
//                    color: Colors.white,
//                  ),
//                  onPressed: () async {
//                    FilePickerResult result =
//                        await FilePicker.platform.pickFiles(
//                      type: FileType.image,
//                    );
//
//                    if (result != null) {
//                      var re = result.paths
//                          .map((path) => ImageWithCaption(path, ""))
//                          .toList();
//                      setState(() {
//                        widget.imageWithCaptionList.addAll(re);
//                      });
//                    }
//                  },
//                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(widget.imageWithCaptionList);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
