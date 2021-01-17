import 'dart:io';

enum DeviceType { advertiser, browser }

abstract class AbstractConnection{
  DeviceType deviceType;
  AbstractConnection(this.deviceType);
  init();
  listen(Socket s);
  write(String s);
  close();
}