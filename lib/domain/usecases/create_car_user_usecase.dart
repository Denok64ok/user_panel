import 'package:user_panel/data/models/car_user.dart';
import 'package:user_panel/data/repositories/auth_repository.dart';

class CreateCarUserUseCase {
  final AuthRepository repository;

  CreateCarUserUseCase(this.repository);

  Future<CarUser> call(int userId, int carId, String token) async {
    return await repository.createCarUser(userId, carId, token);
  }
}
