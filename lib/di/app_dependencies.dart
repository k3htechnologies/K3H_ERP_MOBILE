import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/di/feature_dependencies/marketing/content/content.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/masters/holiday_mapping_master.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/masters/leave_encashment_master.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/masters/leave_type_master.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/masters/project_master.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/masters/shift_mapping_master.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/masters/shift_master.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/masters/week_off_mapping_master.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/masters/week_off_master.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/notification/notification.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/profile/profile.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/project_document/approval_category/approval_category.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/project_document/approval_document/approval_document.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/project_document/rera_document/rera_document_category.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/project_document/rera_document_category/rera_document_category.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/utils.dependencies.dart';

import 'feature_dependencies/calendar/calendar.dependencies.dart';
import 'feature_dependencies/channel_partner/channel_partner.dependencies.dart';
import 'feature_dependencies/inventory/inventory.dependencies.dart';
import 'feature_dependencies/login/login.dependencies.dart';
import 'feature_dependencies/masters/asset_master.dependencies.dart';
import 'feature_dependencies/masters/asset_mapping_master.dependencies.dart';
import 'feature_dependencies/masters/bank_list_master.dependencies.dart';
import 'feature_dependencies/masters/branch_association_master.dependencies.dart';
import 'feature_dependencies/masters/branch_master.dependencies.dart';
import 'feature_dependencies/masters/company_master_dependencies.dart';
import 'feature_dependencies/masters/deduction_master.dependencies.dart';
import 'feature_dependencies/masters/department_master.dependencies.dart';
import 'feature_dependencies/masters/designation_master.dependencies.dart';
import 'feature_dependencies/masters/earning_master.dependencies.dart';
import 'feature_dependencies/masters/employee_master.dependencies.dart';
import 'feature_dependencies/masters/holiday_master.dependencies.dart';
import 'feature_dependencies/masters/leave_credit_debit_master.dependencies.dart';
import 'feature_dependencies/masters/material_master.dependencies.dart';
import 'feature_dependencies/masters/sub_material_master.dependencies.dart';
import 'feature_dependencies/masters/terms_and_condition.dependencies.dart';
import 'feature_dependencies/masters/uom_master.dependencies.dart';
import 'feature_dependencies/parking/parking.dependencies.dart';
import 'feature_dependencies/payroll/comp_off/comp_off.dependencies.dart';
import 'feature_dependencies/payroll/leave/leave.dependencies.dart';
import 'feature_dependencies/payroll/outdoor/outdoor.dependencies.dart';
import 'feature_dependencies/project_document/document/document.dependencies.dart';
import 'feature_dependencies/project_document/document_category/document_category.dependencies.dart';
import 'feature_dependencies/project_management/approved_bank/approved_bank.dependencies.dart';
import 'feature_dependencies/redevelopment/building/building.dependencies.dart';
import 'feature_dependencies/redevelopment/proposed_offer/proposed_offer.dependencies.dart';
import 'feature_dependencies/redevelopment/proposed_plans/proposed_plans.dependencies.dart';
import 'feature_dependencies/redevelopment/rent/rent.dependencies.dart';
import 'feature_dependencies/redevelopment/tenant/tenant.dependencies.dart';
import 'feature_dependencies/vendor_management/vendor_management.dependencies.dart';

final GetIt serviceLocator = GetIt.instance;

