// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/payroll/attendance/data/model/attendance.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';

class MapScreen extends StatefulWidget {
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  final String polyline;
  final double distance;
  final AttendanceModel? attendanceDataModel;
  const MapScreen({
    super.key,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    required this.polyline,
    required this.distance,
    this.attendanceDataModel,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<LatLng> routePoints = [];

  GoogleMapController? mapController;

  final ValueNotifier<num> liveDistance = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    loadRouteFromApi();
  }

  void loadRouteFromApi() {
    final isSameLocation =
        widget.startLatitude == widget.endLatitude &&
        widget.startLongitude == widget.endLongitude;

    if (widget.polyline.isNotEmpty) {
      routePoints = decodePolyline(widget.polyline);
      liveDistance.value = widget.distance;
    } else if (!isSameLocation) {
      routePoints = [
        LatLng(widget.startLatitude, widget.startLongitude),
        LatLng(widget.endLatitude, widget.endLongitude),
      ];
      liveDistance.value = _calculateDistance(routePoints);
    } else {
      routePoints = [LatLng(widget.startLatitude, widget.startLongitude)];
      liveDistance.value = 0.0;
    }

    setState(() {});
  }

  void _fitMapToRoute() {
    if (routePoints.isEmpty || mapController == null) return;

    double minLat = routePoints.first.latitude;
    double maxLat = routePoints.first.latitude;
    double minLng = routePoints.first.longitude;
    double maxLng = routePoints.first.longitude;

    for (final point in routePoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
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
    return _douglasPeucker(points, 8);
  }

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

    log(trip.toString());
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

  void _showAddressBottomSheet({
    required String title,
    required String address,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(address),
            ],
          ),
        );
      },
    );
  }

  Future<String> _getAddressFromLatLng(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isEmpty) return "Address not found";

      final place = placemarks.first;

      return "${place.name}, ${place.street}, ${place.locality}, "
          "${place.administrativeArea}, ${place.postalCode}, ${place.country}";
    } catch (e) {
      return "Unable to fetch address";
    }
  }

  @override
  Widget build(BuildContext context) {
    final startPoint =
        routePoints.isNotEmpty
            ? routePoints.first
            : LatLng(widget.startLatitude, widget.startLongitude);
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBarWithBackButton(
          screenTitle: "Location Tracker",
          authorization: AuthorizationModel(),
        ),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: startPoint,
                zoom: 11.5,
              ),
              zoomControlsEnabled: false,
              onMapCreated: (c) {
                mapController = c;
                Future.delayed(const Duration(milliseconds: 300), () {
                  _fitMapToRoute();
                });
              },
              onTap: (LatLng latLng) async {
                final address = await _getAddressFromLatLng(latLng);
                _showAddressBottomSheet(
                  title: "Selected Location",
                  address: address,
                );
              },
              polylines: {
                if (routePoints.isNotEmpty)
                  Polyline(
                    polylineId: const PolylineId("route"),
                    points: routePoints,
                    width: 5,
                    color: AppColor.primary,
                  ),
              },
              markers: {
                Marker(
                  markerId: const MarkerId("start"),
                  position: LatLng(widget.startLatitude, widget.startLongitude),
                  infoWindow: InfoWindow(
                    title: "Punch In",
                    snippet: widget.attendanceDataModel!.punchInAddress,
                  ),
                ),
                Marker(
                  markerId: const MarkerId("end"),
                  position: LatLng(widget.endLatitude, widget.endLongitude),
                  infoWindow: InfoWindow(
                    title: "Punch Out",
                    snippet: widget.attendanceDataModel!.punchOutAddress,
                  ),
                ),
              },
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
            ),
            Positioned(
              bottom: 160,
              right: 16,
              child: Column(
                children: [
                  _zoomButton(
                    icon: Icons.add,
                    onTap: () async {
                      final zoom = await mapController?.getZoomLevel() ?? 11;
                      mapController?.animateCamera(
                        CameraUpdate.zoomTo(zoom + 1),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  _zoomButton(
                    icon: Icons.remove,
                    onTap: () async {
                      final zoom = await mapController?.getZoomLevel() ?? 11;
                      mapController?.animateCamera(
                        CameraUpdate.zoomTo(zoom - 1),
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ValueListenableBuilder<num>(
                  valueListenable: liveDistance,
                  builder: (context, distance, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow(
                          title: "Distance Travelled",
                          value: "${distance.toStringAsFixed(2)} Km",
                        ),
                        const SizedBox(height: 8),
                        _infoRow(
                          title: "Name",
                          value: widget.attendanceDataModel?.fullName ?? "-",
                        ),
                        const SizedBox(height: 8),
                        _infoRow(
                          title: "Date",
                          value:
                              widget.attendanceDataModel?.attendanceDate != null
                                  ? formatDateTimeAsDDMMMYYYY(
                                    widget.attendanceDataModel!.attendanceDate,
                                  )
                                  : "-",
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _zoomButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.black87, size: 22),
        ),
      ),
    );
  }

  Widget _infoRow({required String title, required String value}) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            title,
            style: AppTextStyle.ts14M(
              color: AppColor.black.withValues(alpha: 0.50),
            ),
          ),
        ),
        Text(
          " : ",
          style: AppTextStyle.ts14M(
            color: AppColor.black.withValues(alpha: 0.50),
          ),
        ),
        Expanded(
          child: Text(value, style: AppTextStyle.ts14M(color: AppColor.black)),
        ),
      ],
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
