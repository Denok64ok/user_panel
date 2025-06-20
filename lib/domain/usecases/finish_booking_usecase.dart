import 'package:user_panel/data/services/api_service.dart';
import 'package:user_panel/data/models/booking_detailed.dart';

class FinishBookingUseCase {
  final ApiService _apiService;

  FinishBookingUseCase(this._apiService);

  Future<BookingDetailed> execute(int bookingId, String token) async {
    return await _apiService.finishBooking(bookingId, 'Bearer $token');
  }
}
