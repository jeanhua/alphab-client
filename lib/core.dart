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
  static var rowMessage = [];
  static String headColor = material.Colors.blue.value.toString();
  static String bubbleColor = material.Colors.white.value.toString();
  static String name = "匿名";

  static _generateRsaKey() async {
    final headers = {
      'accept': 'application/json, text/javascript, */*; q=0.01',
      'accept-language': 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
      'cache-control': 'no-cache',
      'content-type': 'application/json;charset=UTF-8',
      'origin': 'https://www.lddgo.net',
      'pragma': 'no-cache',
      'priority': 'u=1, i',
      'referer': 'https://www.lddgo.net/encrypt/rsakey',
      'sec-ch-ua':
          '"Microsoft Edge";v="129", "Not=A?Brand";v="8", "Chromium";v="129"',
      'sec-ch-ua-mobile': '?0',
      'sec-ch-ua-platform': '"Windows"',
      'sec-fetch-dest': 'empty',
      'sec-fetch-mode': 'cors',
      'sec-fetch-site': 'same-site',
      'user-agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36 Edg/129.0.0.0',
    };
    const data =
        '{"algorithm":"RSA","length":"2048","format":"pem","publicKey":"","privateKey":""}';
    final url = Uri.parse(
        'https://openapi.lddgo.net/base/gtool/api/v1/GeneratorRsaKey');
    final res = await http.post(url, headers: headers, body: data);
    final status = res.statusCode;
    if (status != 200) throw Exception('http.post error: statusCode= $status');
    var result = json.decode(res.body);
    var dir = Directory("./Key");
    if (!dir.existsSync()) {
      dir.create();
    }
    await File("./Key/publicKey.pem")
        .writeAsString(result['data']['publicKey']);
    await File("./Key/privateKey.pem")
        .writeAsString(result['data']['privateKey']);
    print((result['data']['privateKey'] as String).replaceRange(0, 31, "-----BEGIN PRIVATE KEY-----"));
    _publicKey = RSAKeyParser().parse(result['data']['publicKey'] as String);
    _privateKey = RSAKeyParser().parse((result['data']['privateKey'] as String).replaceAll(" RSA ", " "));
  }

  static connect(String ip, int port) {
    Socket.connect(ip, port).then((socket) async {
      _server = socket;
      Map message = {};
      _connectId = _getMessageId();
      await _generateRsaKey();
      message['type'] = "connect";
      message['id'] = _connectId;
      message['public key'] =await File('./Key/publicKey.pem').readAsString();
      String jsonMessage = json.encode(message);
      print(jsonMessage);
      _server?.write(utf8.encode(jsonMessage));
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
        if (type == 'message') {
          rowMessage.add({
            'type': 'message',
            'id': result['id'],
            'name': result['name'],
            'text': Encrypter(AES(Key.fromUtf8(_AesKey!.split(':')[0])))
                .decrypt(result['text'],
                    iv: IV.fromUtf8(_AesKey!.split(':')[1])),
            'head color': result['head color'],
            'name color': result['name color']
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
            'name color': result['name color']
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
            'name color': result['name color']
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
            'name color': result['name color']
          });
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
