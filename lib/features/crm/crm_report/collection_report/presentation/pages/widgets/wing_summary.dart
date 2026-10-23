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
    List<CollectionReportProjectWiseModel> rows,
    num Function(CollectionReportProjectWiseModel) field,
  ) => rows.fold<double>(0, (sum, item) => sum + field(item).toDouble());

  final totalRows = wingRows.where((i) => i.type == 'Total').toList();

  final residentialRows =
      wingRows.where((i) => i.unitType == 'Residential').toList();
  final commercialRows =
      wingRows.where((i) => i.unitType == 'Commercial').toList();

  final residentialTotal =
      residentialRows.where((i) => i.type == 'Total').firstOrNull;
  final commercialTotal =
      commercialRows.where((i) => i.type == 'Total').firstOrNull;

  return WingSummary(
    buildingNumber: wingRows.first.buildingNumber.toString(),
    totalUnits: sumField(totalRows, (i) => i.totalUnit),
    residentialUnits: residentialTotal?.totalUnit ?? 0,
    commercialUnits: commercialTotal?.totalUnit ?? 0,
    agreementAmount: sumField(totalRows, (i) => i.totalAgreementValue),
    receivedAmount: sumField(totalRows, (i) => i.receivedAmount),
    balanceAmount: sumField(totalRows, (i) => i.balanceAmount),
  );
}
