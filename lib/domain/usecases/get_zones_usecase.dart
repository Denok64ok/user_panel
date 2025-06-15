import '../../data/models/parking_zone.dart';
import '../../data/repositories/auth_repository.dart';

class GetZonesUseCase {
  final AuthRepository repository;

  GetZonesUseCase(this.repository);

  Future<List<ParkingZone>> execute() async {
    return await repository.getAllZones();
  }
}
