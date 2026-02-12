import 'package:k3h_erp_app/features/sales/other_charges/data/datasource/other_charges.datasource.dart';

abstract interface class OtherChargesRepository {}

class OtherChargesRepositoryImpl extends OtherChargesRepository {
  final OtherChargesDatasource otherChargesDatasource;

  OtherChargesRepositoryImpl({required this.otherChargesDatasource});
}
