import '../../data/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> execute(String token) async {
    await repository.logout(token);
  }
}
