import 'dart:io';

import 'package:ping_discover_network/ping_discover_network.dart';
import 'package:wifi/wifi.dart';

enum DeviceType { advertiser, browser }

abstract class AbstractConnection {
  DeviceType deviceType;
  Function onData;

  AbstractConnection(this.deviceType);

  isServer();

  init();

  write(String s);

  close();
}

class ConnectionHandler extends AbstractConnection {
  static final int PORT = 29843;
  ServerSocket serverSocket;
  Socket socket;
  Function onData = (data) => {};

  ConnectionHandler(DeviceType deviceType) : super(deviceType);

  @override
  bool isServer() {
    return deviceType == DeviceType.advertiser;
  }

  @override
  Future init() async {
    switch (this.deviceType) {
      case DeviceType.advertiser:
        Wifi.ip.then((ip) => print(ip));
        serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, PORT);
        print("Socket online");
        return serverSocket.listen(listen);
      case DeviceType.browser:
        return browserIpAndConnect(PORT).then((socket) {
          listen(socket);
        });
    }
  }

  setSocket(Socket s) {
    // close open socket and replace
    print("set Socket");
    socket?.close();
    s.setOption(SocketOption.tcpNoDelay, true);
    socket = s;
  }

  listen(Socket s) {
    setSocket(s);
    print("Socket is listening");
    socket.map((data) => String.fromCharCodes(data).trim()).listen((data) {
      onData(data);
      print(data);
    });
  }

  @override
  write(String s) {
    socket?.write(s);
  }

  Future<Socket> browserIpAndConnect(int port) async {
    final String ip = await Wifi.ip;
    final String subnet = ip.substring(0, ip.lastIndexOf('.'));

    final addr = await NetworkAnalyzer.discover2(subnet, port,
            timeout: Duration(milliseconds: 5000))
        .firstWhere((addr) => addr.exists);
    if (addr != null) {
      print("found devise at: " + addr.ip);
      return Socket.connect(addr.ip, port);
    } else {
      throw Exception("Could not find device");
    }
  }

  @override
  void close() {
    socket?.close();
    serverSocket?.close();
  }
}
