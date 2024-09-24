import 'package:encrypt/encrypt.dart';


void main() {
  final plainText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
  final key = 'mDlEijvzMYIKI+BI';
  final iv = "GfeMB5lssqRm6klF";
  print(AesDecrypt("jgjRRwtgksgmF+HsS6RD46gynRljPXJDkGJUJeA8Lvm3Q6yTWhafJA4eufzG31rh", key, iv));
}

String AesEncrypt(String content,String _key,String _iv){
  final key = Key.fromUtf8(_key);
  final iv = IV.fromUtf8(_iv);
  final encrypter = Encrypter(AES(key,mode: AESMode.cbc));
  final encrypted = encrypter.encrypt(content, iv: iv);
  return encrypted.base64;
}

String AesDecrypt(String content,String _key,String _iv){
  final key = Key.fromUtf8(_key);
  final iv = IV.fromUtf8(_iv);
  final encrypter = Encrypter(AES(key,mode: AESMode.cbc));
  final decrypted = encrypter.decrypt(Encrypted.from64(content), iv: iv);
  return decrypted;
}