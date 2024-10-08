import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:path_provider/path_provider.dart';

class Core {
  static late VoidCallback routeToChat;
  static late VoidCallback updatePage;
  static late VoidCallback disconnect;
  Core();
  static late String ip;
  static late String port;
  static WebSocket? _server;
  static String? _AesKey;
  static var _publicKey;
  static var reConnect = false;
  static var _privateKey;
  static int _count = 0;
  static String _connectId = "";
  static bool isConnect = false;
  static bool waitForDimage = false;
  static bool waitForData = false;
  // 音频
  static AudioPlayer player = new AudioPlayer();
  // 全局消息链
  static var rowMessage = [];
  static String headColor = material.Colors.yellow.value.toString();
  static String bubbleColor = material.Colors.white.value.toString();
  static String name = getRandomName();

  static _generateRsaKey() async {
    if (!File("${(await getApplicationDocumentsDirectory()).path}/Key/publicKey.pem")
            .existsSync() ||
        !File("${(await getApplicationDocumentsDirectory()).path}/Key/privateKey.pem")
            .existsSync()) {
      final headers = {
        'Accept': 'application/json, text/javascript, */*; q=0.01',
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'Origin': 'https://www.bejson.com',
        'Pragma': 'no-cache',
        'Referer': 'https://www.bejson.com/enc/rsa/',
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'same-origin',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36 Edg/129.0.0.0',
        'X-Requested-With': 'XMLHttpRequest',
        'sec-ch-ua':
            '"Microsoft Edge";v="129", "Not=A?Brand";v="8", "Chromium";v="129"',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"Windows"',
      };
      var data = {
        'rsaLength': '2048',
        'rsaFormat': 'PKCS#1',
        'rsaPass': '',
      };
      var url = Uri.parse('https://www.bejson.com/Bejson/Api/Rsa/getRsaKey');
      final res = await http.post(url, headers: headers, body: data);
      final status = res.statusCode;
      if (status != 200)
        throw Exception('http.post error: statusCode= $status');
      var result = json.decode(res.body);
      var dir =
          Directory("${(await getApplicationDocumentsDirectory()).path}/Key");
      if (!dir.existsSync()) {
        dir.create();
      }
      await File(
              "${(await getApplicationDocumentsDirectory()).path}/Key/publicKey.pem")
          .writeAsString(result['data']['public']);
      await File(
              "${(await getApplicationDocumentsDirectory()).path}/Key/privateKey.pem")
          .writeAsString(result['data']['private']);
    }
    _publicKey = encrypt.RSAKeyParser().parse(File(
            "${(await getApplicationDocumentsDirectory()).path}/Key/publicKey.pem")
        .readAsStringSync());
    _privateKey = File(
            "${(await getApplicationDocumentsDirectory()).path}/Key/privateKey.pem")
        .readAsStringSync();
  }

  static getRandomName() {
    List<String> romanticUsernames = [
      "星河滚烫",
      "你是人间理想",
      "月色真美",
      "刚好遇见你",
      "心动瞬间",
      "甜蜜梦境",
      "温柔如你",
      "浪漫满屋",
      "花前月下",
      "情书予你",
      "诗酒趁年华",
      "余生请指教",
      "风花雪月",
      "海枯石烂",
      "陪你去看海",
      "心之所向",
      "玫瑰情话",
      "甜蜜约定",
      "恋恋不忘",
      "爱在心口难开",
      "白头偕老",
      "深情不及久伴",
      "你是我眼中的星",
      "岁月静好",
      "相濡以沫",
      "心有灵犀",
      "红尘有你",
      "爱的诺言",
      "情定三生",
      "一眼万年",
      "温柔岁月",
      "浪漫至死不渝"
    ];
    Random random = Random();
    int index = random.nextInt(romanticUsernames.length);
    return romanticUsernames[index];
  }

  static connect(String ip, int port) {
    WebSocket.connect("ws://$ip:$port").then((socket) async {
      _server = socket;
      Map message = {};
      _connectId = getMessageId();
      await _generateRsaKey();
      message['type'] = "connect";
      message['id'] = _connectId;
      message['public key'] = await File(
              "${(await getApplicationDocumentsDirectory()).path}/Key/publicKey.pem")
          .readAsString();
      String jsonMessage = json.encode(message);
      _server?.add(jsonMessage);
      _server?.listen((data) async {
        _messageDeal(utf8.decode(data));
      }, onError: (error) {
        _messageError(error.toString());
      }, onDone: () {
        disconnect();
        _disconnect();
      });
    });
  }

