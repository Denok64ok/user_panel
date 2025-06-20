import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/api_service.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/register_usecase.dart';
import '../domain/usecases/get_user_profile_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/get_zones_usecase.dart';
import '../domain/usecases/get_zone_types_usecase.dart';
import '../domain/usecases/get_zone_detailed_usecase.dart';
import '../domain/usecases/get_user_cars_usecase.dart';
import '../domain/usecases/get_user_bookings_usecase.dart';
import '../domain/usecases/delete_user_car_usecase.dart';
import '../domain/usecases/create_car_usecase.dart';
import '../domain/usecases/create_car_user_usecase.dart';
import '../domain/usecases/finish_booking_usecase.dart';
import '../presentation/presenters/map_presenter.dart';
import '../presentation/presenters/inspect_zone_presenter.dart';

final getIt = GetIt.instance;

void setupDi() {
  // Core
  getIt.registerSingleton<Dio>(
    Dio()
      ..interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => print(obj.toString()),
        ),
      ),
  );
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());

  // Services
  getIt.registerSingleton<ApiService>(ApiService(getIt<Dio>()));

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(getIt<ApiService>()),
  );

  // Use cases
  getIt.registerSingleton<LoginUseCase>(LoginUseCase(getIt<AuthRepository>()));
  getIt.registerSingleton<RegisterUseCase>(
    RegisterUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetUserProfileUseCase>(
    GetUserProfileUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetUserCarsUseCase>(
    GetUserCarsUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<DeleteUserCarUseCase>(
    DeleteUserCarUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetUserBookingsUseCase>(
    GetUserBookingsUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<LogoutUseCase>(
    LogoutUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetZonesUseCase>(
    GetZonesUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetZoneTypesUseCase>(
    GetZoneTypesUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetZoneDetailedUseCase>(
    GetZoneDetailedUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(() => CreateCarUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateCarUserUseCase(getIt()));
  getIt.registerLazySingleton(() => FinishBookingUseCase(getIt<ApiService>()));

  // Presenters
  getIt.registerFactory<MapPresenter>(
    () => MapPresenter(
      getIt<GetZonesUseCase>(),
      getIt<GetZoneTypesUseCase>(),
      getIt<GetZoneDetailedUseCase>(),
      getIt<ApiService>(),
      getIt<MapView>(),
    ),
  );

  getIt.registerFactoryParam<InspectZonePresenter, InspectZoneView, void>(
    (view, _) => InspectZonePresenter(getIt<ApiService>(), view),
  );
}
