import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  final String polyline;
  final double distance;
  const MapScreen({
    super.key,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    required this.polyline,
    required this.distance,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<LatLng> routePoints = [];
  StreamSubscription<Position>? positionStream;

  GoogleMapController? mapController;
  bool cameraMoved = false;
  LatLng? lastSavedPoint;
  LatLng? initialCameraPoint;

  @override
  void initState() {
    super.initState();
    initialize();
    loadRouteFromApi();
  }

  void loadRouteFromApi() {
    if (widget.polyline.isNotEmpty) {
      routePoints = decodePolyline(widget.polyline);
    } else {
      // fallback if polyline empty
      routePoints = [
        LatLng(widget.startLatitude, widget.startLongitude),
        LatLng(widget.endLatitude, widget.endLongitude),
      ];
    }

    initialCameraPoint = LatLng(widget.startLatitude, widget.startLongitude);

    setState(() {});
  }

  Future<void> setInitialCamera() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    initialCameraPoint = LatLng(pos.latitude, pos.longitude);
    setState(() {});
  }

  void startTrip() {
    routePoints.clear();
    lastSavedPoint = null;
    startTracking();
  }

  void endTrip() {
    positionStream?.cancel();

    if (routePoints.isEmpty) return;

    final start = routePoints.first;
    final end = routePoints.last;
    final distance = _calculateDistance(routePoints);
    final polyline = encodeRoute(routePoints);

    Navigator.pop(context, {
      "startLatitude": start.latitude,
      "startLongitude": start.longitude,
      "endLatitude": end.latitude,
      "endLongitude": end.longitude,
      "distance": distance,
      "polyline": polyline,
    });
  }

  Future<void> initialize() async {
    loadTodayRoute();

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    // Step 1: get current location for camera
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    initialCameraPoint = LatLng(pos.latitude, pos.longitude);

    setState(() {});

    // Step 2: start tracking after camera is ready
    startTracking();
  }

  // 🔹 Load saved route from DB
  void loadTodayRoute() {
    setState(() {});
  }

  Future<void> setInitialLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    initialCameraPoint = LatLng(pos.latitude, pos.longitude);

    setState(() {});
  }

  // 🔹 Start GPS tracking
  void startTracking() {
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        timeLimit: Duration(hours: 9),
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      ),
    ).listen((Position pos) async {
      if (pos.speed < 1) return;

      final current = LatLng(pos.latitude, pos.longitude);

      if (lastSavedPoint != null) {
        double distance = Geolocator.distanceBetween(
          lastSavedPoint!.latitude,
          lastSavedPoint!.longitude,
          current.latitude,
          current.longitude,
        );

        if (distance < 15) return;
      }

      lastSavedPoint = current;

      routePoints.add(current);

      setState(() {});
    });
  }

  double _perpendicularDistance(
    LatLng point,
    LatLng lineStart,
    LatLng lineEnd,
  ) {
    double area =
        (lineStart.latitude * lineEnd.longitude +
                lineEnd.latitude * point.longitude +
                point.latitude * lineStart.longitude -
                lineEnd.latitude * lineStart.longitude -
                point.latitude * lineEnd.longitude -
                lineStart.latitude * point.longitude)
            .abs();

    double bottom = Geolocator.distanceBetween(
      lineStart.latitude,
      lineStart.longitude,
      lineEnd.latitude,
      lineEnd.longitude,
    );

    return (area * 2) / bottom;
  }

  List<LatLng> _douglasPeucker(List<LatLng> points, double epsilon) {
    if (points.length < 3) return points;

    double dmax = 0;
    int index = 0;

    for (int i = 1; i < points.length - 1; i++) {
      double d = _perpendicularDistance(points[i], points.first, points.last);
      if (d > dmax) {
        index = i;
        dmax = d;
      }
    }

    if (dmax > epsilon) {
      List<LatLng> rec1 = _douglasPeucker(
        points.sublist(0, index + 1),
        epsilon,
      );
      List<LatLng> rec2 = _douglasPeucker(
        points.sublist(index, points.length),
        epsilon,
      );

      return [...rec1.sublist(0, rec1.length - 1), ...rec2];
    } else {
      return [points.first, points.last];
    }
  }

  List<LatLng> smoothRoute(List<LatLng> points) {
    return _douglasPeucker(points, 8); // 8–12 meters is sweet spot
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  // 🔹 Distance calculation
  double _calculateDistance(List<LatLng> points) {
    double total = 0;

    for (int i = 0; i < points.length - 1; i++) {
      total += Geolocator.distanceBetween(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }

    return total / 1000; // KM
  }

  String encodeRoute(List<LatLng> points) {
    return PolylineEncoder.encode(points);
  }

  void prepareTripData() {
    if (routePoints.isEmpty) return;

    String encoded = encodeRoute(routePoints);

    Map<String, dynamic> trip = {
      "userId": "123",
      "date": DateTime.now().toIso8601String(),
      "punchIn": routePoints.first,
      "punchOut": routePoints.last,
      "totalDistance": _calculateDistance(routePoints),
      "polyline": encoded,
    };

    print(trip); // send this to API
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  void punchOut() {
    String encoded = encodeRoute(routePoints);

    print("---- TRIP SUMMARY ----");
    print("Start: ${routePoints.first}");
    print("End: ${routePoints.last}");
    print("Distance: ${_calculateDistance(routePoints)} KM");
    print("Encoded Polyline: $encoded");
  }

  @override
  Widget build(BuildContext context) {
    final startPoint = LatLng(widget.startLatitude, widget.startLongitude);
    return Scaffold(
      appBar: AppBar(title: const Text("My Day Route")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              endTrip();
              Navigator.pop(context);
            },
            child: const Text("Punch Out"),
          ),
          Expanded(
            child:
                startPoint == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: startPoint,
                        zoom: 11.5,
                      ),
                      onMapCreated: (c) => mapController = c,
                      polylines: {
                        if (routePoints.isNotEmpty)
                          Polyline(
                            polylineId: const PolylineId("route"),
                            points: routePoints,
                            width: 5,
                            color: Colors.blue,
                          ),
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId("start"),
                          position: LatLng(
                            widget.startLatitude,
                            widget.startLongitude,
                          ),
                          infoWindow: const InfoWindow(title: "Punch In"),
                        ),
                        Marker(
                          markerId: const MarkerId("end"),
                          position: LatLng(
                            widget.endLatitude,
                            widget.endLongitude,
                          ),
                          infoWindow: const InfoWindow(title: "Punch Out"),
                        ),
                      },
                      myLocationEnabled: true,
                    ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Distance Today: ${_calculateDistance(routePoints).toStringAsFixed(2)} KM",
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class PolylineEncoder {
  static String encode(List<LatLng> points) {
    StringBuffer result = StringBuffer();

    int prevLat = 0;
    int prevLng = 0;

    for (final point in points) {
      int lat = (point.latitude * 1e5).round();
      int lng = (point.longitude * 1e5).round();

      result.write(_encodeValue(lat - prevLat));
      result.write(_encodeValue(lng - prevLng));

      prevLat = lat;
      prevLng = lng;
    }

    return result.toString();
  }

  static String _encodeValue(int value) {
    value = value < 0 ? ~(value << 1) : (value << 1);
    StringBuffer encoded = StringBuffer();

    while (value >= 0x20) {
      encoded.writeCharCode((0x20 | (value & 0x1f)) + 63);
      value >>= 5;
    }

    encoded.writeCharCode(value + 63);
    return encoded.toString();
  }
}
