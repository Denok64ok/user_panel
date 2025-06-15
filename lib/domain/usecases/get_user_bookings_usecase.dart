import '../../data/models/booking_detailed.dart';
import '../../data/repositories/auth_repository.dart';

class GetUserBookingsUseCase {
  final AuthRepository repository;

  GetUserBookingsUseCase(this.repository);

  Future<List<BookingDetailed>> execute(int userId, String token) async {
    return await repository.getUserBookings(userId, token);
  }
}