  static Future<String> RSAdecodeString(String content, String prikey) async {
    final privatePem = prikey;
    dynamic privateKey = encrypt.RSAKeyParser().parse(privatePem);
    final encrypter = encrypt.Encrypter(encrypt.RSA(privateKey: privateKey));
    return encrypter.decrypt(encrypt.Encrypted.fromBase64(content));
  }

  static String AesEncrypt(String content, String _key, String _iv) {
    var key = encrypt.Key.fromUtf8(_key);
    var iv = encrypt.IV.fromUtf8(_iv);
    var encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    var encrypted = encrypter.encrypt(content, iv: iv);
    return encrypted.base64;
  }

  static String AesDecrypt(String content, String _key, String _iv) {
    var key = encrypt.Key.fromUtf8(_key);
    var iv = encrypt.IV.fromUtf8(_iv);
    var encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    var decrypted =
        encrypter.decrypt(encrypt.Encrypted.from64(content), iv: iv);
    return decrypted;
  }

  static _messageDeal(String data) async {
    try {
      if (!isConnect) {
        var result = json.decode(data);
        if (result['type'] == 'connect' && result['id'] == _connectId) {
          _AesKey = await RSAdecodeString(
              result['AES key'].toString().replaceAll("\\u002B", "+"),
              _privateKey);
          Core.isConnect = true;
          late String config;
          if (File(
                  "${(await getApplicationDocumentsDirectory()).path}/config.json")
              .existsSync()) {
            config = File(
                    "${(await getApplicationDocumentsDirectory()).path}/config.json")
                .readAsStringSync();
            var jsonconfig = jsonDecode(config);
            jsonconfig['ip'] = ip;
            jsonconfig['port'] = port;
            File("${(await getApplicationDocumentsDirectory()).path}/config.json")
                .writeAsString(jsonEncode(jsonconfig));
          } else {
            Map configjson = new Map();
            configjson['ip'] = ip;
            configjson['port'] = port;
            File("${(await getApplicationDocumentsDirectory()).path}/config.json")
                .writeAsString(jsonEncode(configjson));
          }
          if (!reConnect) {
            routeToChat();
          }
          else{
            updatePage();
          }
        }
      } else {
        var result = json.decode(
            AesDecrypt(data, _AesKey!.split(':')[0], _AesKey!.split(':')[1]));
        var type = result['type'];
        // <-----------------------消息处理开始----------------------->
        // 主动接收
        if (type == 'message') {
          rowMessage.add({
            'type': 'message',
            'id': result['id'],
            'name': result['name'],
            'text': result['text'],
            'head color': result['head color'],
            'isRight': false,
            'bubble color': result['bubble color'],
            'isSuccess': false,
          });
          player.play(AssetSource("receive.mp3"));
        } else if (type == 'image') {
          rowMessage.add({
            'type': 'image',
            'id': result['id'],
            'name': result['name'],
            'data': result['data'],
            'head color': result['head color'],
            'isRight': false,
            'bubble color': result['bubble color'],
            'size': result['size'],
            'isSuccess': false,
            'isAlready': false
          });
          player.play(AssetSource("receive.mp3"));
        } else if (type == 'disposable image') {
          rowMessage.add({
            'type': 'disposable image',
            'id': result['id'],
            'name': result['name'],
            'data': result['data'],
            'head color': result['head color'],
            'bubble color': result['bubble color'],
            'isRight': false,
            'size': result['size'],
            'isSuccess': false,
            'isAlready': false,
            'isRead': false
          });
          player.play(AssetSource("receive.mp3"));
        } else if (type == 'audio') {
          rowMessage.add({
            'type': 'audio',
            'id': result['id'],
            'name': result['name'],
            'data': result['data'],
            'head color': result['head color'],
            'bubble color': result['bubble color'],
            'isRight': false,
            'isSuccess': false,
            'isAlready': false
          });
          player.play(AssetSource("receive.mp3"));
        } else if (type == 'data') {
          for (var i in rowMessage) {
            if (i["id"] == result['id']) {
              // 闪照5s后删除
              if (i["type"] == "disposable image") {
                waitForDimage = true;
                i['isAlready'] = true;
                i['data'] = result['data'];
                Future.delayed(const Duration(seconds: 5), () {
                  i['data'] = "";
                  i['isRead'] = true;
                  updatePage();
                  waitForDimage = false;
                });
                // 非闪照
              } else {
                i['isAlready'] = true;
                i['data'] = result['data'];
              }
              waitForData = false;
              break;
            }
          }
        }
        //消息回调
        else if (type == 'callback') {
          for (var any in rowMessage) {
            if (any['id'] == result['id']) {
              if (result['status'] == 'success') {
                any['isSuccess'] = true;
                break;
              }
            }
          }
        }
        updatePage();
        // <-----------------------消息处理完成----------------------->
      }
    } catch (e) {
      print('error$e');
    }
  }

