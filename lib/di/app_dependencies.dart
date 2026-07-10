import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/di/feature_dependencies/crm/dashboard/crm_dashboard.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/crm/pay_track/pay_track.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/dashboard/dashboard.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/inventory/inventory_report.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/legal/litigation/litigation.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/legal/litigation_dashboard/litigation_dashboard.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/marketing/content/content.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/masters/holiday_mapping_master.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/masters/leave_encashment_master.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/masters/leave_type_master.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/masters/project_master.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/masters/shift_mapping_master.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/masters/shift_master.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/masters/week_off_mapping_master.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/masters/week_off_master.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/material_requisition/finalize_vendor.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/material_requisition/grn.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/material_requisition/invoice.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/material_requisition/material_requisition.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/material_requisition/purchase_order.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/more/inward_outward/inward_outward.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/more/ticket/ticket.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/notification/notification.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/payroll/resignation/resignation.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/profile/profile.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/project_document/approval_category/approval_category.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/project_document/approval_document/approval_document.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/project_document/rera_document/rera_document_category.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/project_document/rera_document_category/rera_document_category.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/redevelopment/dashboard/redevelopment_dashboard.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/register/register.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/sales/booking/booking.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/sales/master/channel_partner_category/channel_partner_category.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/sales/master/classification_parameters/classification_parameters.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/sales/enquiry/enquiry.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/sales/master/other_charges/other_charges.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/sales/master/payment_schedule/payment_schedule.dependency.dart';
import 'package:k3h_erp_app/di/feature_dependencies/sales/master/payment_schedule_scheme/payment_schedule_scheme.dependency.dart';
import 'package:k3h_erp_app/di/feature_dependencies/sales/report/aop_achievement_report.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/sales/report/ibm_obm_report.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/sales/report/performance_report.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/sales/sales_dashboard/sales_dashboard.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/setting_dashboard/setting_dashboard.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/stock_management/stock_management.dependency.dart';
import 'package:k3h_erp_app/di/feature_dependencies/tax_tracker/tax_tracker.dependencies.dart';
import 'package:k3h_erp_app/di/feature_dependencies/utils.dependencies.dart';

