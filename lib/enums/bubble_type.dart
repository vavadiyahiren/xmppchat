enum BubbleType { TEXT, IMAGE, VIDEO }

String bubbleTypeToString(BubbleType bubbleType) {
  return '$BubbleType'.split('.').last;
}
