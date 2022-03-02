import 'dart:async';
import 'dart:developer';
import 'dart:io' as fileInstance;
import 'dart:isolate';
import 'package:chatsample/blocs/ContactBloc.dart';
import 'package:chatsample/blocs/MessageBloc.dart';
import 'package:chatsample/db/api/MessageApi.dart';
import 'package:chatsample/enums/bubble_type.dart';
import 'package:chatsample/enums/connectivity_status.dart';
import 'package:chatsample/models/Message.dart';
import 'package:chatsample/services/xmppService.dart';
import 'package:chatsample/ui/shared/app_colors.dart';
import 'package:chatsample/ui/widgets/GroupMemberInfo.dart';
import 'package:chatsample/utils/Utils.dart';
import 'package:chatsample/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

void getMessages(SendPort mainSendPort) async {
  try {
    ReceivePort mainToIsolateStream = ReceivePort();
    mainSendPort.send(mainToIsolateStream.sendPort);
    mainToIsolateStream.listen((message) async {
      String username = message['userName'].toString();
      List<Message> messages = await MessageApi.getUnReadMessagesWithJid(username);
      for (final Message element in messages) {
        if (element.senderJid.split('/')[0] == '${username}@xrstudio.in') {
          if (element.id != null) {
            await AppWidgets.sendCustomMessage(element, username);
            await AppWidgets.readReceipt(element);
          }
        }
      }
      mainSendPort.send('Done');
    });
  } catch (e, s) {
    print('Isolate catch block ==> Error: $e StackTrace: $s');
  }
}

class ConversationPage extends StatefulWidget {
  ConversationPage({Key key, this.title, this.connectivityStatus, this.conversationType})
      : super(key: key);
  final String title;
  final int conversationType;
  final ConnectivityStatus connectivityStatus;

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController textEditingController = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  String mediaURL;
  BubbleType bubbleType = BubbleType.TEXT;
  List groupMembersList;
  List admins;
  ValueNotifier<int> textLength = ValueNotifier(0);
  FlutterIsolate isolate;
  ReceivePort receivePort = ReceivePort();
  MessageBloc messageBloc;
  String userName;
  int lengthOfMessage = 0;

  @override
  void initState() {
    userName = widget.title;
    messageBloc = MessageBloc.instance;
    ContactBloc.instance.setCurrentContact(widget.title);
    // widget.conversationType == 1 ? AppWidgets.getAdmins(userName: widget.title) : null;
    widget.conversationType == 0 ? getMessagesByIsolate() : null;
    super.initState();
  }

  @override
  void dispose() {
    ContactBloc.instance.setCurrentContact(Utils.emptyString);
    receivePort.close();
    super.dispose();
  }

  Future<void> createIsolate() async {
    ReceivePort newReceivePort = ReceivePort();
    final FlutterIsolate isolate = await FlutterIsolate.spawn(getMessages, newReceivePort.sendPort);
    newReceivePort.listen((message) async {
      if (message is SendPort) {
        SendPort mainToIsolateStream = message;
        mainToIsolateStream.send(
          {"userName": "${widget.title}"},
        );
      }
      if (message.toString() == 'Done') {
        log('createIsolate killed');
        isolate.kill();
      }
      print('New message from createIsolate: $message');
    });
  }

