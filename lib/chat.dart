import 'dart:convert';

import 'package:alphab/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class chatpage extends StatefulWidget {
  chatpage({super.key, required this.pushData});
  final Map pushData;
  @override
  State<StatefulWidget> createState() => _chatpage();
}

class _chatpage extends State<chatpage> {
  final textController_message = TextEditingController();
  final scrollController_scoll = ScrollController();
  // 弹出提示框
  void notice_dialog(String noticeText, [String title = "提示"]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: Text(
            noticeText,
            style: const TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
            ),
          ],
        );
      },
    );
  }

  // <-----------------------消息行生成开始----------------------->
  // 文本行
  chatRowText(BuildContext context, String name, String text, String id,
      [bool isRight = false,
      Color headNameColor = Colors.blue,
      Color bubbleColor = Colors.grey,
      bool isSuccess = false]) {
    // 处理text溢出
    const rowMaxLength = 30;
    if (text.length > rowMaxLength) {
      var textdeal = "";
      int j = 0;
      for (int i = 0; i < text.length; i++) {
        textdeal += text[i];
        if (j == rowMaxLength) {
          j = 0;
          textdeal += '\n';
        }
        j++;
      }
      text = textdeal;
    }
    // 左边气泡
    if (!isRight) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image(
            image: const AssetImage('images/head.png'),
            height: 50,
            color: headNameColor,
          ),
          Text(
            name,
            style: TextStyle(color: headNameColor, fontSize: 25),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(16.0),
                    bottomLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
                  color: bubbleColor),
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: text)).then((_) {
                    // 显示一个SnackBar来通知用户文本已被复制
                    const snackBar = SnackBar(content: Text('文本已复制到剪贴板'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  });
                },
                child: Text(
                  ' $text ',
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  softWrap: true,
                ),
              ),
            ),
          ),
          Tooltip(
              message: isSuccess ? "发送成功" : "发送中",
              child:
                  Icon(isSuccess ? Icons.check_circle : Icons.update_rounded))
        ],
      );
    }
    // 右边气泡
    else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Tooltip(
              message: isSuccess ? "发送成功" : "发送中",
              child:
                  Icon(isSuccess ? Icons.check_circle : Icons.update_rounded)),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(0),
                    bottomLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
                  color: bubbleColor),
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: text)).then((_) {
                    // 显示一个SnackBar来通知用户文本已被复制
                    const snackBar = SnackBar(content: Text('文本已复制到剪贴板'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  });
                },
                child: Text(
                  ' $text ',
                  style: const TextStyle(fontSize: 20),
                  softWrap: true,
                ),
              ),
            ),
          ),
          Text(
            name,
            style: TextStyle(color: headNameColor, fontSize: 25),
          ),
          Image(
            image: const AssetImage('images/head.png'),
            height: 50,
            color: headNameColor,
          ),
        ],
      );
    }
  }

  // 图片行
  chatRowImage(BuildContext context, String name, Uint8List image,
      [bool isRight = false,
      Color headNameColor = Colors.blue,
      Color bubbleColor = Colors.grey,
      bool isSuccess = false]) {
    if (!isRight) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.memory(image, color: headNameColor, height: 50),
          Text(
            name,
            style: TextStyle(color: headNameColor, fontSize: 25),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(16.0),
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    ),
                    color: bubbleColor),
                child: const Image(
                  image: AssetImage('images/test.jpg'),
                  width: 250,
                )),
          ),
          Tooltip(
              message: isSuccess ? "发送成功" : "发送中",
              child:
                  Icon(isSuccess ? Icons.check_circle : Icons.update_rounded)),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Tooltip(
              message: isSuccess ? "发送成功" : "发送中",
              child:
                  Icon(isSuccess ? Icons.check_circle : Icons.update_rounded)),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(16.0),
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    ),
                    color: bubbleColor),
                child: const Image(
                  image: AssetImage('images/test.jpg'),
                  width: 250,
                )),
          ),
          Text(
            name,
            style: TextStyle(color: headNameColor, fontSize: 25),
          ),
          Image.memory(image, color: headNameColor, height: 50),
        ],
      );
    }
  }
  // <-----------------------消息行生成开始----------------------->

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: const Text("AlphaB —— safe and anonymous chat"),
          backgroundColor: Colors.redAccent,
        ),
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/bg.jpg'), fit: BoxFit.cover)),
          child: Column(children: [
            Expanded(
              child: Scrollbar(
                  thickness: 8.0, // 滚动条的厚度
                  radius: const Radius.circular(20.0), // 滚动条的圆角
                  thumbVisibility: true, // 是否总是显示滚动条滑块
                  controller: scrollController_scoll,
                  child: ListView.builder(
                      itemCount: Core.rowMessage.length,
                      reverse: Core.rowMessage.length>4?true:false,
                      itemBuilder: (BuildContext builContext, int index) {
                        var any = Core.rowMessage[index];
                          if (any['type'] == "message") {
                            return chatRowText(
                                context,
                                any['name'] as String,
                                any['text'] as String,
                                any['id'] as String,
                                false,
                                Color(int.parse(any['head color'] as String)),
                                Color(int.parse(any['bubble color'] as String)),
                                any['isSuccess'] as bool);
                          } else if (any['type'] == 'image') {
                            return chatRowImage(
                                context,
                                any['name'] as String,
                                any['data'] as Uint8List,
                                false,
                                Color(int.parse(any['head color'] as String)),
                                Color(int.parse(any['bubble color'] as String)),
                                any['isSuccess'] as bool);
                          }
                      })
                  //ListView(
                  //   shrinkWrap: true,
                  //   padding: const EdgeInsets.all(20),
                  //   children: [
                  //   ],
                  // ),
                  ),
            ),
            Row(
              children: [
                Expanded(
                    child: Container(
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(150, 255, 255, 255),
                      borderRadius: BorderRadius.circular(20)),
                  child: TextField(
                    style: const TextStyle(color: Colors.black, fontSize: 20),
                    maxLines: null,
                    controller: textController_message,
                    onChanged: (String text) {
                      // 内容改变事件
                      if (textController_message.text.split('\n').length > 10) {
                        var textList = textController_message.text.split('\n');
                        var newText = "";
                        for (int i = 0; i < 10; i++) {
                          newText += '${textList[i]}\n';
                        }
                        textController_message.text = newText;
                        notice_dialog("输入的太多了，装不下了🥵");
                      } else if (textController_message.text.length > 512) {
                        textController_message.text =
                            textController_message.text.substring(0, 512);
                        notice_dialog("输入的太多了，装不下了🥵");
                      }
                    },
                  ),
                )),
                TextButton(
                  onPressed: () {
                    //发送按钮点击事件
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.pressed)) {
                          return Colors.red.withOpacity(0.5); // 按下时的颜色
                        }
                        return Colors.blue; // 默认背景颜色
                      },
                    ),
                  ),
                  child: const Text("发送",
                      style: TextStyle(color: Colors.yellow, fontSize: 25)),
                )
              ],
            ),
            const Divider(
              height: 5,
              thickness: 1,
              color: Colors.white,
            ),
            // 多功能按钮栏
            Container(
              decoration: const BoxDecoration(
                  color: Color.fromARGB(100, 255, 255, 255)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () async {
                      var ret =
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => settings(
                                    headColorBefore:
                                        Color(int.parse(Core.headColor)),
                                    bubbleColorBefore:
                                        Color(int.parse(Core.bubbleColor)),
                                    nickName: Core.name,
                                  )));
                      setState(() {
                        Core.headColor = ret['headColor'].value.toString();
                        Core.bubbleColor = ret['bubbleColor'].value.toString();
                        Core.name = ret['nickName'];
                      });
                    },
                    icon: const Icon(Icons.settings),
                    tooltip: '设置',
                  ),
                  IconButton(
                    onPressed: () {
                      notice_dialog("还没做好🤣");
                    },
                    icon: const Icon(Icons.image),
                    tooltip: '发送图片',
                  ),
                  IconButton(
                    onPressed: () {
                      notice_dialog("还没做好🤣");
                    },
                    icon: const Icon(Icons.image_not_supported_sharp),
                    tooltip: '发送闪照',
                  ),
                  IconButton(
                    onPressed: () {
                      notice_dialog("还没做好🤣");
                    },
                    icon: const Icon(Icons.keyboard_voice),
                    tooltip: '发送语音',
                  ),
                  IconButton(
                    onPressed: () {
                      notice_dialog("还没做好🤣");
                    },
                    icon: const Icon(Icons.voice_chat),
                    tooltip: '语音通话',
                  ),
                  IconButton(
                    onPressed: () {
                      notice_dialog("还没做好🤣");
                    },
                    icon: const Icon(Icons.video_call),
                    tooltip: '视频通话',
                  ),
                ],
              ),
            ),
          ]),
        ));
  }
}

