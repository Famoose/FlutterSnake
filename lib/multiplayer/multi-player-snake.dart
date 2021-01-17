import 'dart:io';
import 'package:wifi/wifi.dart';
import 'package:ping_discover_network/ping_discover_network.dart';
import 'package:flutter/cupertino.dart';
import 'package:psnake/multiplayer/abstract-connection.dart';

class MultiplayerPlayerGamePage extends StatelessWidget {
  final DeviceType deviceType;

  const MultiplayerPlayerGamePage({this.deviceType});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(child: MySocketConnector(deviceType: deviceType));

  }
}

class MySocketConnector extends StatefulWidget {
  final DeviceType deviceType;

  MySocketConnector({this.deviceType});

  @override
  _MySocketConnectorState createState() => _MySocketConnectorState();
}

class _MySocketConnectorState extends State<MySocketConnector> {
  ConnectionHandler connectionHandler;

  @override
  void initState() {
    connectionHandler = new ConnectionHandler(widget.deviceType);
    connectionHandler.init();
    super.initState();
  }

  @override
  void dispose() {
    connectionHandler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: CupertinoButton(
        child: Text("ping"), onPressed: () => connectionHandler.write("ping")));
  }
}

class ConnectionHandler extends AbstractConnection {
  static final int PORT = 29843;
  ServerSocket serverSocket;
  Socket socket;

  ConnectionHandler(DeviceType deviceType) : super(deviceType);

  @override
  init() async{
    switch (this.deviceType) {
      case DeviceType.advertiser:
        Wifi.ip.then((ip) => print(ip));
        ServerSocket.bind(InternetAddress.anyIPv4, PORT).then((s) {
          serverSocket = s;
          print("Socket online");
          serverSocket.listen(listen);
        });
        break;
      case DeviceType.browser:
        browserIpAndConnect(PORT).then((socket) {
          listen(socket);
          write("test from client " + DateTime.now().toString());
          write("hoi bibi " + DateTime.now().toString());
        });
        break;
    }
  }

  setSocket(Socket s) {
    // close open socket and replace
    socket?.close();
    s.setOption(SocketOption.tcpNoDelay, true);
    socket = s;
  }

  @override
  listen(Socket s) {
    setSocket(s);
    print("Socket is listening");
    socket.map((data) => String.fromCharCodes(data).trim()).listen((data) {
      var time = DateTime.now().toString();
      print(time + ": " + data);
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
