import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/token.dart';
import '../models/user.dart';
import '../models/parking_zone.dart';
import '../models/zone_type.dart';
import '../models/parking_zone_detailed.dart';
import '../models/camera_snapshot.dart';
import '../models/car_user.dart';
import '../models/booking_detailed.dart';
import '../models/parking_place.dart';
import '../models/booking_create.dart';
import '../models/car.dart';
import '../models/car_user_create.dart';
import '../models/booking_finish_response.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: 'http://10.0.2.2:8000/')
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST('/auth/register/user')
  Future<User> registerUser(@Body() Map<String, dynamic> userData);

  @POST('/auth/token/user')
  Future<Token> loginUser(@Body() Map<String, dynamic> loginData);

  @GET('/auth/user/me')
  Future<User> getUserProfile(@Header('Authorization') String token);

  @POST('/auth/logout')
  Future<void> logout(@Header('Authorization') String token);

  @GET('/zones/')
  Future<List<ParkingZone>> getAllZones();

  @GET('/zone-types/')
  Future<List<ZoneType>> getZoneTypes();

  @GET('/zones/{zone_id}/detailed')
  Future<ParkingZoneDetailed> getZoneDetailed(@Path('zone_id') int zoneId);

  @POST('/zones/{zone_id}/process-image')
  Future<void> processZoneImage(@Path('zone_id') int zoneId);

  @GET('/camera-parking-place/zone/{zone_id}/marked-image')
  Future<CameraSnapshot> getMarkedZoneImage(@Path('zone_id') int zoneId);

  @GET('/car-user/user/{user_id}/detailed')
  Future<List<CarUser>> getUserCars(
    @Path('user_id') int userId,
    @Header('Authorization') String token,
  );

  @GET('/booking/user/{user_id}/detailed')
  Future<List<BookingDetailed>> getUserBookings(
    @Path('user_id') int userId,
    @Header('Authorization') String token,
  );

  @GET('/places/zone/{zone_id}')
  Future<List<ParkingPlace>> getPlacesByZone(@Path('zone_id') int zoneId);

  @POST('/booking/')
  Future<BookingDetailed> createBooking(
    @Body() BookingCreate booking,
    @Header('Authorization') String token,
  );

  @POST('/booking/no-end-time')
  Future<BookingDetailed> createBookingWithoutEnd(
    @Body() Map<String, dynamic> booking,
    @Header('Authorization') String token,
  );

  @POST('/booking/{bookingId}/finish')
  Future<BookingFinishResponse> finishBooking(
    @Path('bookingId') int bookingId,
    @Header('Authorization') String token,
  );

  @DELETE('/car-user/{id}')
  Future<void> deleteUserCar(
    @Path('id') int id,
    @Header('Authorization') String token,
  );

  @POST('/car/')
  Future<Car> createCar(
    @Body() CarCreate car,
    @Header('Authorization') String token,
  );

  @POST('/car-user/')
  Future<CarUser> createCarUser(
    @Body() CarUserCreate carUser,
    @Header('Authorization') String token,
  );
}
