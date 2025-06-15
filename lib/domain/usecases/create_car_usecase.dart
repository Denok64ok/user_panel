import 'package:user_panel/data/models/car.dart';
import 'package:user_panel/data/repositories/auth_repository.dart';

class CreateCarUseCase {
  final AuthRepository repository;

  CreateCarUseCase(this.repository);

  Future<Car> call(String carNumber, String token) async {
    return await repository.createCar(carNumber, token);
  }
}
