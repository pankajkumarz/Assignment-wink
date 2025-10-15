import 'package:equatable/equatable.dart';

import '../../entities/alert.dart';
import '../../entities/geo_location.dart';
import '../../repositories/alert_repository.dart';
import '../usecase.dart';

class WatchAlertsForLocation extends StreamUseCase<List<Alert>, WatchAlertsForLocationParams> {
  const WatchAlertsForLocation(this._repository);

  final AlertRepository _repository;

  @override
  Stream<List<Alert>> call(WatchAlertsForLocationParams params) {
    return _repository.watchAlertsForLocation(location: params.location);
  }
}

class WatchAlertsForLocationParams extends Equatable {
  const WatchAlertsForLocationParams({required this.location});

  final GeoLocation location;

  @override
  List<Object> get props => [location];
}