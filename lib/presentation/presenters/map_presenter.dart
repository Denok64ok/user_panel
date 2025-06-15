import '../../data/models/parking_zone.dart';
import '../../data/models/zone_type.dart';
import '../../data/models/parking_zone_detailed.dart';
import '../../domain/usecases/get_zones_usecase.dart';
import '../../domain/usecases/get_zone_types_usecase.dart';
import '../../domain/usecases/get_zone_detailed_usecase.dart';
import '../../data/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

abstract class MapView {
  void showZones(List<ParkingZone> zones, List<ZoneType> zoneTypes);
  void showError(String message);
  void showZoneDetails(ParkingZoneDetailed zone);
  void updateSelectedZone(ParkingZoneDetailed zone);
  void showLoading(String message);
  void hideLoading();
  void centerOnLocation(LatLng location, double zoom);
}

class MapPresenter {
  final GetZonesUseCase _getZonesUseCase;
  final GetZoneTypesUseCase _getZoneTypesUseCase;
  final GetZoneDetailedUseCase _getZoneDetailedUseCase;
  final ApiService _apiService;
  final MapView _view;
  List<ParkingZone> _zones = [];

  MapPresenter(
    this._getZonesUseCase,
    this._getZoneTypesUseCase,
    this._getZoneDetailedUseCase,
    this._apiService,
    this._view,
  );

  Future<void> loadZones() async {
    try {
      final zones = await _getZonesUseCase.execute();
      final zoneTypes = await _getZoneTypesUseCase.execute();
      _zones = zones;
      _view.showZones(zones, zoneTypes);
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          _view.showError(
            'Не удалось подключиться к серверу. Проверьте подключение к интернету',
          );
        } else if (e.response?.statusCode == 404) {
          _view.showError('Парковочные зоны не найдены');
        } else {
          _view.showError(
            'Не удалось загрузить парковочные зоны. Попробуйте позже',
          );
        }
      } else {
        _view.showError(
          'Не удалось загрузить парковочные зоны. Попробуйте позже',
        );
      }
    }
  }

  Future<void> findNearestZone(LatLng userLocation) async {
    if (_zones.isEmpty) {
      _view.showError('Нет доступных парковочных зон');
      return;
    }

    try {
      _view.showLoading('Поиск ближайшей парковки...');

      // Находим центр каждой зоны и вычисляем расстояние до пользователя
      ParkingZone? nearestZone;
      double minDistance = double.infinity;
      LatLng? nearestZoneCenter;

      for (var zone in _zones) {
        // Вычисляем центр зоны
        double centerLat = 0;
        double centerLng = 0;
        for (var point in zone.location) {
          centerLat += point[0];
          centerLng += point[1];
        }
        centerLat /= zone.location.length;
        centerLng /= zone.location.length;

        final zoneCenter = LatLng(centerLat, centerLng);

        // Вычисляем расстояние
        final distance = const Distance().as(
          LengthUnit.Meter,
          userLocation,
          zoneCenter,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestZone = zone;
          nearestZoneCenter = zoneCenter;
        }
      }

      if (nearestZone != null && nearestZoneCenter != null) {
        final zoneDetails = await _getZoneDetailedUseCase.execute(
          nearestZone.id,
        );
        _view.hideLoading();
        _view.showZoneDetails(zoneDetails);

        // Центрируем карту на найденной зоне
        _view.centerOnLocation(
          nearestZoneCenter,
          17.0,
        ); // Увеличенный масштаб для лучшего обзора зоны
      } else {
        _view.hideLoading();
        _view.showError('Не удалось найти ближайшую парковку');
      }
    } catch (e) {
      _view.hideLoading();
      _view.showError('Не удалось найти ближайшую парковку');
    }
  }

  // Метод для первоначальной загрузки информации о зоне
  Future<void> loadZoneDetails(int zoneId) async {
    try {
      final zone = await _getZoneDetailedUseCase.execute(zoneId);
      _view.updateSelectedZone(zone);
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          _view.showError(
            'Не удалось подключиться к серверу. Проверьте подключение к интернету',
          );
        } else if (e.response?.statusCode == 404) {
          _view.showError('Парковочная зона не найдена');
        } else {
          _view.showError(
            'Не удалось загрузить информацию о зоне. Попробуйте позже',
          );
        }
      } else {
        _view.showError(
          'Не удалось загрузить информацию о зоне. Попробуйте позже',
        );
      }
    }
  }

  // Метод для обновления информации о зоне через обработку изображения
  Future<void> refreshZoneDetails(int zoneId) async {
    try {
      _view.showLoading('Обновление информации...');
      await _apiService.processZoneImage(zoneId);
      final zone = await _getZoneDetailedUseCase.execute(zoneId);
      _view.hideLoading();
      _view.updateSelectedZone(zone);
    } catch (e) {
      _view.hideLoading();
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          _view.showError(
            'Не удалось подключиться к серверу. Проверьте подключение к интернету',
          );
        } else if (e.response?.statusCode == 404) {
          _view.showError('Парковочная зона не найдена');
        } else if (e.response?.statusCode == 503) {
          _view.showError(
            'Сервис обработки изображений временно недоступен. Попробуйте позже',
          );
        } else {
          _view.showError(
            'Не удалось обновить информацию о зоне. Попробуйте позже',
          );
        }
      } else {
        _view.showError(
          'Не удалось обновить информацию о зоне. Попробуйте позже',
        );
      }
    }
  }
}
