import '../../data/models/zone_type.dart';
import '../../data/repositories/auth_repository.dart';

class GetZoneTypesUseCase {
  final AuthRepository repository;

  GetZoneTypesUseCase(this.repository);

  Future<List<ZoneType>> execute() async {
    return await repository.getZoneTypes();
  }
}
