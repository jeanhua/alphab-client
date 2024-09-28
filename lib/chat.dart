import 'dart:convert';
import 'dart:io';
import 'package:alphab/core.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/scheduler.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class chatpage extends StatefulWidget {
  chatpage({super.key, required this.pushData});
  final Map pushData;
  @override
  State<StatefulWidget> createState() => chatpageState();
}

class chatpageState extends State<chatpage> {
  final textController_message = TextEditingController();
  final scrollController_scoll = ScrollController();
  var isShowButton = false;
  var emojiShow = false;
  var isCountSize = false;
  late double ScreenWidth;
  late double ScreenHeight;
  FocusNode focusnode_message = FocusNode();

  // 刷新页面
  updatePage() {
    setState(() {});
    // 等待框架渲染完成
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        scrollController_scoll
            .jumpTo(scrollController_scoll.position.maxScrollExtent);
      });
    });
  }

  // 断开连接
  disconnect() async {
    notice_dialog("与服务器断开连接！", "提示");
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    ///添加获取焦点与失去焦点的兼听
    focusnode_message.addListener(() {
      ///当前兼听的 TextFeild 是否获取了输入焦点
      bool hasFocus = focusnode_message.hasFocus;
      if (hasFocus) {
        if (emojiShow) {
          setState(() {
            emojiShow = false;
          });
        }
      }
    });
    super.initState();
    Core.updatePage = updatePage;
    Core.disconnect = disconnect;
    Core.player.audioCache.prefix = "assets/audios/";
  }

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
    const rowMaxLength = 13;
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
      return Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image(
              image: const AssetImage('assets/images/head.png'),
              height: 50,
              color: headNameColor,
            ),
            SizedBox(
                width: ScreenWidth - 75,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          name,
                          style: TextStyle(color: headNameColor, fontSize: 15),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1),
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
                                Clipboard.setData(ClipboardData(text: text))
                                    .then((_) {
                                  // 显示一个SnackBar来通知用户文本已被复制
                                  const snackBar =
                                      SnackBar(content: Text('文本已复制到剪贴板'));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
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
                      ],
                    ),
                  ],
                ))
          ],
        ),
      );
    }
    // 右边气泡
    else {
      return Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
                width: ScreenWidth - 75,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Tooltip(
                        message: isSuccess ? "发送成功" : "发送中",
                        child: Icon(
                          isSuccess ? Icons.check_circle : Icons.update_rounded,
                          color: Colors.lightGreen,
                        )),
                    Column(
                      children: [
                        SizedBox(
                          child: Text(
                            name,
                            style:
                                TextStyle(color: headNameColor, fontSize: 15),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1),
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
                                Clipboard.setData(ClipboardData(text: text))
                                    .then((_) {
                                  // 显示一个SnackBar来通知用户文本已被复制
                                  const snackBar =
                                      SnackBar(content: Text('文本已复制到剪贴板'));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
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
                      ],
                    ),
                  ],
                )),
            Image(
              image: const AssetImage('assets/images/head.png'),
              height: 50,
              color: headNameColor,
            ),
          ],
        ),
      );
    }
  }

  // 图片行
  chatRowImage(
      BuildContext context, String id, String name, String image, String size,
      [bool isRight = false,
      Color headNameColor = Colors.blue,
      Color bubbleColor = Colors.grey,
      bool isSuccess = false,
      bool isAlready = false]) {
    if (!isRight) {
      return Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image(
              image: const AssetImage('assets/images/head.png'),
              height: 50,
              color: headNameColor,
            ),
            SizedBox(
                width: ScreenWidth - 75,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          name,
                          style: TextStyle(color: headNameColor, fontSize: 15),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1),
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
                                if (isAlready) {
                                  return;
                                }
                                if (!Core.waitForData) {
                                  Core.waitForData = true;
                                  Future.delayed(const Duration(seconds: 5),
                                      () {
                                    Core.waitForData = false;
                                  });
                                } else {
                                  notice_dialog("点太急了，等会😡");
                                  return;
                                }
                                var res = Core.getDataBase64(id);
                                if (res != "success") {
                                  notice_dialog(res);
                                }
                              },
                              child: isAlready == false
                                  ? const Image(
                                      image: AssetImage(
                                          "assets/images/loadImage.png"))
                                  : Image.memory(
                                      base64.decoder.convert(image),
                                      width: double.parse(size.split('x')[0]) <
                                              ScreenWidth / 2
                                          ? double.parse(size.split('x')[0])
                                          : ScreenWidth / 2,
                                      fit: BoxFit.cover,
                                      gaplessPlayback: true,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ))
          ],
        ),
      );
      // 右边气泡
    } else {
      return Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
                width: ScreenWidth - 75,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Tooltip(
                        message: isSuccess ? "发送成功" : "发送中",
                        child: Icon(
                          isSuccess ? Icons.check_circle : Icons.update_rounded,
                          color: Colors.lightGreen,
                        )),
                    Column(
                      children: [
                        SizedBox(
                          child: Text(
                            name,
                            style:
                                TextStyle(color: headNameColor, fontSize: 15),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(0),
                                  topRight: Radius.circular(16.0),
                                  bottomLeft: Radius.circular(16.0),
                                  bottomRight: Radius.circular(16.0),
                                ),
                                color: bubbleColor),
                            child: Image.memory(
                              base64.decoder.convert(image),
                              width: double.parse(size.split('x')[0]) <
                                      ScreenWidth / 2
                                  ? double.parse(size.split('x')[0])
                                  : ScreenWidth / 2,
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
            Image(
                image: const AssetImage("assets/images/head.png"),
                color: headNameColor,
                height: 50),
          ],
        ),
      );
    }
  }

  chatRowDimage(
      BuildContext context, String id, String name, String image, String size,
      [Color headNameColor = Colors.blue,
      Color bubbleColor = Colors.grey,
      bool isSuccess = false,
      bool isAlready = false,
      bool isRead = false]) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image(
            image: const AssetImage('assets/images/head.png'),
            height: 50,
            color: headNameColor,
          ),
          SizedBox(
              width: ScreenWidth / 3 * 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Text(
                        name,
                        style: TextStyle(color: headNameColor, fontSize: 15),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(1),
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
                              if (isAlready) {
                                return;
                              }
                              if (Core.waitForDimage) {
                                return;
                              }
                              if (!Core.waitForData) {
                                Core.waitForData = true;
                                Future.delayed(const Duration(seconds: 5), () {
                                  Core.waitForData = false;
                                });
                              } else {
                                notice_dialog("点太急了，等会😡");
                                return;
                              }
                              var res = Core.getDataBase64(id);
                              if (res != "success") {
                                notice_dialog(res);
                              }
                            },
                            child: isAlready == false
                                ? Image(
                                    image:
                                        const AssetImage("assets/images/Dimage.png"),
                                    width: ScreenWidth / 2,
                                  )
                                : (isRead
                                    ? const Image(
                                        image: AssetImage(
                                            "assets/images/broken.png"))
                                    : Image.memory(
                                        base64.decoder.convert(image),
                                        width: double.parse(
                                                    size.split('x')[0]) <
                                                ScreenWidth / 2
                                            ? double.parse(size.split('x')[0])
                                            : ScreenWidth / 2,
                                        fit: BoxFit.cover,
                                        gaplessPlayback: true,
                                      )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )),
          const Tooltip(
            message: "闪照消息",
            child: Icon(
              Icons.image_not_supported,
              color: Colors.lightGreen,
            ),
          ),
        ],
      ),
    );
  }
  // <-----------------------消息行生成结束----------------------->

  @override
  Widget build(BuildContext context) {
    if (!isCountSize) {
      ScreenHeight = MediaQuery.sizeOf(context).height;
      ScreenWidth = MediaQuery.sizeOf(context).width;
      isCountSize = true;
    }
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: const Text("AlphaB —— safe and anonymous chat"),
          backgroundColor: Colors.redAccent,
        ),
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/bg1.png'),
                  fit: BoxFit.cover)),
          child: Column(children: [
            Expanded(
              child: Scrollbar(
                  thickness: 8.0, // 滚动条的厚度
                  radius: const Radius.circular(20.0), // 滚动条的圆角
                  thumbVisibility: true, // 是否总是显示滚动条滑块
                  controller: scrollController_scoll,
                  child: ListView.builder(
                      addAutomaticKeepAlives: true,
                      addRepaintBoundaries: true,
                      itemCount: Core.rowMessage.length,
                      controller: scrollController_scoll,
                      itemBuilder: (BuildContext builContext, int index) {
                        var any = Core.rowMessage[index];
                        if (any['type'] == "message") {
                          return chatRowText(
                              context,
                              any['name'] as String,
                              any['text'] as String,
                              any['id'] as String,
                              any['isRight'] as bool,
                              Color(int.parse(any['head color'] as String)),
                              Color(int.parse(any['bubble color'] as String)),
                              any['isSuccess'] as bool);
                        } else if (any['type'] == 'image') {
                          return chatRowImage(
                              context,
                              any['id'] as String,
                              any['name'] as String,
                              any['data'] as String,
                              any['size'] as String,
                              any['isRight'] as bool,
                              Color(int.parse(any['head color'] as String)),
                              Color(int.parse(any['bubble color'] as String)),
                              any['isSuccess'] as bool,
                              any['isAlready'] as bool);
                        } else if (any['type'] == 'disposable image') {
                          return chatRowDimage(
                              context,
                              any['id'] as String,
                              any['name'] as String,
                              any['data'] as String,
                              any['size'] as String,
                              Color(int.parse(any['head color'] as String)),
                              Color(int.parse(any['bubble color'] as String)),
                              any['isSuccess'] as bool,
                              any['isAlready'] as bool,
                              any['isRead'] as bool);
                        }
                      })),
            ),
            Visibility(
              visible: !Core.isConnect,
              child: SizedBox(
                width: ScreenWidth / 2,
                child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.lightGreen),
                    onPressed: () {
                      Core.connect(Core.ip, int.parse(Core.port));
                    },
                    child: const Text("断线重连")),
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
                    focusNode: focusnode_message,
                    style: const TextStyle(color: Colors.black, fontSize: 20),
                    maxLines: null,
                    controller: textController_message,
                    onChanged: (String text) {
                      // 内容改变事件
                      if (textController_message.text != "" &&
                          isShowButton == false) {
                        setState(() {
                          isShowButton = true;
                        });
                      } else if (textController_message.text == "" &&
                          isShowButton == true) {
                        setState(() {
                          isShowButton = false;
                        });
                      }
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
                Visibility(
                    visible: isShowButton,
                    child: TextButton(
                      onPressed: () async {
                        //发送按钮点击事件
                        if (textController_message.text == "") {
                          return;
                        }
                        String id = Core.getMessageId();
                        String result =
                            Core.sendMessage(textController_message.text, id);
                        if (result != "success") {
                          notice_dialog(result);
                        } else {
                          Core.rowMessage.add({
                            'type': 'message',
                            'id': id,
                            'name': Core.name,
                            'text': textController_message.text,
                            'head color': Core.headColor,
                            'bubble color': Core.bubbleColor,
                            'isRight': true,
                            'isSuccess': false,
                          });
                          setState(() {});
                          await Core.player.play(AssetSource('send.wav'));
                          textController_message.text = "";
                          focusnode_message.unfocus();
                        }
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
                    ))
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
                  MouseRegion(
                    onEnter: (_) {
                      Core.player.play(AssetSource("click.mp3"));
                    },
                    child: IconButton(
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
                          Core.bubbleColor =
                              ret['bubbleColor'].value.toString();
                          Core.name = ret['nickName'];
                        });
                      },
                      icon: const Icon(Icons.settings),
                      tooltip: '设置',
                    ),
                  ),
                  MouseRegion(
                    onEnter: (_) {
                      Core.player.play(AssetSource("click.mp3"));
                    },
                    child: IconButton(
                      onPressed: () async {
                        late File file;
                        FilePickerResult? isFile = await FilePicker.platform
                            .pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ["jpg", "jpeg", "png"]);
                        if (isFile != null) {
                          file = File(isFile.files.single.path!);
                        } else {
                          return;
                        }
                        var imageBytes = file.readAsBytesSync();
                        var image = await decodeImageFromList(imageBytes);
                        String id = Core.getMessageId();
                        var bs64 = base64Encode(imageBytes);
                        String size = "${image.width}x${image.height}";
                        String result = Core.sendImage(bs64, id, size);
                        if (result != "success") {
                          notice_dialog(result);
                        } else {
                          Core.rowMessage.add({
                            'type': 'image',
                            'id': id,
                            'name': Core.name,
                            'data': bs64,
                            'head color': Core.headColor,
                            'isRight': true,
                            'bubble color': Core.bubbleColor,
                            'size': size,
                            'isSuccess': false,
                            'isAlready': true,
                          });
                          Core.player.play(AssetSource("send.wav"));
                          setState(() {});
                        }
                      },
                      icon: const Icon(Icons.image),
                      tooltip: '发送图片',
                    ),
                  ),
                  MouseRegion(
                    onEnter: (_) {
                      Core.player.play(AssetSource("click.mp3"));
                    },
                    child: IconButton(
                      onPressed: () async {
                        late File file;
                        FilePickerResult? isFile = await FilePicker.platform
                            .pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ["jpg", "jpeg", "png"]);
                        if (isFile != null) {
                          file = File(isFile.files.single.path!);
                        } else {
                          return;
                        }
                        var imageBytes = file.readAsBytesSync();
                        var image = await decodeImageFromList(imageBytes);
                        String id = Core.getMessageId();
                        var bs64 = base64Encode(imageBytes);
                        String size = "${image.width}x${image.height}";
                        String result =
                            Core.sendDisposableImage(bs64, id, size);
                        if (result != "success") {
                          notice_dialog(result);
                        } else {
                          Core.rowMessage.add({
                            'type': 'image',
                            'id': id,
                            'name': Core.name,
                            'data': bs64,
                            'head color': Core.headColor,
                            'isRight': true,
                            'bubble color': Core.bubbleColor,
                            'size': size,
                            'isSuccess': false,
                            'isAlready': true,
                          });
                          Core.player.play(AssetSource("send.wav"));
                          setState(() {});
                        }
                      },
                      icon: const Icon(
                        Icons.image_not_supported_sharp,
                      ),
                      tooltip: '发送闪照',
                    ),
                  ),
                  MouseRegion(
                    onEnter: (_) {
                      Core.player.play(AssetSource("click.mp3"));
                    },
                    child: IconButton(
                      onPressed: () {
                        notice_dialog("还没做好🤣");
                      },
                      icon: const Icon(Icons.keyboard_voice),
                      tooltip: '发送语音',
                    ),
                  ),
                  MouseRegion(
                    onEnter: (_) {
                      Core.player.play(AssetSource("click.mp3"));
                    },
                    child: IconButton(
                      onPressed: () {
                        focusnode_message.unfocus();
                        setState(() {
                          emojiShow = !emojiShow;
                        });
                      },
                      icon: const Icon(Icons.emoji_emotions),
                      tooltip: '发送emoji',
                    ),
                  )
                ],
              ),
            ),
            Visibility(
              visible: emojiShow,
              child: Container(
                decoration: const BoxDecoration(
                    color: Color.fromARGB(100, 255, 255, 255)),
                child: Row(
                  children: [
                    SizedBox(
                      width: ScreenWidth,
                      height: ScreenHeight / 3,
                      child: EmojiPicker(
                        onEmojiSelected: (Category? category, Emoji emoji) {
                          // Do something when emoji is tapped (optional)
                        },
                        onBackspacePressed: () {
                          // Do something when the user taps the backspace button (optional)
                          // Set it to null to hide the Backspace-Button
                        },
                        textEditingController:
                            textController_message, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                        config: const Config(
                          height: 256,
                          //bgColor: const Color(0xFFF2F2F2),
                          checkPlatformCompatibility: true,
                          emojiViewConfig: EmojiViewConfig(),
                          swapCategoryAndBottomBar: false,
                          skinToneConfig: SkinToneConfig(),
                          categoryViewConfig: CategoryViewConfig(),
                          bottomActionBarConfig: BottomActionBarConfig(),
                          searchViewConfig: SearchViewConfig(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
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
                image: AssetImage("assets/images/bg.jpg"), fit: BoxFit.cover)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image(
                        image: const AssetImage('assets/images/head.png'),
                        height: 50,
                        color: Color(int.parse(Core.headColor)),
                      ),
                      SizedBox(
                          height: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    Core.name,
                                    style: TextStyle(
                                        color: Color(int.parse(Core.headColor)),
                                        fontSize: 15),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(1),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(0),
                                            topRight: Radius.circular(16.0),
                                            bottomLeft: Radius.circular(16.0),
                                            bottomRight: Radius.circular(16.0),
                                          ),
                                          color: Color(
                                              int.parse(Core.bubbleColor))),
                                      child: GestureDetector(
                                        child: const Text(
                                          ' 你好 ',
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                          softWrap: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ))
                    ],
                  ),
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