  static _messageError(String error) {}
  static _disconnect() {
    _server = null;
    _AesKey = null;
    Core.isConnect = false;
    reConnect = true;
    print('断开连接');
  }

  static String getMessageId() {
    _count++;
    return "${DateTime.now().millisecondsSinceEpoch}$_count";
  }

  // <-----------------------消息发送区域开始----------------------->

  static String sendMessage(String text, String messageId) {
    if (_server == null || _AesKey == null || isConnect == false) {
      return "disconnect";
    }
    try {
      Map message = {};
      message['type'] = "message";
      message['id'] = messageId;
      message['name'] = name;
      message['head color'] = headColor;
      message['bubble color'] = bubbleColor;
      message['text'] = text;
      String jsonMessage = json.encode(message);
      var encryptMessage = AesEncrypt(
          jsonMessage, _AesKey!.split(":")[0], _AesKey!.split(":")[1]);
      _server?.add(encryptMessage);
      return "success";
    } catch (e) {
      return "error:${e.toString()}";
    }
  }

  static String getDataBase64(String id) {
    if (_server == null || _AesKey == null || isConnect == false) {
      return "disconnect";
    }
    try {
      Map message = {};
      message['type'] = "data";
      message['id'] = id;
      String jsonMessage = json.encode(message);
      var encryptMessage = AesEncrypt(
          jsonMessage, _AesKey!.split(":")[0], _AesKey!.split(":")[1]);
      _server?.add(encryptMessage);
      return "success";
    } catch (e) {
      return "error:${e.toString()}";
    }
  }

  static String sendImage(String image_bs64, String messageId, String size) {
    if (_server == null || _AesKey == null || isConnect == false) {
      return "disconnect";
    }
    try {
      Map message = {};
      message['type'] = "image";
      message['id'] = messageId;
      message['name'] = name;
      message['head color'] = headColor;
      message['bubble color'] = bubbleColor;
      message['data'] = image_bs64;
      message['size'] = size;
      String jsonMessage = json.encode(message);
      _server?.add(AesEncrypt(
          jsonMessage, _AesKey!.split(":")[0], _AesKey!.split(":")[1]));
      return "success";
    } catch (e) {
      return "error:${e.toString()}";
    }
  }

  static String sendAudio(String audio, String messageId) {
    if (_server == null || _AesKey == null || isConnect == false) {
      return "disconnect";
    }
    try {
      Map message = {};
      message['type'] = "audio";
      message['id'] = messageId;
      message['name'] = name;
      message['head color'] = headColor;
      message['bubble color'] = bubbleColor;
      message['data'] = audio;
      String jsonMessage = json.encode(message);
      _server?.add(AesEncrypt(
          jsonMessage, _AesKey!.split(":")[0], _AesKey!.split(":")[1]));
      return "success";
    } catch (e) {
      return "error:${e.toString()}";
    }
  }

  static String sendDisposableImage(
      String image_bs64, String messageId, String size) {
    if (_server == null || _AesKey == null || isConnect == false) {
      return "disconnect";
    }
    try {
      Map message = {};
      message['type'] = "disposable image";
      message['id'] = messageId;
      message['name'] = name;
      message['head color'] = headColor;
      message['bubble color'] = bubbleColor;
      message['data'] = image_bs64;
      message['size'] = size;
      String jsonMessage = json.encode(message);
      _server?.add(AesEncrypt(
          jsonMessage, _AesKey!.split(":")[0], _AesKey!.split(":")[1]));
      return "success";
    } catch (e) {
      return "error:${e.toString()}";
    }
  }
  // <-----------------------消息发送区域结束----------------------->
}