void initDependencies() {
  // UTILS
  registerUtilsDependencies(serviceLocator);
  // NOTIFICATION DEPENDENCIES
  registerNotificationDependencies(serviceLocator);
  // COMPANY MASTER DEPENDENCIES (must be before EMPLOYEE MASTER as EmployeeMasterCubit depends on it)
  registerCompanyMasterDependencies(serviceLocator);
  // DEPARTMENT MASTER DEPENDENCIES (must be before EMPLOYEE MASTER as EmployeeMasterCubit depends on it)
  registerDepartmentMasterDependencies(serviceLocator);
  // DESIGNATION MASTER DEPENDENCIES (must be before EMPLOYEE MASTER as EmployeeMasterCubit depends on it)
  registerDesignationMasterDependencies(serviceLocator);
  // PROJECT MASTER DEPENDENCIES (must be before PROFILE as ProfileCubit depends on it, and before calendar as calendar depends on it)
  registerProjectMasterDependencies(serviceLocator);
  // EMPLOYEE MASTER DEPENDENCIES (must be before LOGIN as LoginCubit depends on it)
  registerEmployeeMasterDependencies(serviceLocator);
  // BANK LIST MASTER DEPENDENCIES (must be after EMPLOYEE MASTER as BankListMasterCubit depends on EmployeeMasterRepository)
  registerBankListMasterDependencies(serviceLocator);
  // TERMS AND CONDITIONS MASTER DEPENDENCIES
  registerTermsAndConditionsMasterDependencies(serviceLocator);
  // ASSET MASTER DEPENDENCIES
  registerAssetMasterDependencies(serviceLocator);
  // ASSET MAPPING MASTER DEPENDENCIES
  registerAssetMappingMasterDependencies(serviceLocator);
  // BRANCH MASTER DEPENDENCIES
  registerBranchMasterDependencies(serviceLocator);
  // BRANCH ASSOCIATION MASTER DEPENDENCIES
  registerBranchAssociationMasterDependencies(serviceLocator);
  // DEDUCTION MASTER DEPENDENCIES
  registerDeductionMasterDependencies(serviceLocator);
  // EARNING MASTER DEPENDENCIES
  registerEarningMasterDependencies(serviceLocator);
  // HOLIDAY MASTER DEPENDENCIES
  registerHolidayMasterDependencies(serviceLocator);
  // HOLIDAY MAPPING MASTER DEPENDENCIES
  registerHolidayMappingMasterDependencies(serviceLocator);
  // MATERIAL MASTER DEPENDENCIES
  registerMaterialMasterDependencies(serviceLocator);
  // SUB MATERIAL MASTER DEPENDENCIES
  registerSubMaterialMasterDependencies(serviceLocator);
  // UOM MASTER DEPENDENCIES
  registerUOMMasterDependencies(serviceLocator);
  // LOGIN
  registerLoginDependencies(serviceLocator);
  // PROFILE DEPENDENCIES
  registerProfileDependencies(serviceLocator);
  // VENDOR MANAGEMENT DEPENDENCIES
  registerVendorManagementDependencies(serviceLocator);
  // CONTENT DEPENDENCIES
  registerContentDependencies(serviceLocator);
  // APPROVED BANK DEPENDENCIES
  registerApprovedBankDependencies(serviceLocator);
  // CALENDAR DEPENDENCIES
  registerCalendarDependencies(serviceLocator);
  // REDEVELOPMENT DEPENDENCIES
  registerRedevelopmentDependencies(serviceLocator);
  // LEAVE ENCASHMENT MASTER DEPENDENCIES
  registerLeaveEncashmentDependencies(serviceLocator);
  // LEAVE TYPE MASTER DEPENDENCIES
  registerLeaveTypeMasterDependencies(serviceLocator);
  //SHIFT MASTER DEPENDENCIES
  registerShiftMasterDependencies(serviceLocator);
  //SHIFT MAPPING MASTER DEPENDENCIES
  registerShiftMappingMasterDependencies(serviceLocator);
  //WEEK OFF MASTER DEPENDENCIES
  registerWeekOffMasterDependencies(serviceLocator);
  //WEEK OFF MAPPING MASTER DEPENDENCIES
  registerWeekOffMappingMasterDependencies(serviceLocator);
  // LEAVE CREDIT DEBIT MASTER DEPENDENCIES
  registerLeaveCreditDebitMasterDependencies(serviceLocator);
  // TENANT DEPENDENCIES
  registerTenantMasterDependencies(serviceLocator);
  // PROPOSED PLAN DEPENDENCIES
  registerProposedPlansDependencies(serviceLocator);
  // PROPOSED OFFER DEPENDENCIES
  registerProposedOfferDependencies(serviceLocator);
  // RENT DEPENDENCIES
  registerRentDependencies(serviceLocator);
  // INVENTORY DEPENDENCIES
  registerInventoryDependencies(serviceLocator);
  // PARKING DEPENDENCIES
  registerParkingDependencies(serviceLocator);
  // CHANNEL PARTNER DEPENDENCIES
  registerChannelPartnerDependencies(serviceLocator);
  // DOCUMENT CATEGORY DEPENDENCIES
  registerDocumentCategoryDependencies(serviceLocator);
  // DOCUMENT DEPENDENCIES
  registerDocumentDependencies(serviceLocator);
  // RERA DOCUMENT CATEGORY DEPENDENCIES
  registerRERADocumentCategoryDependencies(serviceLocator);
  //RERA DOCUMENT
  registerRERADocumentDependencies(serviceLocator);
  //APPROVAL DOCUMENT CATEGORY DEPENDENCIES
  registerApprovalCategoryDependencies(serviceLocator);
  //APPROVAL DOCUMENT DEPENDENCIES
  registerApprovalDocumentDependencies(serviceLocator);
  // OUTDOOR DEPENDENCIES
  registerOutdoorDependencies(serviceLocator);
  // LEAVE DEPENDENCIES
  registerLeaveDependencies(serviceLocator);
  // COMP OFF DEPENDENCIES
  registerCompOffDependencies(serviceLocator);
}
