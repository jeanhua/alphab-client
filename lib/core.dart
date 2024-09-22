import 'dart:convert';
import 'dart:io';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart' as material;
import 'package:http/http.dart' as http;

void main() {
  Core.connect('127.0.0.1', 1010);
}

class Core {
  Core();
  static Socket? _server;
  static String? _AesKey;
  static var _publicKey;
  static var _privateKey;
  static int _count = 0;
  static String _connectId = "";
  // 全局消息链
  static var rowMessage = [
    {
      "type": "message",
      "id": "43242",
      "name": "1匿名",
      "text": "你好！",
      "head color": "4280391411",
      "bubble color": "4294967295",
      "isSuccess": false
    },
    {
      "type": "message",
      "id": "4324215",
      "name": "2匿名",
      "text": "你好！",
      "head color": "4280391411",
      "bubble color": "4294967295",
      "isSuccess": true
    },
    {
      "type": "message",
      "id": "4324422",
      "name": "3匿名",
      "text": "你也好！",
      "head color": "4280391411",
      "bubble color": "4294967295",
      "isSuccess": false
    },
    {
      "type": "message",
      "id": "4324222",
      "name": "4匿名",
      "text": "1妙极了！",
      "head color": "4280391411",
      "bubble color": "4294967295",
      "isSuccess": false
    },
    {
      "type": "message",
      "id": "4324222",
      "name": "5匿名",
      "text": "1妙极了！",
      "head color": "4280391411",
      "bubble color": "4294967295",
      "isSuccess": false
    },
    {
      "type": "image",
      "id": "dwadwa",
      "name": "image1",
      "data":
          base64.decode("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"),
      "head color": "4280391411",
      "bubble color": "4294967295",
      "isSuccess":true,
      "size":"201x200"
    }
  ];
  static String headColor = material.Colors.blue.value.toString();
  static String bubbleColor = material.Colors.white.value.toString();
  static String name = "匿名";

  static _generateRsaKey() async {
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
    if (status != 200) throw Exception('http.post error: statusCode= $status');
    var result = json.decode(res.body);
    var dir = Directory("./Key");
    if (!dir.existsSync()) {
      dir.create();
    }
    await File("./Key/publicKey.pem").writeAsString(result['data']['public']);
    await File("./Key/privateKey.pem").writeAsString(result['data']['private']);
    _publicKey = RSAKeyParser().parse(result['data']['public'] as String);
    _privateKey = RSAKeyParser().parse(result['data']['private'] as String);
  }

  static connect(String ip, int port) {
    Socket.connect(ip, port).then((socket) async {
      _server = socket;
      Map message = {};
      _connectId = _getMessageId();
      await _generateRsaKey();
      message['type'] = "connect";
      message['id'] = _connectId;
      message['public key'] = await File('./Key/publicKey.pem').readAsString();
      String jsonMessage = json.encode(message);
      _server?.write(jsonMessage);
      _server?.listen((data) async {
        _messageDeal(utf8.decode(data));
      }, onError: (error) {
        _messageError(error.toString());
      }, onDone: () {
        _disconnect();
      });
    });
  }

