import '../../data/models/camera_snapshot.dart';
import '../../data/models/parking_place.dart';
import '../../data/models/car_user.dart';
import '../../data/models/booking_create.dart';
import '../../data/models/booking_detailed.dart';
import '../../data/services/api_service.dart';
import 'package:dio/dio.dart';

abstract class InspectZoneView {
  void showLoading();
  void hideLoading();
  void showError(String message);
  void updateSnapshot(CameraSnapshot snapshot);
  void showPlaces(List<ParkingPlace> places);
  void showUserCars(List<CarUser> cars);
  void onBookingCreated(BookingDetailed booking);
}

class InspectZonePresenter {
  final ApiService _apiService;
  final InspectZoneView _view;

  InspectZonePresenter(this._apiService, this._view);

  Future<void> loadMarkedZoneImage(int zoneId) async {
    try {
      _view.showLoading();
      final snapshot = await _apiService.getMarkedZoneImage(zoneId);
      _view.hideLoading();
      _view.updateSnapshot(snapshot);
    } catch (e) {
      _view.hideLoading();
      if (e is DioException &&
          (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.connectionError)) {
        _view.showError(
          'Не удалось подключиться к серверу. Проверьте подключение к интернету',
        );
      } else {
        _view.showError(
          'Не удалось загрузить данные с камер. Попробуйте позже',
        );
      }
    }
  }

  Future<void> loadPlaces(int zoneId) async {
    try {
      _view.showLoading();
      final places = await _apiService.getPlacesByZone(zoneId);
      _view.hideLoading();
      _view.showPlaces(places);
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
        } else {
          _view.showError(
            'Не удалось загрузить места парковки. Попробуйте позже',
          );
        }
      } else {
        _view.showError(
          'Не удалось загрузить места парковки. Попробуйте позже',
        );
      }
    }
  }

  Future<void> loadUserCars(int userId, String token) async {
    try {
      _view.showLoading();
      final cars = await _apiService.getUserCars(userId, token);
      _view.hideLoading();
      _view.showUserCars(cars);
    } catch (e) {
      _view.hideLoading();
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          _view.showError(
            'Не удалось подключиться к серверу. Проверьте подключение к интернету',
          );
        } else if (e.response?.statusCode == 401) {
          _view.showError('Необходима повторная авторизация');
        } else {
          _view.showError(
            'Не удалось загрузить список автомобилей. Попробуйте позже',
          );
        }
      } else {
        _view.showError(
          'Не удалось загрузить список автомобилей. Попробуйте позже',
        );
      }
    }
  }

  Future<void> createBooking(BookingCreate booking, String token) async {
    try {
      _view.showLoading();
      final createdBooking = await _apiService.createBooking(booking, token);
      _view.hideLoading();
      _view.onBookingCreated(createdBooking);
    } catch (e) {
      _view.hideLoading();
      if (e is DioException) {
        final responseData = e.response?.data?.toString() ?? '';
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          _view.showError(
            'Не удалось подключиться к серверу. Проверьте подключение к интернету',
          );
        } else if (e.response?.statusCode == 401) {
          _view.showError('Необходима повторная авторизация');
        } else if (responseData.contains('already booked')) {
          _view.showError('Это место уже забронировано');
        } else if (responseData.contains('invalid time')) {
          _view.showError('Выбрано некорректное время бронирования');
        } else if (responseData.contains('place not available')) {
          _view.showError('Выбранное место недоступно для бронирования');
        } else {
          _view.showError('Не удалось создать бронирование. Попробуйте позже');
        }
      } else {
        _view.showError('Не удалось создать бронирование. Попробуйте позже');
      }
    }
  }
}
