import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';

class CommunicateCoordinates extends StatefulWidget {
  const CommunicateCoordinates({super.key});

  @override
  State<CommunicateCoordinates> createState() => _CommunicateCoordinatesState();
}

class _CommunicateCoordinatesState extends State<CommunicateCoordinates> {
  Position? _currentLocation;

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
                    child: Text(
                        "Send Location-> Latitude: ${_currentLocation?.latitude}"))
              ],
            ))));
  }

  // void lauchURI() {
  //   try {
  //     launchUrl(
  //       Uri.parse(
  //           'https://communicate?latitude=${_currentLocation?.latitude}&longitude=${_currentLocation?.longitude}, from other App'),
  //       mode: LaunchMode.externalNonBrowserApplication,
  //     );
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

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
    return position;
  }
}