  @override
  Widget build(BuildContext context) {
    messageBloc.getMessagesWithJid(widget.title);
    XmppService.instance.getConnectivityStatus();
    return Scaffold(
      appBar: appBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.white,
              child: StreamBuilder<List<Message>>(
                stream: messageBloc.messageListObserver,
                builder: (context, snapshot) {
                  List<Message> messages = new List<Message>();
                  if (snapshot.hasData) {
                    messages = snapshot.data;
                    if (lengthOfMessage < messages.length) {
                      lengthOfMessage = messages.length;
                      createIsolate();
                    }
                    messages.sort((a, b) =>
                        b.time.toString().toLowerCase().compareTo(a.time.toString().toLowerCase()));
                  }
                  return Container(
                    margin: EdgeInsets.only(bottom: 2),
                    child: ListView.builder(
                      itemCount: messages.length,
                      addAutomaticKeepAlives: true,
                      reverse: true,
                      itemBuilder: (BuildContext context, int index) =>
                          AppWidgets.buildBubble(context, messages[index], widget.conversationType),
                    ),
                  );
                },
              ),
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget appBar(context) {
    return AppBar(
      iconTheme: new IconThemeData(color: Colors.white),
      backgroundColor: blueGrayColor,
      leadingWidth: 40,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 2.2.h,
            backgroundColor: Color(0xffDEDEDE),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Image.asset(
                'assets/icon_user.png',
              ),
            ),
          ),
          SizedBox(
            width: 3.w,
          ),
          StreamBuilder<String>(
              stream: XmppService.instance.connectionObserver,
              builder: (context, snapshot) {
                String title = "${widget.title}";
                if (snapshot.hasData) {
                  title += "(${snapshot.data})";
                }
                return Flexible(
                  child: GestureDetector(
                    onTap: () async {
                      if (widget.conversationType == 1) {
                        groupMembersList =
                            await XmppService.instance.getMember(groupName: widget.title);
                        setState(() {});
                        log(groupMembersList.toString());
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                GroupMemberInfo(groupMembersList ?? [], widget.title),
                          ),
                        );
                      }
                    },
                    child: Text(
                      "$title",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () async {
            AppWidgets.bottomSheet(
                context, (widget.conversationType == Utils.conversationTypeGroup), widget.title);
          },
          icon: Icon(Icons.more_vert),
        )
      ],
    );
  }

  Widget _buildInput() {
    return Container(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          SizedBox(
            width: 5.w,
          ),
          Container(
            width: 2.7.h,
            height: 2.7.h,
            alignment: Alignment.center,
            child: InkWell(
              onTap: getImage,
              child: Image.asset('assets/imoges.png'),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: TextField(
                onChanged: (value) {
                  textLength.value = textEditingController.text.length;
                },
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  fontSize: 18.0,
                ),
                controller: textEditingController,
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: getImage,
            child: Image.asset(
              'assets/camera.png',
              width: 2.7.h,
              height: 2.7.h,
            ),
          ),
          SizedBox(
            width: 5.w,
          ),
          ValueListenableBuilder(
              valueListenable: textLength,
              builder: (context, int _textLength, child) {
                return _textLength != 0
                    ? InkWell(
                        onTap: () {
                          textLength.value != 0
                              ? addMessageWithType(textEditingController.text, mediaURL, bubbleType)
                              : null;
                          textLength.value = 0;
                        },
                        child: Image.asset(
                          'assets/Send.png',
                          width: 2.7.h,
                          height: 2.5.h,
                        ),
                      )
                    : Image.asset(
                        'assets/Send.png',
                        color: Colors.grey.withOpacity(0.5),
                        width: 2.7.h,
                        height: 2.5.h,
                      );
              }),
          SizedBox(
            width: 5.w,
          ),
        ],
      ),
    );
  }

  Future getImage() async {
    final picker = ImagePicker();
    fileInstance.File _image;
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = fileInstance.File(pickedFile.path);
      mediaURL = pickedFile.path;
      bubbleType = BubbleType.IMAGE;
/*      List<ImageWithCaption> imges = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CaptionScreen([ImageWithCaption(_image.path, "")])),
      );

      if (imges != null) {
        imges.forEach((element) {
          _addMessageWithType(element.caption ?? "", element.filePath, BubbleType.IMAGE);
        });
      }*/
    } else {
      print('No image selected.');
    }
  }

  void addMessageWithType(String message, mediaURL, BubbleType bubbleType) {
    if (message != null) {
      textEditingController.clear();
      messageBloc.addMessageWithType(
          message, widget.title, widget.conversationType, bubbleType, mediaURL);
      //TODO : check it don't clear before data send
      this.mediaURL = null;
      this.bubbleType = BubbleType.TEXT;
    }
  }

  void getMessagesByIsolate() async {
    try {
      isolate = await FlutterIsolate.spawn(getMessages, receivePort.sendPort);
      // ReceivePort receivePort = ReceivePort();
      // FlutterIsolate isolate = await FlutterIsolate.spawn(getMessages, receivePort.sendPort);
      // var database = await MessageApi.databaseHelper.db;
      receivePort.listen((message) async {
        if (message is SendPort) {
          SendPort mainToIsolateStream = message;
          mainToIsolateStream.send(
            {"userName": "${widget.title}"},
          );
        }
        if (message.toString() == 'Done') {
          isolate.kill();
        }
        print('New message from Isolate: $message');
      });
    } catch (e, s) {
      print("Error: $e//$s");
    }
  }
}

class ImageWithCaption {
  String filePath;
  String caption;

  ImageWithCaption(this.filePath, this.caption);
}
