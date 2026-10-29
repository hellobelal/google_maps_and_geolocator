import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'about_page.dart';
import 'app_logo.dart';
import 'main.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  static const _interval = 10; // seconds

  final MapController _map = MapController();
  bool _mapReady = false;
  Timer? _fetchTimer;
  Timer? _countdownTimer;
  AnimationController? _moveCtrl;

  final List<LatLng> _path = [];
  LatLng? _current;
  double _distanceMeters = 0;
  int _updates = 0;
  int _secondsLeft = _interval;
  String? _error;
  bool _locating = true;
  bool _topo = false;
  bool _showInfo = false; // marker info window

  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _countdownTimer?.cancel();
    _moveCtrl?.dispose();
    _pulse.dispose();
    _map.dispose();
    super.dispose();
  }

  // ---------- permission ----------
  Future<bool> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() {
        _error = 'Location service off. Please turn on GPS.';
        _locating = false;
      });
      return false;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      setState(() {
        _error = perm == LocationPermission.deniedForever
            ? 'Permission permanently denied. Enable it from app settings.'
            : 'Location permission denied.';
        _locating = false;
      });
      return false;
    }
    return true;
  }

  // ---------- tracking ----------
  Future<void> _startTracking() async {
    setState(() {
      _error = null;
      _locating = true;
    });
    if (!await _ensurePermission()) return;

    await _fetchLocation(); // first fix immediately

    _fetchTimer?.cancel();
    _fetchTimer = Timer.periodic(
        const Duration(seconds: _interval), (_) => _fetchLocation());

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(
          () => _secondsLeft = _secondsLeft <= 1 ? _interval : _secondsLeft - 1);
    });
  }

  Future<void> _fetchLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final p = LatLng(pos.latitude, pos.longitude);
      final isFirst = _current == null;

      if (_path.isNotEmpty) {
        final last = _path.last;
        _distanceMeters += Geolocator.distanceBetween(
            last.latitude, last.longitude, p.latitude, p.longitude);
      }

      if (!mounted) return;
      setState(() {
        _current = p;
        _path.add(p); // polyline: previous -> current
        _updates++;
        _secondsLeft = _interval;
        _locating = false;
        _error = null;
      });

      if (_mapReady) _animateTo(p, zoom: isFirst ? 17 : null);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not get location: $e';
        _locating = false;
      });
    }
  }

  // ---------- smooth camera animation ----------
  void _animateTo(LatLng dest, {double? zoom}) {
    final cam = _map.camera;
    final latT = Tween<double>(
        begin: cam.center.latitude, end: dest.latitude);
    final lngT = Tween<double>(
        begin: cam.center.longitude, end: dest.longitude);
    final zoomT = Tween<double>(begin: cam.zoom, end: zoom ?? cam.zoom);

    _moveCtrl?.dispose();
    final ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _moveCtrl = ctrl;
    final curve = CurvedAnimation(parent: ctrl, curve: Curves.easeInOutCubic);
    ctrl.addListener(() {
      _map.move(LatLng(latT.evaluate(curve), lngT.evaluate(curve)),
          zoomT.evaluate(curve));
    });
    ctrl.forward();
  }

  void _recenter() {
    if (_current != null) _animateTo(_current!, zoom: 17);
  }

  void _clearPath() {
    setState(() {
      _path
        ..clear()
        ..addAll(_current != null ? [_current!] : []);
      _distanceMeters = 0;
    });
  }

  String get _distanceText => _distanceMeters >= 1000
      ? '${(_distanceMeters / 1000).toStringAsFixed(2)} km'
      : '${_distanceMeters.toStringAsFixed(0)} m';

  // ---------- marker with info window ----------
  Marker _buildMarker() {
    final p = _current!;
    return Marker(
      point: p,
      width: 60,
      height: 60,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _showInfo = !_showInfo),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // pulsing ring
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Container(
                width: 28 + 24 * _pulse.value,
                height: 28 + 24 * _pulse.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary
                      .withOpacity(0.25 * (1 - _pulse.value)),
                ),
              ),
            ),
            // blue dot
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(color: Colors.black38, blurRadius: 6)
                ],
              ),
            ),
            // info window
            if (_showInfo)
              Positioned(
                bottom: 40,
                left: -90,
                width: 240,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 10)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('My current location',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.dark)),
                          const SizedBox(height: 4),
                          Text(
                            'Lat: ${p.latitude.toStringAsFixed(6)}\n'
                            'Lng: ${p.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down,
                        size: 28, color: Colors.white),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: const LatLng(23.685, 90.356),
              initialZoom: 5,
              onMapReady: () {
                _mapReady = true;
                if (_current != null) _animateTo(_current!, zoom: 17);
              },
              onTap: (_, __) {
                if (_showInfo) setState(() => _showInfo = false);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _topo
                    ? 'https://tile.opentopomap.org/{z}/{x}/{y}.png'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.geo_tracker',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: List.of(_path),
                    strokeWidth: 6,
                    color: AppColors.primary,
                    borderStrokeWidth: 2,
                    borderColor: Colors.white,
                    strokeCap: StrokeCap.round,
                    strokeJoin: StrokeJoin.round,
                  ),
                ],
              ),
              MarkerLayer(
                  markers: _current == null ? [] : [_buildMarker()]),
            ],
          ),

          // attribution (required by OpenStreetMap)
          Positioned(
            left: 8,
            bottom: 2,
            child: SafeArea(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.white70,
                child: const Text('© OpenStreetMap contributors',
                    style: TextStyle(fontSize: 10)),
              ),
            ),
          ),

          // top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    const AppLogo(size: 38),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('GeoTracker',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.dark)),
                    ),
                    IconButton(
                      tooltip: 'About',
                      icon: const Icon(Icons.info_outline_rounded,
                          color: AppColors.primary),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AboutPage()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // side buttons
          Positioned(
            right: 14,
            bottom: 200,
            child: Column(
              children: [
                _MapButton(
                    icon: Icons.my_location_rounded,
                    tooltip: 'My location',
                    onTap: _recenter),
                const SizedBox(height: 10),
                _MapButton(
                  icon: Icons.layers_rounded,
                  tooltip: 'Map style',
                  onTap: () => setState(() => _topo = !_topo),
                ),
                const SizedBox(height: 10),
                _MapButton(
                    icon: Icons.delete_sweep_rounded,
                    tooltip: 'Clear path',
                    onTap: _clearPath),
              ],
            ),
          ),

          // bottom info card
          Positioned(
            left: 12,
            right: 12,
            bottom: 16,
            child: SafeArea(child: _buildInfoCard()),
          ),

          if (_locating && _error == null)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text('Finding your location...'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(colors: [AppColors.dark, AppColors.deep]),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: _error != null
          ? Row(
              children: [
                const Icon(Icons.location_off_rounded,
                    color: Colors.orangeAccent),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.white))),
                TextButton(
                    onPressed: _startTracking, child: const Text('Retry')),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    FadeTransition(
                      opacity: Tween(begin: 0.3, end: 1.0).animate(_pulse),
                      child: const Icon(Icons.circle,
                          size: 12, color: AppColors.accent),
                    ),
                    const SizedBox(width: 8),
                    const Text('LIVE TRACKING',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            fontSize: 12)),
                    const Spacer(),
                    Text('Next update in ${_secondsLeft}s',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 1 - (_secondsLeft / _interval),
                    minHeight: 5,
                    backgroundColor: Colors.white12,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _Stat(
                        label: 'LATITUDE',
                        value:
                            _current?.latitude.toStringAsFixed(5) ?? '--'),
                    _Stat(
                        label: 'LONGITUDE',
                        value:
                            _current?.longitude.toStringAsFixed(5) ?? '--'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Stat(label: 'DISTANCE', value: _distanceText),
                    _Stat(label: 'UPDATES', value: '$_updates'),
                  ],
                ),
              ],
            ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 10, letterSpacing: 1)),
          const SizedBox(height: 2),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(value,
                key: ValueKey(value),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _MapButton(
      {required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Tooltip(
              message: tooltip,
              child: Icon(icon, color: AppColors.primary)),
        ),
      ),
    );
  }
}
