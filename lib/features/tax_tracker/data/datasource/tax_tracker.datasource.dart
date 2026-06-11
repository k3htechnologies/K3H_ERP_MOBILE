import 'package:k3h_erp_app/service/base_client.dart';

abstract interface class TaxTrackerDatasource {}

class TaxTrackerDatasourceImpl implements TaxTrackerDatasource {
  final baseClient = BaseClient();
}
