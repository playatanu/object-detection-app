import 'dart:developer';
import 'package:flutter_pytorch/pigeon.dart';

String recognitionsToOutput(List<ResultObjectDetection?> recognitions) {
  if (recognitions.isEmpty) {
    log('no object found');
    return 'no object found';
  }

  String objectListText = '';
  String outputText = '';

  for (var element in recognitions) {
    objectListText =
        "$objectListText ${element!.className} ${element.score.toStringAsFixed(2)}";

    outputText = "$outputText ${element.className}";
  }

  log(objectListText);
  return outputText;
}
