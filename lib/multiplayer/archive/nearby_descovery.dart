import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:psnake/multiplayer/abstract-connection.dart';
import 'package:psnake/styles/divider.dart';

class DevicesListScreen extends StatefulWidget {
  const DevicesListScreen({this.deviceType});

  final DeviceType deviceType;

  @override
  _DevicesListScreenState createState() => _DevicesListScreenState();
}

class _DevicesListScreenState extends State<DevicesListScreen> {
  List<Device> devices = [];
  List<Device> connectedDevices = [];
  NearbyService nearbyService;
  StreamSubscription subscription;
  StreamSubscription receivedDataSubscription;

  bool isInit = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    subscription?.cancel();
    receivedDataSubscription?.cancel();
    nearbyService.stopBrowsingForPeers();
    nearbyService.stopAdvertisingPeer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: getItemCount(),
        itemBuilder: (context, index) {
          final device = widget.deviceType == DeviceType.advertiser
              ? connectedDevices[index]
              : devices[index];
          return Container(
            margin: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: GestureDetector(
                          onTap: () => _onTabItemListener(device),
                          child: Column(
                            children: [
                              Text(device.deviceName),
                              Text(
                                getStateName(device.state),
                                style: TextStyle(
                                    color: getStateColor(device.state)),
                              ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                        )),
                    // Request connect
                    GestureDetector(
                      onTap: () => _onButtonClicked(device),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8.0),
                        padding: EdgeInsets.all(8.0),
                        height: 35,
                        width: 100,
                        color: getButtonColor(device.state),
                        child: Center(
                          child: Text(
                            getButtonStateName(device.state),
                            style: TextStyle(
                                color: CupertinoColors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 8.0,
                ),
                CupertinoDivider()
              ],
            ),
          );
        });
  }

  String getStateName(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return "disconnected";
      case SessionState.connecting:
        return "waiting";
      default:
        return "connected";
    }
  }

  String getButtonStateName(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return "Connect";
      default:
        return "Disconnect";
    }
  }

  Color getStateColor(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return CupertinoColors.black;
      case SessionState.connecting:
        return CupertinoColors.systemGrey;
      default:
        return CupertinoColors.activeGreen;
    }
  }

  Color getButtonColor(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return CupertinoColors.activeGreen;
      default:
        return CupertinoColors.systemRed;
    }
  }

  _onTabItemListener(Device device) {
    if (device.state == SessionState.connected) {
      showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            final myController = TextEditingController();
            return CupertinoAlertDialog(
              title: Text("Send message"),
              content: CupertinoTextField(controller: myController),
              actions: [
                CupertinoButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoButton(
                  child: Text("Send"),
                  onPressed: () {
                    nearbyService.sendMessage(
                        device.deviceId, myController.text);
                    myController.text = '';
                  },
                )
              ],
            );
          });
    }
  }

  int getItemCount() {
    if (widget.deviceType == DeviceType.advertiser) {
      return connectedDevices.length;
    } else {
      return devices.length;
    }
  }

  _onButtonClicked(Device device) {
    switch (device.state) {
      case SessionState.notConnected:
        nearbyService.invitePeer(
          deviceID: device.deviceId,
          deviceName: device.deviceName,
        );
        break;
      case SessionState.connected:
        nearbyService.disconnectPeer(deviceID: device.deviceId);
        break;
      case SessionState.connecting:
        break;
    }
  }

  void init() async {
    nearbyService = NearbyService();
    print("init Connection");
    await nearbyService.init(
        serviceType: 'mp-connection',
        strategy: Strategy.P2P_CLUSTER,
        callback: (isRunning) async {
          print("checkforrunning");
          if (isRunning) {
            print(widget.deviceType);
            if (widget.deviceType == DeviceType.browser) {
              print("browsering");
              await nearbyService.stopBrowsingForPeers();
              await nearbyService.startBrowsingForPeers();
              print("browsering");
            } else {
              print("advertising");
              await nearbyService.stopAdvertisingPeer();
              await nearbyService.startAdvertisingPeer();
              print("advertising");

              await nearbyService.stopBrowsingForPeers();
              await nearbyService.startBrowsingForPeers();
            }
          }
        });
    subscription =
        nearbyService.stateChangedSubscription(callback: (devicesList) {
          devicesList?.forEach((element) {
            print(
                " deviceId: ${element.deviceId} | deviceName: ${element
                    .deviceName} | state: ${element.state}");

            if (Platform.isAndroid) {
              print("Android gugus");
              print(element.state);
              if (element.state == SessionState.connected) {
                nearbyService.stopBrowsingForPeers();
              } else {
                nearbyService.startBrowsingForPeers();
              }
            }
          });

          setState(() {
            devices.clear();
            devices.addAll(devicesList);
            connectedDevices.clear();
            connectedDevices.addAll(devicesList
                .where((d) => d.state == SessionState.connected)
                .toList());
          });
        });

    receivedDataSubscription =
        nearbyService.dataReceivedSubscription(callback: (data) {
          print("dataReceivedSubscription: ${jsonEncode(data)}");
          //Fluttertoast.showToast(msg: jsonEncode(data));
        });
  }
}