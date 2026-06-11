import 'package:k3h_erp_app/features/tax_tracker/data/datasource/tax_tracker.datasource.dart';

abstract interface class TaxTrackerRepository {}

class TaxTrackerRepositoryImpl implements TaxTrackerRepository {
  final TaxTrackerDatasource taxTrackerDatasource;
  TaxTrackerRepositoryImpl({required this.taxTrackerDatasource});
}
