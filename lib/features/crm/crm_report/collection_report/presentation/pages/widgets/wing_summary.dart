import 'package:k3h_erp_app/features/crm/crm_report/collection_report/data/model/collection_report_project_wise.model.dart';

class WingSummary {
  final String buildingNumber;
  final num totalUnits;
  final num residentialUnits;
  final num commercialUnits;
  final double agreementAmount;
  final double receivedAmount;
  final double balanceAmount;

  WingSummary({
    required this.buildingNumber,
    required this.totalUnits,
    required this.residentialUnits,
    required this.commercialUnits,
    required this.agreementAmount,
    required this.receivedAmount,
    required this.balanceAmount,
  });
}

WingSummary buildWingSummary(List<CollectionReportProjectWiseModel> wingRows) {
  double sumField(
    Iterable<CollectionReportProjectWiseModel> rows,
    num Function(CollectionReportProjectWiseModel) field,
  ) => rows.fold<double>(0, (sum, item) => sum + field(item).toDouble());

  final totalRows = wingRows.where((i) => i.type == 'Total').toList();

  final residentialUnits = sumField(
    totalRows.where((i) => i.unitType == 'Residential'),
    (i) => i.bookingCount,
  );
  final commercialUnits = sumField(
    totalRows.where((i) => i.unitType == 'Commercial'),
    (i) => i.bookingCount,
  );

  return WingSummary(
    buildingNumber: wingRows.first.buildingNumber.toString(),
    totalUnits: residentialUnits + commercialUnits,
    residentialUnits: residentialUnits,
    commercialUnits: commercialUnits,
    agreementAmount: sumField(totalRows, (i) => i.totalAgreementValue),
    receivedAmount: sumField(totalRows, (i) => i.receivedAmount),
    balanceAmount: sumField(totalRows, (i) => i.balanceAmount),
  );
}