class settings extends StatefulWidget {
  final Color headColorBefore;
  final Color bubbleColorBefore;
  final String nickName;
  const settings(
      {super.key,
      required this.headColorBefore,
      required this.bubbleColorBefore,
      required this.nickName});
  @override
  State<StatefulWidget> createState() => _settings();
}

class _settings extends State<settings> {
  final textControllerNickName = TextEditingController();
  _settings();

  @override
  void dispose() {
    // TODO: implement dispose
    textControllerNickName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    textControllerNickName.text = Core.name;
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text("settings"),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop({
              'headColor': Color(int.parse(Core.headColor)),
              'bubbleColor': Color(int.parse(Core.bubbleColor)),
              'nickName': textControllerNickName.text == ""
                  ? "匿名"
                  : textControllerNickName.text
            });
          },
          icon: const Icon(Icons.keyboard_return_outlined),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/bg.jpg"), fit: BoxFit.cover)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "设置昵称：",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Padding(
                    padding: EdgeInsets.all(15),
                    child: SizedBox(
                      width: 200,
                      child: TextField(
                        controller: textControllerNickName,
                        decoration: const InputDecoration(
                          hintText: "请输入昵称",
                          labelText: "昵称",
                        ),
                        maxLength: 10,
                        style: const TextStyle(color: Colors.white),
                      ),
                    )),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    "头像和气泡颜色",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    tooltip: '头像颜色',
                    onPressed: () {
                      Color pickColor = Color(int.parse(Core.headColor));
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Pick a color!'),
                            content: SingleChildScrollView(
                              child: BlockPicker(
                                pickerColor: Color(int.parse(Core.headColor)),
                                onColorChanged: (Color colorNow) {
                                  pickColor = colorNow;
                                },
                              ),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                child: const Text('Got it'),
                                onPressed: () {
                                  setState(() {
                                    Core.headColor = pickColor.value.toString();
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.color_lens)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image(
                      image: const AssetImage('images/head.png'),
                      height: 50,
                      color: Color(int.parse(Core.headColor)),
                    ),
                    Text(
                      Core.name,
                      style: TextStyle(
                          color: Color(int.parse(Core.headColor)),
                          fontSize: 25),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(0),
                              topRight: Radius.circular(16.0),
                              bottomLeft: Radius.circular(16.0),
                              bottomRight: Radius.circular(16.0),
                            ),
                            color: Color(int.parse(Core.bubbleColor))),
                        child: GestureDetector(
                          onTap: () {},
                          child: const Text(
                            ' 你好 ',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                IconButton(
                    tooltip: '气泡颜色',
                    onPressed: () {
                      Color pickColor = Color(int.parse(Core.bubbleColor));
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Pick a color!'),
                            content: SingleChildScrollView(
                              child: BlockPicker(
                                pickerColor: Color(int.parse(Core.bubbleColor)),
                                onColorChanged: (Color colorNow) {
                                  pickColor = colorNow;
                                },
                              ),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                child: const Text('Got it'),
                                onPressed: () {
                                  setState(() {
                                    Core.bubbleColor =
                                        pickColor.value.toString();
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.color_lens))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
