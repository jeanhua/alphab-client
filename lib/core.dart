import 'dart:io';

void main(){
  print("你好");
}

var server;
void Connet(String IP,int port){
  server = Socket.connect(IP, port);
}