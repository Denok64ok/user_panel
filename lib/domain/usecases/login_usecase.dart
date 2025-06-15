import '../../data/models/token.dart';
import '../../data/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Token> execute(String email, String password) async {
    return await repository.login(email, password);
  }
}
