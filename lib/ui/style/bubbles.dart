import 'dart:ui';

import 'package:bubble/bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

BubbleStyle styleSomebody = BubbleStyle(
  nip: BubbleNip.leftTop,
  color: Color(0xffE3F2FF),
  elevation: 5,
  margin: BubbleEdges.only(top: 2.0, right: 50.0),
  alignment: Alignment.topLeft,
);

BubbleStyle styleMe = BubbleStyle(
  nip: BubbleNip.rightTop,
  color: Color(0xffF0F0F0),
  elevation: 5,
  margin: BubbleEdges.only(top: 2.0, left: 50.0),
  alignment: Alignment.topRight,
);
