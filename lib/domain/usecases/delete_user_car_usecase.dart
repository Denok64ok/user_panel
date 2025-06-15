import '../../data/repositories/auth_repository.dart';

class DeleteUserCarUseCase {
  final AuthRepository repository;

  DeleteUserCarUseCase(this.repository);

  Future<void> execute(int carId, String token) async {
    return await repository.deleteUserCar(carId, token);
  }
}
