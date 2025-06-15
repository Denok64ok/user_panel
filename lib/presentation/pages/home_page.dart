import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../widgets/map_controls_widget.dart';
import '../widgets/search_widget.dart';
import '../widgets/header.dart';
import '../presenters/map_presenter.dart';
import '../../data/models/parking_zone.dart';
import '../../data/models/zone_type.dart';
import '../../data/models/parking_zone_detailed.dart';
import '../../data/services/api_service.dart';
import '../../domain/usecases/get_zones_usecase.dart';
import '../../domain/usecases/get_zone_types_usecase.dart';
import '../../domain/usecases/get_zone_detailed_usecase.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> implements MapView {
  final MapController _mapController = MapController();
  late MapPresenter _presenter;
  List<ParkingZone> _zones = [];
  ParkingZoneDetailed? _selectedZone;
  bool _isExpanded = false;
  bool _isLoading = false;
  String _loadingMessage = '';

  @override
  void initState() {
    super.initState();
    _presenter = MapPresenter(
      GetIt.I.get<GetZonesUseCase>(),
      GetIt.I.get<GetZoneTypesUseCase>(),
      GetIt.I.get<GetZoneDetailedUseCase>(),
      GetIt.I.get<ApiService>(),
      this,
    );
    _presenter.loadZones();
  }

  @override
  void centerOnLocation(LatLng location, double zoom) {
    _mapController.move(location, zoom);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void showZones(List<ParkingZone> zones, List<ZoneType> zoneTypes) {
    setState(() {
      _zones = zones;
    });
  }

  @override
  void showError(String message) {
    if (message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connection')) {
      _showError('Проверьте подключение к интернету');
    } else if (message.toLowerCase().contains('not found')) {
      _showError('Парковочная зона не найдена');
    } else if (message.toLowerCase().contains('unauthorized')) {
      _showError('Необходимо авторизоваться');
    } else {
      _showError('Не удалось загрузить информацию о парковках');
    }
  }

  @override
  void showZoneDetails(ParkingZoneDetailed zone) {
    setState(() {
      _selectedZone = zone;
      _isExpanded = false;
    });
  }

  @override
  void updateSelectedZone(ParkingZoneDetailed zone) {
    setState(() {
      _selectedZone = zone;
    });
  }

  @override
  void showLoading(String message) {
    setState(() {
      _isLoading = true;
      _loadingMessage = message;
    });
  }

  @override
  void hideLoading() {
    setState(() {
      _isLoading = false;
      _loadingMessage = '';
    });
  }

  Color _getZoneColor(int zoneTypeId) {
    final colors = {
      1: Colors.blue.withOpacity(0.5), // Обычная зона
      2: Colors.green.withOpacity(0.5), // Льготная зона
      3: Colors.red.withOpacity(0.5), // Специальная зона
    };
    return colors[zoneTypeId] ?? Colors.grey.withOpacity(0.5);
  }

  Widget _buildZoneDetailsWidget() {
    if (_selectedZone == null) return const SizedBox.shrink();

    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _selectedZone!.zoneName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF447BBA),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedZone!.typeName,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        color: const Color(0xFF447BBA),
                      ),
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF447BBA)),
                      onPressed: () {
                        setState(() {
                          _selectedZone = null;
                          _isExpanded = false;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              _buildInfoRow(Icons.location_on_outlined, _selectedZone!.address),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.access_time_outlined,
                '${_selectedZone!.startTime} - ${_selectedZone!.endTime}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.local_parking_outlined,
                'Свободно ${_selectedZone!.freePlaces} из ${_selectedZone!.totalPlaces} мест',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.currency_ruble_outlined,
                '${_selectedZone!.pricePerMinute} руб/мин',
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Обновлено: ${_selectedZone!.formattedUpdateTime}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF447BBA)),
                    onPressed:
                        () => _presenter.refreshZoneDetails(_selectedZone!.id),
                    tooltip: 'Обновить информацию',
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/inspect-zone', extra: _selectedZone);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF447BBA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Осмотреть парковку',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF447BBA)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(55.441004, 65.341118), // Курган
              initialZoom: 13.0,
              minZoom: 8.0,
              maxZoom: 18.0,
              onTap: (tapPosition, point) {
                for (var zone in _zones) {
                  final location =
                      zone.location
                          .map((innerList) => innerList.cast<double>().toList())
                          .toList();
                  if (_isPointInPolygon(point, location)) {
                    _presenter.loadZoneDetails(zone.id);
                    break;
                  }
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.user_panel',
              ),
              PolygonLayer(
                polygons:
                    _zones.map((zone) {
                      return Polygon(
                        points:
                            zone.location
                                .map((coord) => LatLng(coord[0], coord[1]))
                                .toList(),
                        color: _getZoneColor(zone.zoneTypeId),
                        borderColor: Colors.black,
                        borderStrokeWidth: 2.0,
                        isFilled: true,
                      );
                    }).toList(),
              ),
            ],
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Column(
                  children: [
                    SearchWidget(mapController: _mapController),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.center,
                      child: MapControlsWidget(
                        mapController: _mapController,
                        onFindNearestZone: (userLocation) {
                          _presenter.findNearestZone(userLocation);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _buildZoneDetailsWidget(),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          _loadingMessage,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isPointInPolygon(LatLng point, List<List<double>> vertices) {
    int intersectCount = 0;
    for (int i = 0; i < vertices.length; i++) {
      final j = (i + 1) % vertices.length;
      final vertex1 = LatLng(vertices[i][0], vertices[i][1]);
      final vertex2 = LatLng(vertices[j][0], vertices[j][1]);

      if ((vertex1.latitude > point.latitude) !=
              (vertex2.latitude > point.latitude) &&
          point.longitude <
              (vertex2.longitude - vertex1.longitude) *
                      (point.latitude - vertex1.latitude) /
                      (vertex2.latitude - vertex1.latitude) +
                  vertex1.longitude) {
        intersectCount++;
      }
    }
    return intersectCount % 2 == 1;
  }
}
