import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User> execute(
    String userName,
    String phone,
    String email,
    String password,
  ) async {
    return await repository.register(userName, phone, email, password);
  }
}
