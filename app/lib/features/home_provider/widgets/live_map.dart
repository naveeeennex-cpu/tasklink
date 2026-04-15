import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/api_client.dart';
import '../../../core/models/route_info.dart';
import '../../../core/polyline_codec.dart';
import '../../../design/tokens/colors.dart';

/// Renders a live Google Map with the shortest route between [origin]
/// and [destination], fetched through the backend proxy (never touches
/// the Maps API key client-side).
///
/// Falls back to a neutral background when the backend is unreachable
/// or no route is available so the UI never goes blank.
class LiveRouteMap extends StatefulWidget {
  const LiveRouteMap({
    super.key,
    required this.origin,
    required this.destination,
    this.onRouteReady,
  });

  final LatLng origin;
  final LatLng destination;
  final ValueChanged<RouteInfo>? onRouteReady;

  @override
  State<LiveRouteMap> createState() => _LiveRouteMapState();
}

class _LiveRouteMapState extends State<LiveRouteMap> {
  GoogleMapController? _controller;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    try {
      final route = await ApiClient.instance.routeShortest(
        oLat: widget.origin.latitude,
        oLng: widget.origin.longitude,
        dLat: widget.destination.latitude,
        dLng: widget.destination.longitude,
      );
      if (!mounted) return;

      final points = decodePolyline(route.polyline);
      setState(() {
        _loading = false;
        _error = null;
        _polylines
          ..clear()
          ..add(
            Polyline(
              polylineId: const PolylineId('shortest'),
              points: points,
              color: LokalColors.primaryContainer,
              width: 6,
              jointType: JointType.round,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
            ),
          );
        _markers
          ..clear()
          ..add(Marker(
            markerId: const MarkerId('origin'),
            position: widget.origin,
            infoWindow: InfoWindow(title: route.start.address),
          ))
          ..add(Marker(
            markerId: const MarkerId('destination'),
            position: widget.destination,
            infoWindow: InfoWindow(title: route.end.address),
          ));
      });
      widget.onRouteReady?.call(route);
      _fitBounds(points);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _fitBounds(List<LatLng> points) {
    if (_controller == null || points.isEmpty) return;
    final south = points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    final north = points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    final west = points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    final east = points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);
    _controller!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(south, west),
          northeast: LatLng(north, east),
        ),
        64,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.origin,
            zoom: 13,
          ),
          polylines: _polylines,
          markers: _markers,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          liteModeEnabled: false,
          onMapCreated: (c) {
            _controller = c;
          },
        ),
        if (_loading)
          const Positioned(
            top: 12,
            right: 12,
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: LokalColors.primaryContainer,
              ),
            ),
          ),
        if (_error != null)
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Route unavailable — $_error',
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }
}
