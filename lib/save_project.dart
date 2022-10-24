// ONLY SUPPORTS Color.fromARGB(a, r, g, b)
// DONT USE 'Accent' COLORS!!

import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:event/event.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/rendering.dart';
import 'package:note_bus/freesketch.dart';
import 'package:note_bus/tools/platform_detector.dart';
import 'package:note_bus/widgets/drawboard_widget.dart';

class ProjectSaver {
  static ProjectSaver get instance => ProjectSaver();

  static Event onProjectLoaded = Event();
  static Event onProjectSaved = Event();

  void capturePng() async {
    try {
      log('inside');
      RenderRepaintBoundary? boundary = globalWidgetKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary?;
      ui.Image? image = await boundary?.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image?.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData?.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes!);
      log(pngBytes.toString());
      log(bs64.toString());

      //var x = Image.memory(base64Decode(bs64));

      await FileSaver.instance
          .saveFile('NoteBusFile', pngBytes, '.png', mimeType: MimeType.PNG);
    } catch (e) {
      log(e.toString());
    }
  }

  void saveFile() {
    for (var element in drawboardSketches) {
      element.initializePoints();
    }

    var projectData = '';
    for (var i = 0; i < drawboardSketches.length; i++) {
      var jsonString = json.encode(drawboardSketches[i].toJson());

      projectData += i == 0 ? jsonString : 'ß$jsonString';
    }

    var bytes = projectData.codeUnits;
    var uintList = Uint8List.fromList(bytes);

    FileSaver.instance.saveFile('Note Bus Project', uintList, 'ntbs');

    onProjectSaved.broadcast();
  }

  void loadFile() {
    _openFilePicker().then((value) {
      if (value != null) {
        // Clear drawboard before loading new one
        drawboardSketches.clear();

        drawboardSketches.addAll(value);
        onProjectLoaded.broadcast();
      } else {
        log('User not select any file');
      }
    });
  }

  Future<List<HandSketch>?> _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      Uint8List projectData;
      if (PlatformInfo.instance.isWeb()) {
        projectData = result.files.first.bytes!;
      } else {
        File file = File(result.files.single.path!);
        projectData = file.readAsBytesSync();
      }

      var projectString = String.fromCharCodes(projectData);
      var sketches = projectString.split('ß');

      List<HandSketch> finalList = [];

      for (var i = 0; i < sketches.length; i++) {
        Map<String, dynamic> jsonFile = jsonDecode(sketches[i]);
        HandSketch sketch = HandSketch.fromJson(jsonFile);
        finalList.add(sketch);
      }

      return finalList;
    } else {
      // User canceled the picker
      return null;
    }
  }
}

Color hexToColor(String code) {
  return Color(int.parse(code.substring(8, 16), radix: 16));
}