  static _messageDeal(String data) {
    try {
      var result = json.decode(data);
      var encrypter =
          Encrypter(RSA(publicKey: _privateKey, privateKey: _privateKey));
      if (result['type'] == 'connect' && result['id'] == _connectId) {
        _AesKey = encrypter.decrypt(result['AES key']);
      } else {
        var type = result['type'];

        // <-----------------------消息处理开始----------------------->
        // 主动接收
        if (type == 'message') {
          rowMessage.add({
            'type': 'message',
            'id': result['id'],
            'name': result['name'],
            'text': Encrypter(AES(Key.fromUtf8(_AesKey!.split(':')[0])))
                .decrypt(result['text'],
                    iv: IV.fromUtf8(_AesKey!.split(':')[1])),
            'head color': result['head color'],
            'bubble color': result['bubble color']
          });
        } else if (type == 'image') {
          rowMessage.add({
            'type': 'image',
            'id': result['id'],
            'name': result['name'],
            'data': base64.decode(
                Encrypter(AES(Key.fromUtf8(_AesKey!.split(':')[0]))).decrypt(
                    result['data'],
                    iv: IV.fromUtf8(_AesKey!.split(':')[1]))),
            'head color': result['head color'],
            'bubble color': result['bubble color'],
            'size':result['size']
          });
        } else if (type == 'disposable image') {
          rowMessage.add({
            'type': 'disposable image',
            'id': result['id'],
            'name': result['name'],
            'data': base64.decode(
                Encrypter(AES(Key.fromUtf8(_AesKey!.split(':')[0]))).decrypt(
                    result['data'],
                    iv: IV.fromUtf8(_AesKey!.split(':')[1]))),
            'head color': result['head color'],
            'bubble color': result['bubble color'],
            'size':result['size']
          });
        } else if (type == 'audio') {
          rowMessage.add({
            'type': 'audio',
            'id': result['id'],
            'name': result['name'],
            'data': base64.decode(
                Encrypter(AES(Key.fromUtf8(_AesKey!.split(':')[0]))).decrypt(
                    result['data'],
                    iv: IV.fromUtf8(_AesKey!.split(':')[1]))),
            'head color': result['head color'],
            'bubble color': result['bubble color']
          });
        }
        //消息回调
        else if(type == 'callback'){
          for(var any in rowMessage){
            if(any['id'] == result['id']){
              if(result['status'] == 'success'){
                any['isSuccess'] = true;
              }
            }
          }
        }
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
    print('断开连接');
  }

  static String _getMessageId() {
    _count++;
    return "${DateTime.now().millisecondsSinceEpoch}$_count";
  }

  // <-----------------------消息发送区域开始----------------------->

  static String sendMessage(String text) {
    if (_server == null || _AesKey == null) {
      return "disconnect";
    }
    try {
      Map message = {};
      message['type'] = "message";
      message['id'] = _getMessageId();
      message['name'] = name;
      message['head color'] = headColor;
      message['bubble color'] = bubbleColor;
      message['text'] = Encrypter(AES(Key.fromUtf8(_AesKey!.split(':')[0])))
          .encrypt(text, iv: IV.fromUtf8(_AesKey!.split(':')[1]));
      String jsonMessage = jsonEncode(message);
      _server?.write(utf8.encode(jsonMessage));
      return "success";
    } catch (e) {
      return "error:${e.toString()}";
    }
  }

  static String sendImage(List<int> image) {
    if (_server == null || _AesKey == null) {
      return "disconnect";
    }
    try {
      Map message = {};
      message['type'] = "image";
      message['id'] = _getMessageId();
      message['name'] = name;
      message['head color'] = headColor;
      message['bubble color'] = bubbleColor;
      message['data'] = Encrypter(AES(Key.fromUtf8(_AesKey!.split(':')[0])))
          .encrypt(base64Encode(image),
              iv: IV.fromUtf8(_AesKey!.split(':')[1]));
      String jsonMessage = jsonEncode(message);
      _server?.write(utf8.encode(jsonMessage));
      return "success";
    } catch (e) {
      return "error:${e.toString()}";
    }
  }

  static String sendAudio(List<int> audio) {
    if (_server == null || _AesKey == null) {
      return "disconnect";
    }
    try {
      Map message = {};
      message['type'] = "audio";
      message['id'] = _getMessageId();
      message['name'] = name;
      message['head color'] = headColor;
      message['bubble color'] = bubbleColor;
      message['data'] = Encrypter(AES(Key.fromUtf8(_AesKey!.split(':')[0])))
          .encrypt(base64Encode(audio),
              iv: IV.fromUtf8(_AesKey!.split(':')[1]));
      String jsonMessage = jsonEncode(message);
      _server?.write(utf8.encode(jsonMessage));
      return "success";
    } catch (e) {
      return "error:${e.toString()}";
    }
  }

  static String sendDisposableImage(List<int> image) {
    if (_server == null || _AesKey == null) {
      return "disconnect";
    }
    try {
      Map message = {};
      message['type'] = "disposable image";
      message['id'] = _getMessageId();
      message['name'] = name;
      message['head color'] = headColor;
      message['bubble color'] = bubbleColor;
      message['data'] = Encrypter(AES(Key.fromUtf8(_AesKey!.split(':')[0])))
          .encrypt(base64Encode(image),
              iv: IV.fromUtf8(_AesKey!.split(':')[1]));
      String jsonMessage = jsonEncode(message);
      _server?.write(utf8.encode(jsonMessage));
      return "success";
    } catch (e) {
      return "error:${e.toString()}";
    }
  }
  // <-----------------------消息发送区域结束----------------------->
}
