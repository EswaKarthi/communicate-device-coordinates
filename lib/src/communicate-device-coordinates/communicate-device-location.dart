import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:geolocator/geolocator.dart';
import 'dart:async';

class CommunicateCoordinates extends StatefulWidget {
  const CommunicateCoordinates({super.key});

  @override
  State<CommunicateCoordinates> createState() => _CommunicateCoordinatesState();
}

class _CommunicateCoordinatesState extends State<CommunicateCoordinates> {
  Position? _currentLocation;

  late IO.Socket socket;

  Timer? timer;

  @override
  void initState() {
    print("socket connection starting");

    // if we are running app with android emulator, then localhost doesn't work
    // we need to replace with 10.0.2.2
    socket = IO.io(
        "http://10.0.2.2:4000",
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());
    socket.connect();
    socket.onConnect((_) {
      print('Connection established');
    });
    print("connected");
    socket.onDisconnect((_) => print('Connection Disconnection'));
    socket.onConnectError((err) => print(err));
    socket.onError((err) => print(err));
    setUpSocketListener();
    timer = Timer.periodic(
        Duration(seconds: 15), (Timer t) => sendDriverCoordinates());
    timer = Timer.periodic(
        Duration(seconds: 20), (Timer t) => setUpSocketListener());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text("Geolocation"),
              centerTitle: true,
            ),
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Location Coordinates",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 6,
                ),
                SizedBox(
                  height: 30.0,
                ),
                ElevatedButton(
                    onPressed: () async {
                      _currentLocation = await _determinePosition();
                    },
                    child: Text("Send Location"))
              ],
            ))));
  }

  void sendDriverCoordinates() {
    print("Timer started for every 15 seconds");
    var messageJson = {'latitude': 37.4219983, 'longitude': -122.084};
    socket.emit('message', messageJson);
  }

  void setUpSocketListener() {
    print('inside received return emit');
    socket.on('message-receive', (data) {
      print("--------");
      print(data);
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition();
    print("-----------------");
    print(position);
    var messageJson = {
      'latitude': position.latitude,
      'longitude': position.longitude
    };
    socket.emit('message', messageJson);
    //setUpSocketListener();
    return position;
  }
}
