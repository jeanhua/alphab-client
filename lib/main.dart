import 'dart:convert';
import 'dart:io';
import 'package:alphab/chat.dart';
import 'package:alphab/core.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const alphab());
}

class alphab extends StatelessWidget {
  const alphab({super.key});

  @override
  Widget build(BuildContext context) {
    const String appTitle = "AlphaB —— safe and anonymous chat";
    // TODO: implement build
    return MaterialApp(
        title: appTitle,
        home: Scaffold(
          appBar: AppBar(
            title: const Text(
              appTitle,
              style: TextStyle(color: Colors.pinkAccent),
            ),
            backgroundColor: const Color.fromARGB(110, 255, 255, 255),
          ),
          body: const LoginPage(),
          extendBodyBehindAppBar: true,
        ));
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<StatefulWidget> createState() => LoginPageState();
}

// 首页
class LoginPageState extends State<LoginPage> {
  final textController_ip = TextEditingController();
  final textController_port = TextEditingController();
  // socket
  late Socket server;
  late bool isConnect = false;

  @override
  void dispose() {
    // TODO: implement dispose
    textController_ip.dispose();
    textController_port.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Core.routeToChat = routeToChat;
    if(File("./config.json").existsSync()){
      var jsonConfig = jsonDecode(File("./config.json").readAsStringSync());
      textController_ip.text = jsonConfig['ip'];
      textController_port.text = jsonConfig['port'];
    }
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

  // 页面跳转聊天界面
  void routeToChat() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => chatpage(pushData: {})),
        (context) => context == null);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage("images/bg.jpg"),
          fit: BoxFit.cover,
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
                child: Padding(
              padding: EdgeInsets.all(30),
              child: Image(
                image: AssetImage("images/head.png"),
                width: 150,
                height: 150,
              ),
            )),
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: SizedBox(
                      width: 300,
                      child: TextField(
                        controller: textController_ip,
                        decoration: const InputDecoration(
                          hintText: "请输入服务器IP地址",
                          labelText: "服务器",
                        ),
                        maxLength: 15,
                      ),
                    ))),
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: SizedBox(
                      width: 300,
                      child: TextField(
                        controller: textController_port,
                        decoration: const InputDecoration(
                          hintText: "请输入服务器端口地址",
                          labelText: "端口",
                        ),
                        maxLength: 5,
                      ),
                    ))),
            Center(
              child: SizedBox(
                width: 200,
                child: TextButton(
                  onPressed: () => {
                    Core.ip = textController_ip.text,
                    Core.port = textController_port.text,
                    Core.connect(textController_ip.text,int.parse(textController_port.text)),
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(100, 255, 255, 255),
                  ),
                  child: const Text(
                    "确定",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