import 'feature_dependencies/calendar/calendar.dependencies.dart';
import 'feature_dependencies/channel_partner/channel_partner.dependencies.dart';
import 'feature_dependencies/crm/brokerage/brokerage.dependencies.dart';
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
import 'feature_dependencies/payroll/attendance/attendance.dependencies.dart';
import 'feature_dependencies/payroll/comp_off/comp_off.dependencies.dart';
import 'feature_dependencies/payroll/leave/leave.dependencies.dart';
import 'feature_dependencies/payroll/outdoor/outdoor.dependencies.dart';
import 'feature_dependencies/payroll/payroll_dashboard/payroll_dashboard.dependencies.dart';
import 'feature_dependencies/payroll/payroll_report/payroll_report.dependencies.dart';
import 'feature_dependencies/project_document/document/document.dependencies.dart';
import 'feature_dependencies/project_document/document_category/document_category.dependencies.dart';
import 'feature_dependencies/project_management/approved_bank/approved_bank.dependencies.dart';
import 'feature_dependencies/redevelopment/building/building.dependencies.dart';
import 'feature_dependencies/redevelopment/proposed_offer/proposed_offer.dependencies.dart';
import 'feature_dependencies/redevelopment/proposed_plans/proposed_plans.dependencies.dart';
import 'feature_dependencies/redevelopment/rent/rent.dependencies.dart';
import 'feature_dependencies/redevelopment/tenant/tenant.dependencies.dart';
import 'feature_dependencies/sales/call_tracker/call_tracker.dependencies.dart';
import 'feature_dependencies/sales/report/achievement_report.dependencies.dart';
import 'feature_dependencies/sales/sourcing/sourcing.dependencies.dart';
import 'feature_dependencies/sales/target/target.dependencies.dart';
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
  // BRANCH ASSOCIATION MASTER DEPENDENCIES
  registerBranchAssociationMasterDependencies(serviceLocator);
  // EMPLOYEE MASTER DEPENDENCIES (must be before LOGIN as LoginCubit depends on it)
  registerEmployeeMasterDependencies(serviceLocator);
  // BANK LIST MASTER DEPENDENCIES (must be after EMPLOYEE MASTER as BankListMasterCubit depends on EmployeeMasterRepository)
  registerBankListMasterDependencies(serviceLocator);
  // TERMS AND CONDITIONS MASTER DEPENDENCIES
  registerTermsAndConditionsMasterDependencies(serviceLocator);
  // ASSET MAPPING MASTER DEPENDENCIES
  registerAssetMappingMasterDependencies(serviceLocator);
  // ASSET MASTER DEPENDENCIES
  registerAssetMasterDependencies(serviceLocator);
  // BRANCH MASTER DEPENDENCIES
  registerBranchMasterDependencies(serviceLocator);
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
  // REGISTER
  registerDependencies(serviceLocator);
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
  // INWARD OUTWARD DEPENDENCIES
  registerInwardOutwardependencies(serviceLocator);
  // TICKET DEPENDENCIES
  registerTicketDependencies(serviceLocator);
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
  // LEAVE CREDIT CONFIGURATION MASTER DEPENDENCIES
  registerLeaveCreditConfigurationMasterDependencies(serviceLocator);
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
  registerInventoryReportReportDependencies(serviceLocator);
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
  // ATTENDANCE DEPENDENCIES
  registerAttendanceDependencies(serviceLocator);
  // RESIGNATION DEPENDENCIES
  registerResignationDependencies(serviceLocator);
  // PAYROLL REPORT DEPENDENCIES
  registerPayrollReportDependencies(serviceLocator);
  // LITIGATION DEPENDENCIES
  registerLitigationDependencies(serviceLocator);
  // CALL TRACKER DEPENDENCIES
  registerCallTrackerDependencies(serviceLocator);
  // TARGET DEPENDENCIES
  registerTargetDependencies(serviceLocator);
  // ENQUIRY DEPENDENCIES
  registerEnquiryDependencies(serviceLocator);
  // OTHER CHARGES DEPENDENCIES
  registerOtherChargesDependencies(serviceLocator);
  // CHANNEL PARTNER CATEGORY DEPENDENCIES
  registerChannelPartnerCategoryDependencies(serviceLocator);
  // PAYMENT SCHEDULE DEPENDENCIES (must be before Booking as BookingCubit depends on it)
  registerPaymentScheduleDependencies(serviceLocator);
  // BOOKING DEPENDENCIES
  registerBookingDependencies(serviceLocator);
  // SOURCING DEPENDENCIES
  registerSourcingDependencies(serviceLocator);
  // DASHBOARD DEPENDENCIES
  registerDashboardDependencies(serviceLocator);
  // SALES DASHBOARD
  registerSalesDashboardDependencies(serviceLocator);
  // REDEVELOPMENT DASHBOARD
  registerRedevelopmentDashboardDependencies(serviceLocator);
  // PAYMENT SCHEDULE SCHEME DEPENDENCIES
  registerPaymentScheduleSchemeDependencies(serviceLocator);
  // SETTING DASHBOARD
  registerSettingDashboardDependencies(serviceLocator);
  // LITIGATION DASHBOARD
  registerLitigationDashboardDependencies(serviceLocator);
  // PAYROLL DASHBOARD
  registerPayrollDashboardDependencies(serviceLocator);
  // CLASSIFICATION PARAMETERS DEPENDENCIES
  registerClassificationParameterDependencies(serviceLocator);
  // PERFORMANCE REPORT DEPENDENCIES
  registerPerformanceReportDependencies(serviceLocator);
  // ACHIEVEMENT REPORT DEPENDENCIES
  registerAchievementReportDependencies(serviceLocator);
  //IBM OBM REPORT DEPENDENCIES
  registerIbmObmReportDependencies(serviceLocator);
  //AOP ACHIEVEMENT REPORT DEPENDENCIES
  registerAopAchievementReportDependencies(serviceLocator);
  // PROCUREMENT
  registerMaterialRequisitionFinalizeVendorDependencies(serviceLocator);
  registerMaterialRequisitionInvoiceDependencies(serviceLocator);
  registerMaterialRequisitionDependencies(serviceLocator);

  //CRM
  // CRM PAY TRACK
  registerCRMPayTrackDependencies(serviceLocator);
  registerMaterialRequisitionPurchaseOrderDependencies(serviceLocator);
  registerMaterialRequisitionGRNDependencies(serviceLocator);
  // CRM BROKERAGE
  registerBrokerageDependencies(serviceLocator);
  // STOCK MANAGEMENT
  registerStockManagementrDependencies(serviceLocator);
  // CRM DASHBOARD
  registerCrmDashboardDependencies(serviceLocator);
  registerTaxTrackerDependencies(serviceLocator);
}
