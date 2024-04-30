import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class MultiWindow extends StatefulWidget {
  const MultiWindow({super.key});

  @override
  State<MultiWindow> createState() => _MultiWindowState();
}

class _MultiWindowState extends State<MultiWindow> {

  @override
  void initState() {
    super.initState();
    createQrWindow();
    //createWindow();
  }

  Future<void> createQrWindow() async {
    await windowManager.ensureInitialized();
    windowManager.setSize(Size(250, 250));
    windowManager.setPosition(Offset(1460, 0));
  }

  Future<void> closeSubWindow() async {
    var ids = await DesktopMultiWindow.getAllSubWindowIds();
    for (var id in ids) {
      WindowController.fromWindowId(id).close();
    }
  }

  Future<void> createWindow() async {
    final window = await DesktopMultiWindow.createWindow(jsonEncode({
    }));
    window
      ..setFrame(const Offset(0, 0) & const Size(1280, 720))
      ..center()
      ..setTitle('Another window')
      ..show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final window = await DesktopMultiWindow.createWindow(jsonEncode({
            }));
            window
              ..setFrame(const Offset(0, 0) & const Size(600, 600))
              ..center()
              ..setTitle('Meeting Dashboard')
              ..show();
        },
          child: Text("New window"),
        ),
      ),
    );
  }
}
