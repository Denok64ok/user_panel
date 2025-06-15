import '../models/token.dart';
import '../models/user.dart';
import '../models/parking_zone.dart';
import '../models/zone_type.dart';
import '../models/parking_zone_detailed.dart';
import '../models/car_user.dart';
import '../models/booking_detailed.dart';
import '../models/car.dart';
import '../models/car_user_create.dart';
import '../services/api_service.dart';

abstract class AuthRepository {
  Future<User> register(
    String userName,
    String phone,
    String email,
    String password,
  );
  Future<Token> login(String email, String password);
  Future<User> getUserProfile(String token);
  Future<void> logout(String token);
  Future<List<ParkingZone>> getAllZones();
  Future<List<ZoneType>> getZoneTypes();
  Future<ParkingZoneDetailed> getZoneDetailed(int zoneId);
  Future<List<CarUser>> getUserCars(int userId, String token);
  Future<List<BookingDetailed>> getUserBookings(int userId, String token);
  Future<void> deleteUserCar(int carId, String token);
  Future<Car> createCar(String carNumber, String token);
  Future<CarUser> createCarUser(int userId, int carId, String token);
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService;

  AuthRepositoryImpl(this.apiService);

  @override
  Future<User> register(
    String userName,
    String phone,
    String email,
    String password,
  ) async {
    try {
      final userData = {
        'user_name': userName,
        'phone': phone,
        'email': email,
        'password': password,
      };
      print('Register request data: $userData');
      return await apiService.registerUser(userData);
    } catch (e) {
      print('Register error: $e');
      rethrow;
    }
  }

  @override
  Future<Token> login(String email, String password) async {
    try {
      final loginData = {'email': email, 'password': password};
      print('Login request data: $loginData');
      return await apiService.loginUser(loginData);
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  @override
  Future<User> getUserProfile(String token) async {
    try {
      return await apiService.getUserProfile('Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout(String token) async {
    try {
      await apiService.logout('Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ParkingZone>> getAllZones() async {
    try {
      return await apiService.getAllZones();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ZoneType>> getZoneTypes() async {
    try {
      return await apiService.getZoneTypes();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ParkingZoneDetailed> getZoneDetailed(int zoneId) async {
    try {
      return await apiService.getZoneDetailed(zoneId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CarUser>> getUserCars(int userId, String token) async {
    try {
      return await apiService.getUserCars(userId, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BookingDetailed>> getUserBookings(
    int userId,
    String token,
  ) async {
    try {
      return await apiService.getUserBookings(userId, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteUserCar(int carId, String token) async {
    try {
      await apiService.deleteUserCar(carId, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Car> createCar(String carNumber, String token) async {
    try {
      final car = CarCreate(carNumber: carNumber);
      return await apiService.createCar(car, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CarUser> createCarUser(int userId, int carId, String token) async {
    try {
      final carUser = CarUserCreate(userId: userId, carId: carId);
      return await apiService.createCarUser(carUser, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }
}
