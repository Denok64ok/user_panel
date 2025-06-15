import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';

class GetUserProfileUseCase {
  final AuthRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<User> execute(String token) async {
    return await repository.getUserProfile(token);
  }
}
