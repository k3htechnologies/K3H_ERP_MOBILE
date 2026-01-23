import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_debit_master/data/datasource/leave_credit_debit_master.datasource.dart';

abstract interface class LeaveCreditDebitMasterRepository {}

class LeaveCreditDebitMasterRepositoryImpl extends LeaveCreditDebitMasterRepository{
  final LeaveCreditDebitMasterDatasource leaveCreditDebitMasterDatasource;

  LeaveCreditDebitMasterRepositoryImpl({required this.leaveCreditDebitMasterDatasource});
}