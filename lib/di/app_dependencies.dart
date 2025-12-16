import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/di/feature_dependencies/marketing/content/content.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/utils.dependencies.dart';

import 'feature_dependencies/calendar/calendar.dependencies.dart';
import 'feature_dependencies/login/login.dependencies.dart';
import 'feature_dependencies/masters/company_master_dependencies.dart';
import 'feature_dependencies/masters/department_master.dependencies.dart';
import 'feature_dependencies/masters/designation_master.dependencies.dart';
import 'feature_dependencies/masters/employee_master.dependencies.dart';
import 'feature_dependencies/project_management/approved_bank/approved_bank.dependencies.dart';

final GetIt serviceLocator = GetIt.instance;

void initDependencies() {
  // UTILS
  registerUtilsDependencies(serviceLocator);
  // LOGIN
  registerLoginDependencies(serviceLocator);
  // COMPANY MASTER DEPENDENCIES
  registerCompanyMasterDependencies(serviceLocator);
  // DEPARTMENT MASTER DEPENDENCIES
  registerDepartmentMasterDependencies(serviceLocator);
  // DESIGNATION MASTER DEPENDENCIES
  registerDesignationMasterDependencies(serviceLocator);
  // EMPLOYEE MASTER DEPENDENCIES
  registerEmployeeMasterDependencies(serviceLocator);
  // CONTENT DEPENDENCIES
  registerContentDependencies(serviceLocator);
  // APPROVED BANK DEPENDENCIES
  registerApprovedBankDependencies(serviceLocator);
  // CALENDAR DEPENDENCIES
  registerCalendarDependencies(serviceLocator);
}
