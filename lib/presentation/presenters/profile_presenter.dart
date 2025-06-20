import '../../data/models/user.dart';
import '../../data/models/car_user.dart';
import '../../data/models/booking_detailed.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/get_user_cars_usecase.dart';
import '../../domain/usecases/get_user_bookings_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/delete_user_car_usecase.dart';
import '../../domain/usecases/create_car_usecase.dart';
import '../../domain/usecases/create_car_user_usecase.dart';
import '../../domain/usecases/finish_booking_usecase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

abstract class ProfileView {
  void showLoading();
  void hideLoading();
  void showError(String message);
  void showProfile(User user);
  void showUserCars(List<CarUser> cars);
  void showUserBookings(List<BookingDetailed> bookings);
  void onLogoutSuccess();
}

class ProfilePresenter {
  final GetUserProfileUseCase getUserProfileUseCase;
  final GetUserCarsUseCase getUserCarsUseCase;
  final GetUserBookingsUseCase getUserBookingsUseCase;
  final DeleteUserCarUseCase deleteUserCarUseCase;
  final LogoutUseCase logoutUseCase;
  final CreateCarUseCase createCarUseCase;
  final CreateCarUserUseCase createCarUserUseCase;
  final FinishBookingUseCase finishBookingUseCase;
  final ProfileView view;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ProfilePresenter(
    this.getUserProfileUseCase,
    this.getUserCarsUseCase,
    this.getUserBookingsUseCase,
    this.deleteUserCarUseCase,
    this.logoutUseCase,
    this.createCarUseCase,
    this.createCarUserUseCase,
    this.finishBookingUseCase,
    this.view,
  );

  Future<void> loadProfile(String token) async {
    view.showLoading();
    try {
      final user = await getUserProfileUseCase.execute(token);
      await _secureStorage.write(key: 'user_id', value: user.id.toString());
      view.hideLoading();
      view.showProfile(user);
      loadUserCars(user.id, token);
      loadUserBookings(user.id, token);
    } catch (e) {
      view.hideLoading();
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          view.showError(
            'Не удалось подключиться к серверу. Проверьте подключение к интернету',
          );
        } else if (e.response?.statusCode == 401) {
          view.showError('Необходима повторная авторизация');
        } else {
          view.showError('Не удалось загрузить профиль. Попробуйте позже');
        }
      } else {
        view.showError('Не удалось загрузить профиль. Попробуйте позже');
      }
    }
  }

  Future<void> loadUserCars(int userId, String token) async {
    _lastUserId = userId;
    view.showLoading();
    try {
      final cars = await getUserCarsUseCase.execute(userId, token);
      view.hideLoading();
      view.showUserCars(cars);
    } catch (e) {
      view.hideLoading();
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          view.showError(
            'Не удалось подключиться к серверу. Проверьте подключение к интернету',
          );
        } else if (e.response?.statusCode == 401) {
          view.showError('Необходима повторная авторизация');
        } else {
          view.showError(
            'Не удалось загрузить список автомобилей. Попробуйте позже',
          );
        }
      } else {
        view.showError(
          'Не удалось загрузить список автомобилей. Попробуйте позже',
        );
      }
    }
  }

  Future<void> loadUserBookings(int userId, String token) async {
    view.showLoading();
    try {
      final bookings = await getUserBookingsUseCase.execute(userId, token);
      view.hideLoading();
      view.showUserBookings(bookings);
    } catch (e) {
      view.hideLoading();
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          view.showError(
            'Не удалось подключиться к серверу. Проверьте подключение к интернету',
          );
        } else if (e.response?.statusCode == 401) {
          view.showError('Необходима повторная авторизация');
        } else {
          view.showError(
            'Не удалось загрузить историю бронирований. Попробуйте позже',
          );
        }
      } else {
        view.showError(
          'Не удалось загрузить историю бронирований. Попробуйте позже',
        );
      }
    }
  }

  Future<void> logout(String token) async {
    view.showLoading();
    try {
      await logoutUseCase.execute(token);
      view.hideLoading();
      view.onLogoutSuccess();
    } catch (e) {
      view.hideLoading();
      view.showError('Не удалось выйти из системы. Попробуйте позже');
    }
  }

  Future<void> deleteUserCar(int carId, String token) async {
    view.showLoading();
    try {
      await deleteUserCarUseCase.execute(carId, token);
      view.hideLoading();
      if (_lastUserId != null) {
        await loadUserCars(_lastUserId!, token);
      }
    } catch (e) {
      view.hideLoading();
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          view.showError(
            'Не удалось подключиться к серверу. Проверьте подключение к интернету',
          );
        } else if (e.response?.statusCode == 401) {
          view.showError('Необходима повторная авторизация');
        } else if (e.response?.statusCode == 404) {
          view.showError('Автомобиль не найден');
        } else {
          view.showError('Не удалось удалить автомобиль. Попробуйте позже');
        }
      } else {
        view.showError('Не удалось удалить автомобиль. Попробуйте позже');
      }
    }
  }

  Future<void> createCar(String carNumber) async {
    view.showLoading();
    try {
      final token = await _secureStorage.read(key: 'access_token');
      if (token == null) {
        view.hideLoading();
        view.showError('Необходима повторная авторизация');
        return;
      }

      final car = await createCarUseCase(carNumber, token);

      final userId = await _secureStorage.read(key: 'user_id');
      if (userId == null) {
        view.hideLoading();
        view.showError('Необходима повторная авторизация');
        return;
      }

      await createCarUserUseCase(int.parse(userId), car.id, token);

      if (_lastUserId != null) {
        await loadUserCars(_lastUserId!, token);
      } else {
        await loadUserCars(int.parse(userId), token);
      }

      view.hideLoading();
    } catch (e) {
      view.hideLoading();
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          view.showError(
            'Не удалось подключиться к серверу. Проверьте подключение к интернету',
          );
        } else if (e.response?.statusCode == 401) {
          view.showError('Необходима повторная авторизация');
        } else {
          final responseData = e.response?.data?.toString() ?? '';
          if (responseData.contains('already exists')) {
            view.showError('Автомобиль с таким номером уже существует');
          } else if (responseData.contains('invalid number')) {
            view.showError('Неверный формат номера автомобиля');
          } else {
            view.showError('Не удалось добавить автомобиль. Попробуйте позже');
          }
        }
      } else {
        view.showError('Не удалось добавить автомобиль. Попробуйте позже');
      }
    }
  }

  Future<void> finishBooking(int bookingId, String token) async {
    view.showLoading();
    try {
      await finishBookingUseCase.execute(bookingId, token);
      final userId = await _secureStorage.read(key: 'user_id');
      if (userId != null) {
        await loadUserBookings(int.parse(userId), token);
      }
      view.hideLoading();
    } catch (e) {
      view.hideLoading();
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          view.showError(
            'Не удалось подключиться к серверу. Проверьте подключение к интернету',
          );
        } else if (e.response?.statusCode == 401) {
          view.showError('Необходима повторная авторизация');
        } else if (e.response?.statusCode == 404) {
          view.showError('Бронирование не найдено');
        } else {
          view.showError('Не удалось завершить бронирование. Попробуйте позже');
        }
      } else {
        view.showError('Не удалось завершить бронирование. Попробуйте позже');
      }
    }
  }

  int? _lastUserId;
}
