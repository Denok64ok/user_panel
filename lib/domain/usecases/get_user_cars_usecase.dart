import '../../data/models/car_user.dart';
import '../../data/repositories/auth_repository.dart';

class GetUserCarsUseCase {
  final AuthRepository repository;

  GetUserCarsUseCase(this.repository);

  Future<List<CarUser>> execute(int userId, String token) async {
    return await repository.getUserCars(userId, token);
  }
}
