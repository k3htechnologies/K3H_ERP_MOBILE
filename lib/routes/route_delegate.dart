import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/approval_log_history.model.dart';
import 'package:k3h_erp_app/core/models/bank_details.model.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/core/models/modules_workflow_approval.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/presentation/cubit/main_screen_cubit.dart';
import 'package:k3h_erp_app/core/presentation/pages/main_screen.dart';
import 'package:k3h_erp_app/core/presentation/pages/no_authorised_screen.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/channel_partner/presentation/cubit/channel_partner_cubit.dart';
import 'package:k3h_erp_app/features/channel_partner/presentation/pages/add_channel_partner_screen.dart';
import 'package:k3h_erp_app/features/channel_partner/presentation/pages/channel_partner_dashboard.screen.dart';
import 'package:k3h_erp_app/features/channel_partner/presentation/pages/channel_partner_screen.dart';
import 'package:k3h_erp_app/features/channel_partner/presentation/pages/channel_partner_view_screen.dart';
import 'package:k3h_erp_app/features/channel_partner/presentation/pages/cp_universe.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/model/brokerage.model.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/model/brokerage_invoice.model.dart';
import 'package:k3h_erp_app/features/crm/brokerage/presentation/cubit/brokerage_cubit.dart';
import 'package:k3h_erp_app/features/crm/brokerage/presentation/pages/add_brokerage_invoice_screen.dart';
import 'package:k3h_erp_app/features/crm/brokerage/presentation/pages/add_brokerage_payment.dart';
import 'package:k3h_erp_app/features/crm/brokerage/presentation/pages/brokerage_screen.dart';
import 'package:k3h_erp_app/features/crm/brokerage/presentation/pages/view_brokerage_screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/files/presentation/cubit/files_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/files/presentation/pages/add_files.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover/presentation/pages/add_flat_handover.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover_checklist/presentation/cubit/flat_handover_checklist_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/data/model/loan_details.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/presentation/cubit/loan_details_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/presentation/pages/add_active_bank.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/presentation/pages/add_bank_loan_documents.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track_booking_files.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/pages/pay_track_screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/pages/pay_track_view_screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_ledger_summary.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/cubit/payment_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/pages/add_payment_ledger.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/pages/make_payment.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/pages/view_payment_ledger.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/cubit/request_management_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/add_applicant_details_requests.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/add_flat_specification_remark.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/add_parking_details.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/add_refund.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/snag_checklist/presentation/cubit/snag_checklist_cubit.dart';
import 'package:k3h_erp_app/features/crm/dashboard/presentation/cubit/crm_dashboard_cubit.dart';
import 'package:k3h_erp_app/features/crm/dashboard/presentation/pages/crm_dashboard.screen.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/pages/pending_approvals_screen.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/pages/project_overview_screen.dart';
import 'package:k3h_erp_app/features/inventory/data/model/building.model.dart';
import 'package:k3h_erp_app/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:k3h_erp_app/features/inventory/presentation/pages/add_inventory_specification_screen.dart';
import 'package:k3h_erp_app/features/inventory/presentation/pages/add_unit_specification_screen.dart';
import 'package:k3h_erp_app/features/inventory/presentation/pages/inventory_dashboard.dart';
import 'package:k3h_erp_app/features/inventory/presentation/pages/unit_distribution_status_screen.dart';
import 'package:k3h_erp_app/features/inventory/presentation/pages/unit_specification_view_screen.dart';
import 'package:k3h_erp_app/features/inventory_reports/presentation/cubit/inventory_report_cubit.dart';
import 'package:k3h_erp_app/features/inventory_reports/presentation/pages/inventory_overall_report.dart';
import 'package:k3h_erp_app/features/inventory_reports/presentation/pages/inventory_report_overview.dart';
import 'package:k3h_erp_app/features/legal/dashboard/presentation/cubit/litigation_dashboard_cubit.dart';
import 'package:k3h_erp_app/features/legal/dashboard/presentation/pages/litigation_dashboard.screen.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation_hearing.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/presentation/cubit/litigation_cubit.dart';
import 'package:k3h_erp_app/features/legal/litigation/presentation/pages/add_litigation_hearing_screen.dart';
import 'package:k3h_erp_app/features/legal/litigation/presentation/pages/add_litigation_screen.dart';
import 'package:k3h_erp_app/features/legal/litigation/presentation/pages/litigation_screen.dart';
import 'package:k3h_erp_app/features/legal/litigation/presentation/pages/litigation_view_screen.dart';
import 'package:k3h_erp_app/features/more/ticket/data/model/ticket.model.dart';
import 'package:k3h_erp_app/features/more/ticket/presentation/cubit/ticket_cubit.dart';
import 'package:k3h_erp_app/features/more/ticket/presentation/pages/add_ticket.screen.dart';
import 'package:k3h_erp_app/features/more/ticket/presentation/pages/assign_ticket.screen.dart';
import 'package:k3h_erp_app/features/more/ticket/presentation/pages/ticket.screen.dart';
import 'package:k3h_erp_app/features/more/ticket/presentation/pages/ticket_view.screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor_for_compare.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/data/model/grn.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/presentation/pages/add_grn_material_screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/presentation/pages/add_grn_screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/presentation/pages/grn_summary_screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/presentation/pages/view_grn_screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/presentation/pages/add_invoice.screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/presentation/pages/add_make_payment.screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/presentation/pages/make_payment.screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/presentation/pages/view_payment.screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/pages/copy_material_requisition_screen.dart';
import 'package:k3h_erp_app/features/register/presentation/pages/register_screen.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/pages/module_access_screen.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/model/designation.model.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/pages/add_designation_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/presentation/pages/branch_association_master_view_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/presentation/pages/deduction_master_view_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/presentation/pages/earning_master_view_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/presentation/pages/holiday_mapping_master_view_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/presentation/pages/holiday_master_view_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_configuration_master/data/model/leave_credit_configuration_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_configuration_master/presentation/cubit/leave_credit_configuration_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_configuration_master/presentation/pages/add_leave_credit_configuration_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_configuration_master/presentation/pages/add_leave_balance_type_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_configuration_master/presentation/pages/leave_credit_configuration_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_configuration_master/presentation/pages/leave_credit_configuration_master_view_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/data/model/week_off_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/presentation/pages/asset_master_view_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/presentation/pages/asset_mapping_master_view_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/data/model/branch_association_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/presentation/cubit/branch_association_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/presentation/pages/add_branch_association_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/presentation/pages/branch_association_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/data/model/branch_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/presentation/cubit/branch_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/presentation/pages/add_branch_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/presentation/pages/branch_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/presentation/pages/branch_master_view_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/data/model/deduction_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/presentation/cubit/deduction_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/presentation/pages/add_deduction_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/presentation/pages/deduction_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/data/model/earning_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/presentation/cubit/earning_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/presentation/pages/add_earning_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/presentation/pages/earning_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/data/model/holiday_mapping_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/presentation/cubit/holiday_mapping_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/presentation/pages/add_holiday_mapping_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/presentation/pages/holiday_mapping_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/data/model/holiday_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/presentation/cubit/holiday_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/presentation/pages/add_holiday_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/presentation/pages/holiday_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/data/model/leave_encashment_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/presentation/cubit/leave_encashment_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/presentation/pages/add_leave_encashment_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/presentation/pages/leave_encashment_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/model/leave_type_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/presentation/cubit/leave_type_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/presentation/pages/add_leave_type_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/presentation/pages/leave_type_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/data/model/shift_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/presentation/cubit/shift_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/presentation/pages/add_shift_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/presentation/pages/shift_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/presentation/pages/shift_master_view_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/data/model/shift_master_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/presentation/cubit/shift_master_mapping_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/presentation/pages/add_shift_mapping_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/presentation/pages/shift_mapping_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/presentation/pages/view_shift_mapping_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/presentation/cubit/week_off_mapping_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/presentation/pages/add_week_off_mapping_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/presentation/pages/view_week_off_mapping_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/presentation/pages/week_off_mapping_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/data/model/week_off_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/presentation/cubit/week_off_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/presentation/pages/add_week_off_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/presentation/pages/view_week_off_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/presentation/pages/week_off_master_screen.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/data/model/material_master.model.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/presentation/cubit/material_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/presentation/pages/add_material_master_screen.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/presentation/pages/material_master_screen.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/presentation/pages/material_master_view_screen.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/data/model/sub_material_master.model.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/presentation/cubit/sub_material_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/presentation/pages/add_sub_material_master_screen.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/presentation/pages/sub_material_master_screen.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/presentation/pages/sub_material_master_view_screen.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/umo_master/presentation/cubit/umo_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/umo_master/presentation/pages/umo_master_screen.dart';
import 'package:k3h_erp_app/features/masters/project_master/presentation/cubit/project_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/project_master/presentation/pages/add_bank_details_screen.dart';
import 'package:k3h_erp_app/features/masters/project_master/presentation/pages/add_project_screen.dart';
import 'package:k3h_erp_app/features/masters/project_master/presentation/pages/module_add_employee_screen.dart';
import 'package:k3h_erp_app/features/masters/project_master/presentation/pages/project_details_screen.dart';
import 'package:k3h_erp_app/features/masters/project_master/presentation/pages/project_master_screen.dart';
import 'package:k3h_erp_app/features/masters/setting_dashboard/presentation/cubit/setting_dashboard_cubit.dart';
import 'package:k3h_erp_app/features/masters/setting_dashboard/presentation/pages/setting_dashboard.screen.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/data/model/terms_and_conditions.model.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/presentation/cubit/terms_and_conditions_cubit.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/presentation/pages/add_terms_and_conditions_screen.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/presentation/pages/terms_and_conditions_screen.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/presentation/pages/terms_and_conditions_view_screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/presentation/pages/finalize_vendor_edit.screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/presentation/pages/finalize_vendor_get_quotation.screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/presentation/cubit/grn_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/presentation/cubit/finalize_vendor_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/presentation/pages/finalize_vendor.screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/features/menu/presentation/pages/menu_screen.dart';
import 'package:k3h_erp_app/features/more/events/calendar/data/models/calendar_event.dart';
import 'package:k3h_erp_app/features/more/events/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:k3h_erp_app/features/more/events/calendar/presentation/pages/add_event_details_screen.dart';
import 'package:k3h_erp_app/features/more/events/calendar/presentation/pages/calendar_date_detail_screen.dart';
import 'package:k3h_erp_app/features/more/events/calendar/presentation/pages/calendar_screen.dart';
import 'package:k3h_erp_app/features/more/events/task/presentation/pages/task_transfer_history_screen.dart';
import 'package:k3h_erp_app/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:k3h_erp_app/features/notification/presentation/pages/notification_screen.dart';
import 'package:k3h_erp_app/features/parking/data/model/parking.model.dart';
import 'package:k3h_erp_app/features/parking/presentation/cubit/parking_cubit.dart';
import 'package:k3h_erp_app/features/parking/presentation/pages/edit_parking_screen.dart';
import 'package:k3h_erp_app/features/parking/presentation/pages/parking_screen.dart';
import 'package:k3h_erp_app/features/payroll/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:k3h_erp_app/features/payroll/attendance/presentation/pages/attendance_screen.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/data/model/comp_off.model.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/presentation/cubit/comp_off_cubit.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/presentation/pages/add_comp_off_screen.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/presentation/pages/comp_off_screen.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/presentation/pages/comp_off_view_screen.dart';
import 'package:k3h_erp_app/features/payroll/leave/model/leave.model.dart';
import 'package:k3h_erp_app/features/payroll/leave/presentation/cubit/leave_cubit.dart';
import 'package:k3h_erp_app/features/payroll/leave/presentation/pages/apply_leave_screen.dart';
import 'package:k3h_erp_app/features/payroll/leave/presentation/pages/leave_screen.dart';
import 'package:k3h_erp_app/features/payroll/leave/presentation/pages/leave_view_screen.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/data/model/outdoor.model.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/presentation/cubit/outdoor_cubit.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/presentation/pages/add_outdoor_screen.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/presentation/pages/outdoor_screen.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/presentation/pages/outdoor_view_screen.dart';
import 'package:k3h_erp_app/features/payroll/payroll_dashboard/presentation/cubit/payroll_dashboard_cubit.dart';
import 'package:k3h_erp_app/features/payroll/payroll_dashboard/presentation/pages/payroll_dashboard_screen.dart';
import 'package:k3h_erp_app/features/payroll/payroll_report/presentation/cubit/payroll_report_cubit.dart';
import 'package:k3h_erp_app/features/payroll/payroll_report/presentation/pages/payroll_report_screen.dart';
import 'package:k3h_erp_app/features/payroll/resignation/data/model/resignation.model.dart';
import 'package:k3h_erp_app/features/payroll/resignation/presentation/cubit/resignation_cubit.dart';
import 'package:k3h_erp_app/features/payroll/resignation/presentation/pages/add_resignation_screen.dart';
import 'package:k3h_erp_app/features/payroll/resignation/presentation/pages/resignation_screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/pages/add_material_requisition_screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/pages/add_material_screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/pages/material_requisition_screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/pages/material_requisition_view_screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/purchase_order/presentation/cubit/purchase_order_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/purchase_order/presentation/pages/generate_purchase_order.screen.dart';
import 'package:k3h_erp_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:k3h_erp_app/features/profile/presentation/pages/profile_screen.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:k3h_erp_app/features/inventory/presentation/pages/inventory_screen.dart';
import 'package:k3h_erp_app/features/login/presentation/pages/login_screen.dart';
import 'package:k3h_erp_app/features/login/presentation/pages/splash_screen.dart';
import 'package:k3h_erp_app/features/marketing/content/presentation/cubit/content_document/content_document_cubit.dart';
import 'package:k3h_erp_app/features/marketing/content/presentation/cubit/content_folder/content_folder_cubit.dart';
import 'package:k3h_erp_app/features/marketing/content/presentation/pages/content_document_screen.dart';
import 'package:k3h_erp_app/features/marketing/content/presentation/pages/content_folder_screen.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/cubit/company_master/company_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/cubit/company_master_add/company_master_add_cubit.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/pages/add_company_master_screen.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/pages/add_company_partner_screen.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/pages/company_master_screen.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/pages/company_master_view.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/pages/view_company_partner_screen.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/model/department.model.dart';
import 'package:k3h_erp_app/features/masters/department_master/presentation/cubit/department_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/department_master/presentation/pages/add_department_screen.dart';
import 'package:k3h_erp_app/features/masters/department_master/presentation/pages/department_master_screen.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/cubit/designation_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/pages/designation_screen.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/presentation/cubit/bank_list_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/presentation/pages/bank_list_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/data/model/asset_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/presentation/cubit/asset_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/presentation/pages/add_asset_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/presentation/pages/asset_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/data/model/asset_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/presentation/cubit/asset_mapping_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/presentation/pages/add_asset_mapping_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/presentation/pages/asset_mapping_master_screen.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/cubit/employee_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/pages/add_employee_screen.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/pages/employee_master_screen.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/pages/employee_master_view_details_screen.dart';
import 'package:k3h_erp_app/features/profile/presentation/pages/update_user_details_screen.dart';
import 'package:k3h_erp_app/features/project_document/approval_category/data/model/approval_category.model.dart';
import 'package:k3h_erp_app/features/project_document/approval_category/presentation/cubit/approval_category_cubit.dart';
import 'package:k3h_erp_app/features/project_document/approval_category/presentation/pages/add_approval_category_screen.dart';
import 'package:k3h_erp_app/features/project_document/approval_category/presentation/pages/approval_category_screen.dart';
import 'package:k3h_erp_app/features/project_document/approval_category/presentation/pages/view_approval_category_screen.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/data/model/approval_document.model.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/presentation/cubit/approval_document_cubit.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/presentation/pages/add_approval_document_screen.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/presentation/pages/approval_document_screen.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/presentation/pages/view_approval_document_screen.dart';
import 'package:k3h_erp_app/features/project_document/document/data/model/document.model.dart';
import 'package:k3h_erp_app/features/project_document/document/presentation/cubit/document_cubit.dart';
import 'package:k3h_erp_app/features/project_document/document/presentation/pages/add_document_screen.dart';
import 'package:k3h_erp_app/features/project_document/document/presentation/pages/document_screen.dart';
import 'package:k3h_erp_app/features/project_document/document/presentation/pages/view_document_screen.dart';
import 'package:k3h_erp_app/features/project_document/document_category/data/model/document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/document_category/presentation/cubit/document_category_cubit.dart';
import 'package:k3h_erp_app/features/project_document/document_category/presentation/pages/add_document_category_screen.dart';
import 'package:k3h_erp_app/features/project_document/document_category/presentation/pages/document_category_screen.dart';
import 'package:k3h_erp_app/features/project_document/document_category/presentation/pages/view_document_category_screen.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/data/model/rera_document.model.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/presentation/cubit/rera_document_cubit.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/presentation/pages/add_rera_document_screen.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/presentation/pages/rera_document_screen.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/presentation/pages/view_rera_document_screen.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/data/model/rera_document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/presentation/cubit/rera_document_category_cubit.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/presentation/pages/add_rera_document_category_screen.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/presentation/pages/rera_document_category_screen.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/presentation/pages/view_document_category_screen.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/presentation/cubit/approved_bank_file/approved_bank_file_cubit.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/presentation/cubit/approved_bank_folder/approved_bank_folder_cubit.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/presentation/pages/add_bank_screen.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/presentation/pages/approved_bank_file_screen.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/presentation/pages/approved_bank_folder_screen.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/cubit/building_cubit.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/pages/add_building_screen.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/pages/add_update_document_screen.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/pages/building_screen.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/pages/building_view_screen.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/pages/edit_building_details_screen.dart';
import 'package:k3h_erp_app/features/redevelopment/dashboard/presentation/cubit/redevlopment_dashboard_cubit.dart';
import 'package:k3h_erp_app/features/redevelopment/dashboard/presentation/pages/redevelopment_dashboard_screen.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/pages/proposed_offer_screen/proposed_offer_screen.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/pages/proposed_offer_screen/proposed_offer_secondary_screen.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/presentation/cubit/proposed_plans_cubit.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/presentation/pages/proposed_plans_screen.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/rent_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/data/model/payment_ledger.model.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/data/model/rent.model.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/presentation/cubit/rent_cubit.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/presentation/pages/add_payment_screen.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/presentation/pages/rent_screen.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/presentation/pages/view_payment_summary_screen.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/presentation/cubit/tenant_cubit.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/presentation/pages/add_tenant_screen.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/presentation/pages/tenant_screen.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/presentation/pages/tenant_view_screen.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/presentation/pages/add_update_tenant_document_screen.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/cubit/booking_cubit.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/pages/add_booking_screen.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/pages/approval_log_history_view_screen.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/pages/booking_screen.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/pages/booking_view_screen.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/data/model/call_log.model.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/data/model/calling_data.model.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/presentation/cubit/call_tracker_cubit.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/presentation/pages/add_calling_data_screen.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/presentation/pages/call_tracker_screen.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/presentation/pages/update_call_log_screen.dart';
import 'package:k3h_erp_app/features/sales/sales_master/classification_parameters/data/model/classification_paramerter.model.dart';
import 'package:k3h_erp_app/features/sales/sales_master/classification_parameters/presentation/cubit/classification_parameters_cubit.dart';

import 'package:k3h_erp_app/features/sales/sales_master/classification_parameters/presentation/pages/add_classification_parameter_screen.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_cubit.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/pages/add_enquiry_screen.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/pages/enquiry_screen.dart';
import 'package:k3h_erp_app/features/sales/sales_master/classification_parameters/presentation/pages/classification_parameter_screen.dart';
import 'package:k3h_erp_app/features/sales/sales_master/other_charges/data/model/other_charges.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/pages/view_enquiry_screen.dart';
import 'package:k3h_erp_app/features/sales/sales_master/other_charges/presentation/cubit/other_charges_cubit.dart';
import 'package:k3h_erp_app/features/sales/sales_master/other_charges/presentation/pages/add_other_charges_screen.dart';
import 'package:k3h_erp_app/features/sales/sales_master/other_charges/presentation/pages/other_charges_screen.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule/presentation/cubit/payment_schedule_cubit.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule/presentation/presentation/add_payment_schedule_screen.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule/presentation/presentation/payment_schedule_screen.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule_scheme/data/model/payment_schedule_scheme.model.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule_scheme/presentation/cubit/payment_schedule_scheme_cubit.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule_scheme/presentation/pages/add_payment_schedule_scheme_screen.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule_scheme/presentation/pages/payment_schedule_scheme_screen.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/data/model/project_achievement_report.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/presentation/cubit/achievement_cubit.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/presentation/pages/managers_achievement_report.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/performance/data/model/performance_report_closing.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/performance/data/model/performance_report_sourcing.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/performance/presentation/cubit/performance_cubit.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/performance/presentation/pages/performance.screen.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/performance/presentation/pages/view_performance.screen.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/performance/presentation/pages/performance._without_access_screen.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/cubit/sales_dashboard_cubit.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/pages/sales_dashboard_screen.dart';
import 'package:k3h_erp_app/features/sales/sourcing/presentation/cubit/sourcing_cubit.dart';
import 'package:k3h_erp_app/features/sales/sourcing/presentation/pages/sourcing_screen.dart';
import 'package:k3h_erp_app/features/sales/sourcing/presentation/pages/sourcing_view_screen.dart';
import 'package:k3h_erp_app/features/sales/target/data/model/sales_target_closing.model.dart';
import 'package:k3h_erp_app/features/sales/target/data/model/sales_target_sourcing.model.dart';
import 'package:k3h_erp_app/features/sales/target/presentation/cubit/target_cubit.dart';
import 'package:k3h_erp_app/features/sales/target/presentation/pages/target_screen.dart';
import 'package:k3h_erp_app/features/sales/target/presentation/pages/target_view_screen.dart';
import 'package:k3h_erp_app/features/stock_management/data/model/stock_management.model.dart';
import 'package:k3h_erp_app/features/stock_management/presentation/cubit/stock_management_cubit.dart';
import 'package:k3h_erp_app/features/stock_management/presentation/pages/add_stock_management.screen.dart';
import 'package:k3h_erp_app/features/stock_management/presentation/pages/stock_management.screen.dart';
import 'package:k3h_erp_app/features/stock_management/presentation/pages/view_stock_management.screen.dart';
import 'package:k3h_erp_app/features/tax_tracker/presentation/cubit/tax_tracker_cubit.dart';
import 'package:k3h_erp_app/features/tax_tracker/presentation/pages/add_tax_tracker.screen.dart';
import 'package:k3h_erp_app/features/tax_tracker/presentation/pages/tax_tracker.screen.dart';
import 'package:k3h_erp_app/features/tax_tracker/presentation/pages/view_tax_tracker.screen.dart';
import 'package:k3h_erp_app/features/test_screen.dart';
import 'package:k3h_erp_app/features/vendor_management/data/model/vendor.model.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/cubit/vendor/vendor_cubit.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/cubit/vendor_add/vendor_add_cubit.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/pages/add_vendor_screen.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/pages/documents_view_vendor_screen.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/pages/vendor_screen.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/pages/view_details_vendor_screen.dart';
import 'package:k3h_erp_app/main.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';

import '../features/sales/sales_master/payment_schedule/data/model/payment_schedule.model.dart';
import '../features/sales/sales_reports/achievement/presentation/pages/achievement_screen.dart';

String? authenticateAndAuthorizeRoute(GoRouterState state) {
  // SPLASH || LOGIN
  if (state.uri.path == AppRoutes.splashScreen ||
      state.uri.path == AppRoutes.login ||
      state.uri.path == AppRoutes.register
  // state.uri.path == AppRoutes.projectList
  ) {
    return null;
  }
  // AUTHENTICATION
  final localStorage = LocalStorageManager();
  final menuData = localStorage.getString(StorageKey.menu);
  final bool isLoggedIn = menuData != null;
  if (!isLoggedIn) {
    return AppRoutes.login;
  }
  // AUTHORIZATION
  AuthorizationModel? routeAuthorizationModel =
      Authorization.routeAuthorizationMap[state.uri.path];
  if (routeAuthorizationModel == null) {
    return null;
  }
  if (!routeAuthorizationModel.isAccess) {
    return AppRoutes.notAuthorized;
  }
  return null;
}

double? _readDouble(dynamic extraVal, String? queryVal) {
  if (extraVal != null && extraVal is num) return extraVal.toDouble();
  if (queryVal != null && queryVal.isNotEmpty) return double.tryParse(queryVal);
  return null;
}

RentModel? _rentModelFromQuery(String? encoded) {
  if (encoded == null || encoded.isEmpty) return null;
  try {
    final json =
        jsonDecode(
              EncryptionManager.decryptData(Uri.decodeQueryComponent(encoded)),
            )
            as Map<String, dynamic>;
    return RentModel.fromJson(json);
  } catch (_) {
    return null;
  }
}

List<RentDetailsModel> _rentDetailsFromQuery(String? encoded) {
  if (encoded == null || encoded.isEmpty) return [];
  try {
    final list =
        jsonDecode(
              EncryptionManager.decryptData(Uri.decodeQueryComponent(encoded)),
            )
            as List<dynamic>;
    return list
        .map((e) => RentDetailsModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}

final GoRouter goRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: AppRoutes.splashScreen,
  redirect: (context, state) {
    // Track the current route for menu highlighting
    final currentPath = state.uri.path;
    if (currentPath != AppRoutes.menu && currentPath.isNotEmpty) {
      LocalStorageManager().setString(StorageKey.lastActiveRoute, currentPath);
    }
    return authenticateAndAuthorizeRoute(state);
  },
  routes: [
    // SPLASH SCREEN
    GoRoute(
      path: AppRoutes.splashScreen,
      name: AppRoutes.splashScreen,
      builder: (context, state) {
        return const SplashScreen();
      },
    ),
    // NOT AUTHORIZED
    GoRoute(
      path: AppRoutes.notAuthorized,
      name: AppRoutes.notAuthorized,
      builder: (context, state) {
        return const NotAuthorizedScreen();
      },
    ),
    // REGISTER
    GoRoute(
      path: AppRoutes.register,
      name: AppRoutes.register,
      builder: (context, state) {
        return const RegisterScreen();
      },
    ),
    // LOGIN
    GoRoute(
      path: AppRoutes.login,
      name: AppRoutes.login,
      builder: (context, state) {
        return const LoginScreen();
      },
    ),
    // SCREENS
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<MainScreenCubit>(
              create: (context) => MainScreenCubit(),
            ),
            BlocProvider<UtilsCubit>(create: (context) => UtilsCubit()),
          ],
          child: MainScreen(child: child),
        );
      },
      routes: [
        // DASHBOARD
        GoRoute(
          path: AppRoutes.dashboardScreen,
          name: AppRoutes.dashboardScreen,
          builder: (context, state) {
            return BlocProvider(
              create: (_) => DashboardCubit(),
              child: DashboardScreen(),
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.pendingApprovalScreen,
              name: AppRoutes.pendingApprovalScreen,

              builder: (context, state) {
                /// Encrypted Data
                final queryParameterPendingApprovalData =
                    state.uri.queryParameters['pendingApproval'];

                /// Screen Title
                final queryParameterTitle = state.uri.queryParameters['title'];

                /// onView Route / Type
                final queryParameterOnView =
                    state.uri.queryParameters['onViewRoute'];

                /// Parsed Data
                List<List<Map<String, String>>> data = [];

                if (queryParameterPendingApprovalData != null) {
                  final decryptedData = EncryptionManager.decryptData(
                    Uri.decodeQueryComponent(queryParameterPendingApprovalData),
                  );

                  final decodedData = jsonDecode(decryptedData);

                  data =
                      (decodedData as List)
                          .map<List<Map<String, String>>>(
                            (card) =>
                                (card as List)
                                    .map<Map<String, String>>(
                                      (item) => Map<String, String>.from(item),
                                    )
                                    .toList(),
                          )
                          .toList();
                }

                return BlocProvider(
                  create: (_) => DashboardCubit(),

                  child: PendingApprovalsScreen(
                    pageTitle: queryParameterTitle ?? "Pending Approvals",

                    onViewRoute: queryParameterOnView!,

                    data: data,
                  ),
                );
              },
            ),
          ],
        ),

        GoRoute(
          path: AppRoutes.settingDashboard,
          name: AppRoutes.settingDashboard,
          builder: (context, state) {
            return BlocProvider(
              create: (_) => SettingDashboardCubit(),
              child: SettingDashboardScreen(),
            );
          },
        ),
        //
        GoRoute(
          path: AppRoutes.projectOverview,
          name: AppRoutes.projectOverview,
          builder: (context, state) {
            final queryParameterProject = state.uri.queryParameters['project'];
            final ProjectModel? projectModel =
                queryParameterProject != null
                    ? ProjectModel.fromJson(
                      jsonDecode(
                        EncryptionManager.decryptData(
                          Uri.decodeQueryComponent(queryParameterProject),
                        ),
                      ),
                    )
                    : null;
            return BlocProvider(
              create: (context) => DashboardCubit(),
              child: ProjectOverviewScreen(project: projectModel!),
            );
          },
        ),
        // COMPANY MASTER
        GoRoute(
          name: AppRoutes.companyMaster,
          path: AppRoutes.companyMaster,
          builder: (context, state) {
            return BlocProvider(
              create: (context) => CompanyMasterCubit(),
              child: CompanyMasterScreen(),
            );
          },
          routes: [
            GoRoute(
              parentNavigatorKey: navigatorKey,
              name: AppRoutes.addCompany,
              path: AppRoutes.addCompany,
              builder: (context, state) {
                final queryParameterCompany =
                    state.uri.queryParameters['company'];
                final CompanyModel? companyModel =
                    queryParameterCompany != null
                        ? CompanyModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeQueryComponent(queryParameterCompany),
                            ),
                          ),
                        )
                        : null;
                return BlocProvider(
                  create: (context) => CompanyMasterAddCubit(),
                  child: AddCompanyMasterScreen(company: companyModel),
                );
              },
            ),
            GoRoute(
              parentNavigatorKey: navigatorKey,
              name: AppRoutes.addCompanyPartner,
              path: AppRoutes.addCompanyPartner,
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>? ?? {};
                final partner = extra['partner'] as CompanyPartnerModel?;
                final index = extra['index'] as int?;
                final cubit = extra['cubit'] as CompanyMasterAddCubit?;
                return BlocProvider.value(
                  value: cubit ?? context.read<CompanyMasterAddCubit>(),
                  child: AddCompanyPartnerScreen(
                    companyPartner: partner,
                    index: index,
                  ),
                );
              },
            ),
            GoRoute(
              parentNavigatorKey: navigatorKey,
              name: AppRoutes.viewCompanyDetails,
              path: AppRoutes.viewCompanyDetails,
              builder: (context, state) {
                final queryParameterVendor =
                    state.uri.queryParameters['company'];
                if (queryParameterVendor != null) {
                  final decodedJson = jsonDecode(
                    EncryptionManager.decryptData(
                      Uri.decodeQueryComponent(queryParameterVendor),
                    ),
                  );
                  final companyModel = CompanyModel.fromJson(decodedJson);
                  return CompanyMasterViewScreen(company: companyModel);
                } else {
                  return Scaffold();
                }
              },
            ),
            GoRoute(
              parentNavigatorKey: navigatorKey,
              name: AppRoutes.viewCompanyPartner,
              path: AppRoutes.viewCompanyPartner,
              builder: (context, state) {
                final queryParameterCompany =
                    state.uri.queryParameters['company'];
                if (queryParameterCompany != null) {
                  final decodedJson = jsonDecode(
                    EncryptionManager.decryptData(
                      Uri.decodeQueryComponent(queryParameterCompany),
                    ),
                  );
                  final companyModel = CompanyModel.fromJson(decodedJson);
                  return ViewCompanyPartnerScreen(company: companyModel);
                }
                return Scaffold();
              },
            ),
          ],
        ),
        // DEPARTMENT MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => DepartmentMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.departmentMaster,
              path: AppRoutes.departmentMaster,
              builder: (context, state) {
                return const DepartmentMasterScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addDepartment,
              path: AppRoutes.addDepartment,
              builder: (context, state) {
                final queryParameterDepartment =
                    state.uri.queryParameters['department'];
                final DepartmentModel? department =
                    queryParameterDepartment != null
                        ? DepartmentModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterDepartment),
                            ),
                          ),
                        )
                        : null;
                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
                return AddDepartmentScreen(
                  department: department,
                  index: index,
                );
              },
            ),
          ],
        ),
        // DESIGNATION MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => DesignationMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.designationMaster,
              path: AppRoutes.designationMaster,
              builder: (context, state) {
                return const DesignationMasterScreen();
              },
            ),

            GoRoute(
              // parentNavigatorKey: navigatorKey,
              name: AppRoutes.addDesignation,
              path: AppRoutes.addDesignation,
              builder: (context, state) {
                final queryParameterDesignation =
                    state.uri.queryParameters['designation'];
                final DesignationMasterModel? designation =
                    queryParameterDesignation != null
                        ? DesignationMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterDesignation),
                            ),
                          ),
                        )
                        : null;
                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
                return AddDesignationScreen(
                  designationMasterModel: designation,
                  index: index,
                );
              },
            ),
            GoRoute(
              // parentNavigatorKey: navigatorKey,
              path: AppRoutes.employeeModuleAccess,
              name: AppRoutes.employeeModuleAccess,
              builder: (context, state) {
                final queryParameter = state.uri.queryParameters['designation'];
                if (queryParameter == null) {
                  return TestScreen();
                }
                final designationJson = jsonDecode(
                  EncryptionManager.decryptData(
                    Uri.decodeComponent(queryParameter),
                  ),
                );
                final designation = DesignationMasterModel.fromJson(
                  designationJson,
                );
                return ModuleAccessScreen(designation: designation);
              },
            ),
          ],
        ),
        // BANK LIST MASTER
        GoRoute(
          name: AppRoutes.bankListMaster,
          path: AppRoutes.bankListMaster,
          builder: (context, state) {
            return BlocProvider(
              create: (context) => BankListMasterCubit(),
              child: BankListScreen(),
            );
          },
        ),
        // TERMS AND CONDITIONS MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => TermsAndConditionsCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.termsAndConditions,
              path: AppRoutes.termsAndConditions,
              builder: (context, state) {
                return TermsAndConditionsScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addTermsAndConditions,
              path: AppRoutes.addTermsAndConditions,
              builder: (context, state) {
                final queryParameterTnc =
                    state.uri.queryParameters['termsAndCondition'];
                final TermsAndConditionsModel? termsAndCondition =
                    queryParameterTnc != null
                        ? TermsAndConditionsModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterTnc),
                            ),
                          ),
                        )
                        : null;
                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
                final tabIndex =
                    int.tryParse(
                      state.uri.queryParameters['tabIndex'] ?? '0',
                    ) ??
                    0;
                return AddTermsAndConditionsScreen(
                  termsAndConditions: termsAndCondition,
                  index: index,
                  tabIndex: tabIndex,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.viewTermsAndConditions,
              path: AppRoutes.viewTermsAndConditions,
              builder: (context, state) {
                final queryParameterTNC = state.uri.queryParameters['tnc'];
                if (queryParameterTNC != null) {
                  final decodedJson = jsonDecode(
                    EncryptionManager.decryptData(
                      Uri.decodeQueryComponent(queryParameterTNC),
                    ),
                  );
                  final tnc = TermsAndConditionsModel.fromJson(decodedJson);
                  return TermsAndConditionsViewScreen(termsAndCondition: tnc);
                } else {
                  return Scaffold();
                }
              },
            ),
          ],
        ),
        // ASSET MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => AssetMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.assetMaster,
              path: AppRoutes.assetMaster,
              builder: (context, state) {
                return const AssetMasterScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addAssetMaster,
              path: AppRoutes.addAssetMaster,
              builder: (context, state) {
                final queryParameterAsset = state.uri.queryParameters['asset'];

                final AssetMasterModel? asset =
                    queryParameterAsset != null
                        ? AssetMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterAsset),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AddAssetMasterScreen(asset: asset, index: index);
              },
            ),
            GoRoute(
              name: AppRoutes.viewAssetMaster,
              path: AppRoutes.viewAssetMaster,
              builder: (context, state) {
                final queryParameterAsset = state.uri.queryParameters['asset'];

                final AssetMasterModel? assetMaster =
                    queryParameterAsset != null
                        ? AssetMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterAsset),
                            ),
                          ),
                        )
                        : null;
                return AssetMasterViewScreen(assetMaster: assetMaster!);
              },
            ),
          ],
        ),
        // ASSET MAPPING MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => AssetMappingMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.assetMappingMaster,
              path: AppRoutes.assetMappingMaster,
              builder: (context, state) {
                return const AssetMappingMasterScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addAssetMappingMaster,
              path: AppRoutes.addAssetMappingMaster,
              builder: (context, state) {
                final queryParameterAssetMapping =
                    state.uri.queryParameters['assetMapping'];

                final AssetMappingModel? assetMapping =
                    queryParameterAssetMapping != null
                        ? AssetMappingModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterAssetMapping),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AddAssetMappingMasterScreen(
                  assetMapping: assetMapping,
                  index: index,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.viewAssetMappingMaster,
              path: AppRoutes.viewAssetMappingMaster,
              builder: (context, state) {
                final queryParameterAssetMapping =
                    state.uri.queryParameters['assetMapping'];
                final AssetMappingModel? assetMapping =
                    queryParameterAssetMapping != null
                        ? AssetMappingModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterAssetMapping),
                            ),
                          ),
                        )
                        : null;
                return AssetMappingMasterViewScreen(
                  assetMapping: assetMapping!,
                );
              },
            ),
          ],
        ),
        // BRANCH MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => BranchMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.branchMaster,
              path: AppRoutes.branchMaster,
              builder: (context, state) {
                return const BranchMasterScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addBranchMaster,
              path: AppRoutes.addBranchMaster,
              builder: (context, state) {
                final queryParameterBranchMaster =
                    state.uri.queryParameters['branchMaster'];

                final BranchMasterModel? branchMaster =
                    queryParameterBranchMaster != null
                        ? BranchMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterBranchMaster),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AddBranchMasterScreen(
                  branch: branchMaster,
                  index: index,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.viewBranchMaster,
              path: AppRoutes.viewBranchMaster,
              builder: (context, state) {
                final queryParameterBranchMaster =
                    state.uri.queryParameters['branchMaster'];
                final BranchMasterModel? branchMaster =
                    queryParameterBranchMaster != null
                        ? BranchMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterBranchMaster),
                            ),
                          ),
                        )
                        : null;
                return BranchMasterViewScreen(branch: branchMaster!);
              },
            ),
          ],
        ),
        // BRANCH ASSOCIATION MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => BranchAssociationMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.branchAssociation,
              path: AppRoutes.branchAssociation,
              builder: (context, state) {
                return const BranchAssociationMasterScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addBranchAssociation,
              path: AppRoutes.addBranchAssociation,
              builder: (context, state) {
                final queryParameterBranchAssociationMaster =
                    state.uri.queryParameters['branchAssociation'];

                final BranchAssociationModel? branchAssociation =
                    queryParameterBranchAssociationMaster != null
                        ? BranchAssociationModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(
                                queryParameterBranchAssociationMaster,
                              ),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AddBranchAssociationMasterScreen(
                  branchAssociation: branchAssociation,
                  index: index,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.viewBranchAssociation,
              path: AppRoutes.viewBranchAssociation,
              builder: (context, state) {
                final queryParameterBranchAssociationMaster =
                    state.uri.queryParameters['branchAssociation'];

                final BranchAssociationModel? branchAssociation =
                    queryParameterBranchAssociationMaster != null
                        ? BranchAssociationModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(
                                queryParameterBranchAssociationMaster,
                              ),
                            ),
                          ),
                        )
                        : null;

                return BranchAssociationMasterViewScreen(
                  branchAssociation: branchAssociation!,
                );
              },
            ),
          ],
        ),
        // DEDUCTION MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => DeductionMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.deductionMaster,
              path: AppRoutes.deductionMaster,
              builder: (context, state) {
                return const DeductionMasterScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addDeductionMaster,
              path: AppRoutes.addDeductionMaster,
              builder: (context, state) {
                final queryParameterDeductionMaster =
                    state.uri.queryParameters['deduction'];

                final DeductionMasterModel? deduction =
                    queryParameterDeductionMaster != null
                        ? DeductionMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(
                                queryParameterDeductionMaster,
                              ),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AddDeductionMasterScreen(
                  deductionMasterModel: deduction,
                  index: index,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.viewDeductionMaster,
              path: AppRoutes.viewDeductionMaster,
              builder: (context, state) {
                final queryParameterDeductionMaster =
                    state.uri.queryParameters['deduction'];

                final DeductionMasterModel? deduction =
                    queryParameterDeductionMaster != null
                        ? DeductionMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(
                                queryParameterDeductionMaster,
                              ),
                            ),
                          ),
                        )
                        : null;

                return DeductionMasterViewScreen(
                  deductionMasterModel: deduction!,
                );
              },
            ),
          ],
        ),
        // EARNING MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => EarningMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.earningMaster,
              path: AppRoutes.earningMaster,
              builder: (context, state) {
                return const EarningMasterScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addEarningMaster,
              path: AppRoutes.addEarningMaster,
              builder: (context, state) {
                final queryParameterEarningMaster =
                    state.uri.queryParameters['earning'];

                final EarningMasterModel? earning =
                    queryParameterEarningMaster != null
                        ? EarningMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterEarningMaster),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AddEarningMasterScreen(
                  earningMasterModel: earning,
                  index: index,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.viewEarningMaster,
              path: AppRoutes.viewEarningMaster,
              builder: (context, state) {
                final queryParameterEarningMaster =
                    state.uri.queryParameters['earning'];

                final EarningMasterModel? earning =
                    queryParameterEarningMaster != null
                        ? EarningMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterEarningMaster),
                            ),
                          ),
                        )
                        : null;
                return EarningMasterViewScreen(earningMasterModel: earning!);
              },
            ),
          ],
        ),
        // HOLIDAY MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => HolidayMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.holidayMaster,
              path: AppRoutes.holidayMaster,
              builder: (context, state) {
                return const HolidayMasterScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addHolidayMaster,
              path: AppRoutes.addHolidayMaster,
              builder: (context, state) {
                final queryParameterHolidayMaster =
                    state.uri.queryParameters['holiday'];

                final HolidayMasterModel? holiday =
                    queryParameterHolidayMaster != null
                        ? HolidayMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterHolidayMaster),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AddHolidayMasterScreen(
                  holidayMaster: holiday,
                  index: index,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.viewHolidayMaster,
              path: AppRoutes.viewHolidayMaster,
              builder: (context, state) {
                final queryParameterHolidayMaster =
                    state.uri.queryParameters['holiday'];

                final HolidayMasterModel? holiday =
                    queryParameterHolidayMaster != null
                        ? HolidayMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterHolidayMaster),
                            ),
                          ),
                        )
                        : null;

                return HolidayMasterViewScreen(holidayMaster: holiday!);
              },
            ),
          ],
        ),
        // HOLIDAY MAPPING MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => HolidayMappingMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.holidayMappingMaster,
              path: AppRoutes.holidayMappingMaster,
              builder: (context, state) {
                return const HolidayMappingMasterScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addHolidayMappingMaster,
              path: AppRoutes.addHolidayMappingMaster,
              builder: (context, state) {
                final queryParameterHolidayMappingMaster =
                    state.uri.queryParameters['holidayMapping'];

                final HolidayMappingModel? holidayMapping =
                    queryParameterHolidayMappingMaster != null
                        ? HolidayMappingModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(
                                queryParameterHolidayMappingMaster,
                              ),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AddHolidayMappingMasterScreen(
                  holidayMapping: holidayMapping,
                  index: index,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.viewHolidayMappingMaster,
              path: AppRoutes.viewHolidayMappingMaster,
              builder: (context, state) {
                final queryParameterHolidayMappingMaster =
                    state.uri.queryParameters['holidayMapping'];

                final HolidayMappingModel? holidayMapping =
                    queryParameterHolidayMappingMaster != null
                        ? HolidayMappingModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(
                                queryParameterHolidayMappingMaster,
                              ),
                            ),
                          ),
                        )
                        : null;

                return HolidayMappingMasterViewScreen(
                  holidayMapping: holidayMapping!,
                );
              },
            ),
          ],
        ),
        //LEAVE ENCASHMENT MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => LeaveEncashmentMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.leaveEncashmentMaster,
              name: AppRoutes.leaveEncashmentMaster,
              builder: (context, state) {
                return const LeaveEncashmentScreen();
              },
            ),
            GoRoute(
              path: AppRoutes.addLeaveEncashmentMaster,
              name: AppRoutes.addLeaveEncashmentMaster,
              builder: (context, state) {
                final queryParameterLeaveEncashment =
                    state.uri.queryParameters['leaveEncashment'];
                final LeaveEncashmentMasterModel? leaveEncashmentMasterModel =
                    queryParameterLeaveEncashment != null
                        ? LeaveEncashmentMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(
                                queryParameterLeaveEncashment,
                              ),
                            ),
                          ),
                        )
                        : null;
                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
                return AddLeaveEncashmentMasterScreen(
                  leaveEncashmentMasterModel: leaveEncashmentMasterModel,
                  index: index,
                );
              },
            ),
          ],
        ),
        // LEAVE TYPE MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => LeaveTypeMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.leaveTypeMaster,
              name: AppRoutes.leaveTypeMaster,
              builder: (context, state) {
                return const LeaveTypeMasterScreen();
              },
            ),
            GoRoute(
              path: AppRoutes.addLeaveTypeMaster,
              name: AppRoutes.addLeaveTypeMaster,
              builder: (context, state) {
                final queryParameterLeaveType =
                    state.uri.queryParameters['leaveType'];
                final LeaveTypeModel? leaveTypeMasterModel =
                    queryParameterLeaveType != null
                        ? LeaveTypeModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterLeaveType),
                            ),
                          ),
                        )
                        : null;
                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
                return AddLeaveTypeMasterScreen(
                  leaveTypeModel: leaveTypeMasterModel,
                  index: index,
                );
              },
            ),
          ],
        ),
        // SHIFT MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => ShiftMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.shiftMaster,
              name: AppRoutes.shiftMaster,
              builder: (context, state) {
                return const ShiftMasterScreen();
              },
            ),
            GoRoute(
              path: AppRoutes.addShiftMaster,
              name: AppRoutes.addShiftMaster,
              builder: (context, state) {
                final queryParameterLeaveType =
                    state.uri.queryParameters['shift'];
                final ShiftMasterModel? shiftMasterModel =
                    queryParameterLeaveType != null
                        ? ShiftMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterLeaveType),
                            ),
                          ),
                        )
                        : null;
                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
                return AddShiftMasterScreen(
                  shiftMasterModel: shiftMasterModel,
                  index: index,
                );
              },
            ),

            GoRoute(
              name: AppRoutes.viewShiftMaster,
              path: AppRoutes.viewShiftMaster,
              builder: (context, state) {
                final queryParameterShift = state.uri.queryParameters['shift'];

                final ShiftMasterModel? shiftMaster =
                    queryParameterShift != null
                        ? ShiftMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterShift),
                            ),
                          ),
                        )
                        : null;
                return ShiftMasterViewScreen(shiftMaster: shiftMaster!);
              },
            ),
          ],
        ),
        // SHIFT MAPPING MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => ShiftMappingMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.shiftMappingMaster,
              name: AppRoutes.shiftMappingMaster,
              builder: (context, state) {
                return const ShiftMappingMasterScreen();
              },
            ),
            GoRoute(
              path: AppRoutes.addShiftMappingMaster,
              name: AppRoutes.addShiftMappingMaster,
              builder: (context, state) {
                final queryParameterShitMapping =
                    state.uri.queryParameters['shiftMapping'];

                final ShiftMappingModel? shiftMappingMaster =
                    queryParameterShitMapping != null
                        ? ShiftMappingModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterShitMapping),
                            ),
                          ),
                        )
                        : null;
                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AddShiftMappingMasterScreen(
                  shiftMappingModel: shiftMappingMaster,
                  index: index,
                );
              },
            ),
            GoRoute(
              path: AppRoutes.viewShiftMappingMaster,
              name: AppRoutes.viewShiftMappingMaster,
              builder: (context, state) {
                final queryParameterShiftMapping =
                    state.uri.queryParameters['shiftMapping'];

                final ShiftMappingModel? shiftMappingMaster =
                    queryParameterShiftMapping != null
                        ? ShiftMappingModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterShiftMapping),
                            ),
                          ),
                        )
                        : null;

                return ViewShiftMappingMasterScreen(
                  shiftMappingModel: shiftMappingMaster!,
                );
              },
            ),
          ],
        ),
        //WEEK OFF MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => WeekOffMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.weekOffMaster,
              name: AppRoutes.weekOffMaster,
              builder: (context, state) {
                return const WeekOffMasterScreen();
              },
            ),
            GoRoute(
              path: AppRoutes.addWeekOffMaster,
              name: AppRoutes.addWeekOffMaster,
              builder: (context, state) {
                final queryParameterWeekOff =
                    state.uri.queryParameters['weekOff'];

                final WeekOffMasterModel? weekOffMaster =
                    queryParameterWeekOff != null
                        ? WeekOffMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterWeekOff),
                            ),
                          ),
                        )
                        : null;
                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AddWeekOffMasterScreen(
                  weekOffMasterModel: weekOffMaster,
                  index: index,
                );
              },
            ),
            GoRoute(
              path: AppRoutes.viewWeekOffMaster,
              name: AppRoutes.viewWeekOffMaster,
              builder: (context, state) {
                final queryParameterWeekOff =
                    state.uri.queryParameters['weekOff'];

                final WeekOffMasterModel? weekOffMaster =
                    queryParameterWeekOff != null
                        ? WeekOffMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterWeekOff),
                            ),
                          ),
                        )
                        : null;
                return ViewWeekOffMasterScreen(weekOffMaster: weekOffMaster!);
              },
            ),
          ],
        ),
        //WEEK OFF MAPPING MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => WeekOffMappingMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.weekOffMappingMaster,
              name: AppRoutes.weekOffMappingMaster,
              builder: (context, state) {
                return const WeekOffMappingMasterScreen();
              },
            ),
            GoRoute(
              path: AppRoutes.addWeekOffMappingMaster,
              name: AppRoutes.addWeekOffMappingMaster,
              builder: (context, state) {
                final queryParameterWeekOffMapping =
                    state.uri.queryParameters['weekOffMapping'];

                final WeekOffMappingModel? weekOffMappingMaster =
                    queryParameterWeekOffMapping != null
                        ? WeekOffMappingModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterWeekOffMapping),
                            ),
                          ),
                        )
                        : null;
                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AddWeekOffMappingMasterScreen(
                  weekOffMappingMasterModel: weekOffMappingMaster,
                  index: index,
                );
              },
            ),
            GoRoute(
              path: AppRoutes.viewWeekOffMappingMaster,
              name: AppRoutes.viewWeekOffMappingMaster,
              builder: (context, state) {
                final queryParameterWeekOff =
                    state.uri.queryParameters['weekOffMapping'];

                final WeekOffMappingModel? weekOffMappingMaster =
                    queryParameterWeekOff != null
                        ? WeekOffMappingModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterWeekOff),
                            ),
                          ),
                        )
                        : null;
                return ViewWeekOffMappingMasterScreen(
                  weekOffMappingMasterModel: weekOffMappingMaster!,
                );
              },
            ),
          ],
        ),
        // LEAVE CREDIT DEBIT MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => LeaveCreditConfigurationMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.leaveCreditConfigurationMaster,
              name: AppRoutes.leaveCreditConfigurationMaster,
              builder: (context, state) {
                return const LeaveCreditConfigurationMasterScreen();
              },
            ),
            GoRoute(
              path: AppRoutes.addLeaveCreditConfigurationMaster,
              name: AppRoutes.addLeaveCreditConfigurationMaster,
              builder: (context, state) {
                final queryParameterLeaveCreditConfiguration =
                    state.uri.queryParameters['leaveCreditConfiguration'];

                final LeaveCreditConfigurationMasterModel?
                leaveCreditConfiguration =
                    queryParameterLeaveCreditConfiguration != null
                        ? LeaveCreditConfigurationMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(
                                queryParameterLeaveCreditConfiguration,
                              ),
                            ),
                          ),
                        )
                        : null;
                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AddLeaveCreditConfigurationMasterScreen(
                  leaveCreditConfigurationMasterModel: leaveCreditConfiguration,
                  index: index,
                );
              },
            ),
            GoRoute(
              path: AppRoutes.addLeaveBalanceType,
              name: AppRoutes.addLeaveBalanceType,
              builder: (context, state) {
                final queryParameterLeaveBalanceTypes =
                    state.uri.queryParameters['existingLeaveBalanceTypes'];

                List<LeaveBalanceType> existingLeaveBalanceTypes = [];
                if (queryParameterLeaveBalanceTypes != null) {
                  final decryptedData = EncryptionManager.decryptData(
                    Uri.decodeComponent(queryParameterLeaveBalanceTypes),
                  );
                  final List<dynamic> jsonList = jsonDecode(decryptedData);
                  existingLeaveBalanceTypes =
                      jsonList
                          .map((json) => LeaveBalanceType.fromJson(json))
                          .toList();
                }

                return AddLeaveBalanceTypeScreen(
                  existingLeaveBalanceTypes: existingLeaveBalanceTypes,
                );
              },
            ),
            GoRoute(
              path: AppRoutes.viewLeaveCreditConfigurationMaster,
              name: AppRoutes.viewLeaveCreditConfigurationMaster,
              builder: (context, state) {
                final queryParameterLeaveCreditConfiguration =
                    state.uri.queryParameters['leaveCreditConfiguration'];

                final LeaveCreditConfigurationMasterModel?
                leaveCreditConfigurationMaster =
                    queryParameterLeaveCreditConfiguration != null
                        ? LeaveCreditConfigurationMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(
                                queryParameterLeaveCreditConfiguration,
                              ),
                            ),
                          ),
                        )
                        : null;
                return LeaveCreditConfigurationMasterViewScreen(
                  leaveCreditConfigurationMaster:
                      leaveCreditConfigurationMaster!,
                );
              },
            ),
          ],
        ),
        // EMPLOYEE MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => EmployeeMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.employeeMaster,
              name: AppRoutes.employeeMaster,
              builder: (context, state) {
                return const EmployeeMasterScreen();
              },
              routes: [
                GoRoute(
                  path: AppRoutes.addUpdateEmployee,
                  name: AppRoutes.addUpdateEmployee,
                  builder: (context, state) {
                    final employee = state.uri.queryParameters['employee'];
                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;

                    return AddEmployeeScreen(
                      employee:
                          employee != null
                              ? UserModel.fromJson(
                                jsonDecode(
                                  EncryptionManager.decryptData(
                                    Uri.decodeComponent(employee),
                                  ),
                                ),
                              )
                              : null,
                      index: index,
                    );
                  },
                ),
                GoRoute(
                  path: AppRoutes.employeeViewDetails,
                  name: AppRoutes.employeeViewDetails,
                  builder: (context, state) {
                    final employee = state.uri.queryParameters['employee'];

                    return EmployeeMasterViewDetailsScreen(
                      employee: UserModel.fromJson(
                        jsonDecode(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(employee!),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // PROJECT MANAGEMENT
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => ProjectMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.projectMaster,
              name: AppRoutes.projectMaster,
              builder: (context, state) {
                return ProjectMasterScreen();
              },
            ),
            GoRoute(
              path: AppRoutes.addProjectMaster,
              name: AppRoutes.addProjectMaster,
              builder: (context, state) {
                final queryParameterProject =
                    state.uri.queryParameters['project'];
                final ProjectModel? project =
                    queryParameterProject != null
                        ? ProjectModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterProject),
                            ),
                          ),
                        )
                        : null;
                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
                return AddProjectScreen(project: project, index: index);
              },
            ),
            GoRoute(
              path: AppRoutes.projectDetails,
              name: AppRoutes.projectDetails,
              builder: (context, state) {
                final queryParameterProject =
                    state.uri.queryParameters['project'];
                final ProjectModel? project =
                    queryParameterProject != null
                        ? ProjectModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterProject),
                            ),
                          ),
                        )
                        : null;
                return ProjectDetailsScreen(project: project!);
              },
              routes: [
                GoRoute(
                  name: AppRoutes.addBankDetails,
                  path: AppRoutes.addBankDetails,
                  builder: (context, state) {
                    final queryParameterProject =
                        state.uri.queryParameters['project'];
                    final ProjectModel? project =
                        queryParameterProject != null
                            ? ProjectModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterProject),
                                ),
                              ),
                            )
                            : null;
                    final queryParameterBank =
                        state.uri.queryParameters['bank'];
                    final BankDetailsModel? bankDetailsModel =
                        queryParameterBank != null
                            ? BankDetailsModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterBank),
                                ),
                              ),
                            )
                            : null;
                    return AddBankDetailsScreen(
                      bankDetailsModel: bankDetailsModel,
                      project: project!,
                    );
                  },
                ),
                GoRoute(
                  name: AppRoutes.addEmployeeToModule,
                  path: AppRoutes.addEmployeeToModule,
                  builder: (context, state) {
                    final queryParameterModulesWorkflowApprovalModel =
                        state
                            .uri
                            .queryParameters['modulesWorkflowApprovalModel'];
                    final queryParameterProjectId =
                        state.uri.queryParameters['projectId'];

                    final projectId =
                        queryParameterProjectId != null &&
                                queryParameterProjectId.isNotEmpty
                            ? int.parse(
                              EncryptionManager.decryptData(
                                Uri.decodeComponent(queryParameterProjectId),
                              ),
                            )
                            : null;
                    final modulesWorkflowApprovalModel =
                        queryParameterModulesWorkflowApprovalModel != null &&
                                queryParameterModulesWorkflowApprovalModel
                                    .isNotEmpty
                            ? ModulesWorkflowApprovalModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(
                                    queryParameterModulesWorkflowApprovalModel,
                                  ),
                                ),
                              ),
                            )
                            : null;
                    return ModuleAddEmployeeScreen(
                      module: modulesWorkflowApprovalModel!,
                      projectId: projectId!,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // MATERIAL MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => MaterialMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.materialMaster,
              path: AppRoutes.materialMaster,
              builder: (context, state) {
                return MaterialMasterScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addMaterialMaster,
              path: AppRoutes.addMaterialMaster,
              builder: (context, state) {
                final queryParameterMaterial =
                    state.uri.queryParameters['material'];
                final MaterialMasterModel? material =
                    queryParameterMaterial != null
                        ? MaterialMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeQueryComponent(queryParameterMaterial),
                            ),
                          ),
                        )
                        : null;
                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
                // Use BlocProvider.value with service locator to get the singleton instance
                return AddMaterialMasterScreen(
                  material: material,
                  index: index,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.viewMaterialMaster,
              path: AppRoutes.viewMaterialMaster,
              builder: (context, state) {
                final queryParameterMaterial =
                    state.uri.queryParameters['material'];
                final MaterialMasterModel? material =
                    queryParameterMaterial != null
                        ? MaterialMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeQueryComponent(queryParameterMaterial),
                            ),
                          ),
                        )
                        : null;
                return MaterialMasterViewScreen(material: material!);
              },
            ),
          ],
        ),
        GoRoute(
          name: AppRoutes.uomMaster,
          path: AppRoutes.uomMaster,
          builder: (context, state) {
            return BlocProvider.value(
              value: UOMMasterCubit(),
              child: UOMMasterScreen(),
            );
          },
        ),
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => SubMaterialMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.subMaterialMaster,
              path: AppRoutes.subMaterialMaster,
              builder: (context, state) {
                return SubMaterialMasterScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addSubMaterialMaster,
              path: AppRoutes.addSubMaterialMaster,
              builder: (context, state) {
                final queryParameterSubMaterial =
                    state.uri.queryParameters['subMaterial'];
                final SubMaterialMasterModel? subMaterial =
                    queryParameterSubMaterial != null
                        ? SubMaterialMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeQueryComponent(
                                queryParameterSubMaterial,
                              ),
                            ),
                          ),
                        )
                        : null;
                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
                return AddSubMaterialMasterScreen(
                  subMaterial: subMaterial,
                  index: index,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.viewSubMaterialMaster,
              path: AppRoutes.viewSubMaterialMaster,
              builder: (context, state) {
                final queryParameterSubMaterial =
                    state.uri.queryParameters['subMaterial'];
                final SubMaterialMasterModel? subMaterial =
                    queryParameterSubMaterial != null
                        ? SubMaterialMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeQueryComponent(
                                queryParameterSubMaterial,
                              ),
                            ),
                          ),
                        )
                        : null;
                return SubMaterialMasterViewScreen(subMaterial: subMaterial!);
              },
            ),
          ],
        ),
        // REDEVELOPMENT DASHBOARD

        // BUILDING
        ShellRoute(
          builder: (context, state, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => RedevlopmentDashboardCubit(),
                  child: child,
                ),
                BlocProvider(create: (_) => BuildingCubit(), child: child),
              ],
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.redevelopmentDashboard,
              path: AppRoutes.redevelopmentDashboard,
              builder: (context, state) => const RedevelopmentDashboardScreen(),
            ),
            GoRoute(
              name: AppRoutes.building,
              path: AppRoutes.building,
              builder: (context, state) {
                return const BuildingScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addUpdateBuildingDoc,
              path: AppRoutes.addUpdateBuildingDoc,
              builder: (context, state) {
                final queryParameterBuilding =
                    state.uri.queryParameters['building'];

                final RedevelopmentBuildingModel? building =
                    queryParameterBuilding != null
                        ? RedevelopmentBuildingModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterBuilding),
                            ),
                          ),
                        )
                        : null;

                return AddUpdateDocumentScreen(building: building!);
              },
            ),
            GoRoute(
              name: AppRoutes.addBuilding,
              path: AppRoutes.addBuilding,
              builder: (context, state) {
                final queryParameterBuilding =
                    state.uri.queryParameters['building'];

                final RedevelopmentBuildingModel? building =
                    queryParameterBuilding != null
                        ? RedevelopmentBuildingModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterBuilding),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                final projectId = int.tryParse(
                  state.uri.queryParameters['projectId'] ?? '',
                );

                return AddBuildingScreen(
                  building: building,
                  index: index,
                  projectId: projectId,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.viewBuilding,
              path: AppRoutes.viewBuilding,
              builder: (context, state) {
                final queryParameterBuilding =
                    state.uri.queryParameters['building'];

                final RedevelopmentBuildingModel? building =
                    queryParameterBuilding != null
                        ? RedevelopmentBuildingModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterBuilding),
                            ),
                          ),
                        )
                        : null;

                return BuildingViewScreen(building: building!);
              },
            ),
            GoRoute(
              name: AppRoutes.editBuildingDetails,
              path: AppRoutes.editBuildingDetails,
              builder: (context, state) {
                // Check for both parameter names (buildingDetail and buildingDetails)
                final queryParameterBuildingDetail =
                    state.uri.queryParameters['buildingDetail'] ??
                    state.uri.queryParameters['buildingDetails'];

                if (queryParameterBuildingDetail == null) {
                  // Return error screen or navigate back
                  return Scaffold(
                    appBar: AppBar(title: const Text('Error')),
                    body: const Center(
                      child: Text('Building details not found'),
                    ),
                  );
                }

                final BuildingDetailsModel buildingDetail =
                    BuildingDetailsModel.fromJson(
                      jsonDecode(
                        EncryptionManager.decryptData(
                          Uri.decodeComponent(queryParameterBuildingDetail),
                        ),
                      ),
                    );

                return EditBuildingDetailsScreen(
                  buildingDetailsModel: buildingDetail,
                );
              },
            ),
          ],
        ),
        // TENANT
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(create: (_) => TenantCubit(), child: child);
          },
          routes: [
            GoRoute(
              name: AppRoutes.tenant,
              path: AppRoutes.tenant,
              builder: (context, state) {
                return const TenantScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addTenant,
              path: AppRoutes.addTenant,
              builder: (context, state) {
                final queryParameterTenant =
                    state.uri.queryParameters['tenant'];

                final TenantModel? tenant =
                    queryParameterTenant != null
                        ? TenantModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterTenant),
                            ),
                          ),
                        )
                        : null;
                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                final projectId =
                    int.tryParse(
                      state.uri.queryParameters['projectId'] ?? '',
                    ) ??
                    tenant?.projectId ??
                    0;
                final buildingId =
                    int.tryParse(
                      state.uri.queryParameters['buildingId'] ?? '',
                    ) ??
                    tenant?.buildingId ??
                    0;

                return AddTenantScreen(
                  tenant: tenant,
                  index: index,
                  projectId: projectId,
                  buildingId: buildingId,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.viewTenant,
              path: AppRoutes.viewTenant,
              builder: (context, state) {
                final queryParameterTenant =
                    state.uri.queryParameters['tenant'];

                final TenantModel? tenant =
                    queryParameterTenant != null
                        ? TenantModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterTenant),
                            ),
                          ),
                        )
                        : null;

                return TenantViewScreen(tenant: tenant!);
              },
            ),
            GoRoute(
              name: AppRoutes.addUpdateTenantDoc,
              path: AppRoutes.addUpdateTenantDoc,
              builder: (context, state) {
                final queryParameterTenant =
                    state.uri.queryParameters['tenant'];

                final TenantModel? tenant =
                    queryParameterTenant != null
                        ? TenantModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterTenant),
                            ),
                          ),
                        )
                        : null;

                return AddUpdateTenantDocumentScreen(tenant: tenant!);
              },
            ),
          ],
        ),
        // RENT
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(create: (_) => RentCubit(), child: child);
          },
          routes: [
            GoRoute(
              name: AppRoutes.rent,
              path: AppRoutes.rent,
              builder: (context, state) {
                return RentScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addPayment,
              path: AppRoutes.addPayment,
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>? ?? {};
                final query = state.uri.queryParameters;
                // Prefer extra (can be null with ShellRoute + pushNamed), fallback to query params (encrypted JSON)
                final buildingId =
                    extra['buildingId'] as int? ??
                    int.tryParse(query['buildingId'] ?? '') ??
                    0;
                List<RentDetailsModel> rentDetails =
                    (extra['rentDetails'] as List<RentDetailsModel>?) ?? [];
                if (rentDetails.isEmpty) {
                  rentDetails = _rentDetailsFromQuery(query['rentDetails']);
                }
                RentModel? rentModel = extra['rentModel'] as RentModel?;
                rentModel ??= _rentModelFromQuery(query['rentModel']);
                final totalAmount =
                    _readDouble(extra['totalAmount'], query['totalAmount']) ??
                    0.0;
                final paidAmount =
                    _readDouble(extra['paidAmount'], query['paidAmount']) ??
                    0.0;
                final paymentLedger =
                    extra['paymentLedger'] as PaymentLedgerModel?;
                final paymentLedgerIndex = extra['paymentLedgerIndex'] as int?;
                final isEditMode = paymentLedger != null;
                if (rentModel == null) {
                  return const Scaffold(
                    body: Center(child: Text('Missing payment context')),
                  );
                }
                if (!isEditMode && rentDetails.isEmpty) {
                  return const Scaffold(
                    body: Center(child: Text('Missing payment context')),
                  );
                }
                return AddPaymentScreen(
                  buildingId: buildingId,
                  rentDetails: rentDetails,
                  rentModel: rentModel,
                  totalAmount: totalAmount,
                  paidAmount: paidAmount,
                  paymentLedger: paymentLedger,
                  paymentLedgerIndex: paymentLedgerIndex,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.viewSummary,
              path: AppRoutes.viewSummary,
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>? ?? {};
                RentModel? rentModel = extra['rentModel'] as RentModel?;
                rentModel ??= _rentModelFromQuery(
                  state.uri.queryParameters['rentModel'],
                );
                if (rentModel == null) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Payment Summary')),
                    body: const Center(child: Text('Missing payment context')),
                  );
                }
                return ViewPaymentSummaryScreen(rentModel: rentModel);
              },
            ),
          ],
        ),
        // PROPOSED PLANS
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => ProposedPlansCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.proposedPlans,
              path: AppRoutes.proposedPlans,
              builder: (context, state) {
                return const ProposedPlansScreen();
              },
            ),
          ],
        ),
        // PROPOSED OFFER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => ProposedOfferCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.proposedOffer,
              path: AppRoutes.proposedOffer,
              builder: (context, state) {
                return const ProposedOfferScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.proposedOfferSecondaryScreen,
              path: AppRoutes.proposedOfferSecondaryScreen,
              builder: (context, state) {
                final projectId =
                    int.tryParse(
                      state.uri.queryParameters['projectId'] ?? '',
                    ) ??
                    0;
                final projectName =
                    state.uri.queryParameters['projectName'] ?? "";
                final buildingId =
                    int.tryParse(
                      state.uri.queryParameters['buildingId'] ?? '',
                    ) ??
                    0;
                final buildingName =
                    state.uri.queryParameters['buildingName'] ?? "";
                final type = state.uri.queryParameters['type'] ?? "";
                return ProposedOfferSecondaryScreen(
                  projectId: projectId,
                  projectName: projectName,
                  buildingId: buildingId,
                  buildingName: buildingName,
                  type: type,
                );
              },
            ),
          ],
        ),
        // CALENDAR
        ShellRoute(
          builder: (context, state, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => CalendarCubit(), child: child),
                BlocProvider(create: (_) => TicketCubit(), child: child),
              ],
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.calendar,
              name: AppRoutes.calendar,
              builder: (context, state) => const CalendarScreen(),
            ),
            GoRoute(
              path: AppRoutes.addDetailsCalendar,
              name: AppRoutes.addDetailsCalendar,
              builder: (context, state) => AddEventDetailsScreen(),
            ),
            GoRoute(
              path: AppRoutes.calendarDetail,
              name: AppRoutes.calendarDetail,
              builder: (context, state) {
                final payload = state.uri.queryParameters['data'];
                if (payload == null || payload.isEmpty) {
                  return CalendarDateDetailScreen(
                    date: DateTime.now(),
                    events: const [],
                  );
                }

                try {
                  final decrypted = EncryptionManager.decryptData(
                    Uri.decodeComponent(payload),
                  );
                  final data = jsonDecode(decrypted) as Map<String, dynamic>;
                  final dateString = data['date'] as String? ?? '';
                  final date = DateTime.tryParse(dateString) ?? DateTime.now();

                  final eventsJson = (data['events'] as List<dynamic>? ?? []);
                  final events = <CalendarEventModel>[];

                  for (var e in eventsJson) {
                    try {
                      final event = CalendarEventModel.fromJson(
                        Map<String, dynamic>.from(e as Map),
                      );
                      events.add(event);
                    } catch (error) {
                      log(error.toString());
                    }
                  }

                  return CalendarDateDetailScreen(date: date, events: events);
                } catch (error) {
                  return CalendarDateDetailScreen(
                    date: DateTime.now(),
                    events: const [],
                  );
                }
              },
            ),
            GoRoute(
              path: AppRoutes.ticket,
              name: AppRoutes.ticket,
              builder: (context, state) => const TicketScreen(),
            ),
            GoRoute(
              path: AppRoutes.viewTicket,
              name: AppRoutes.viewTicket,
              builder: (context, state) {
                final ticket = state.extra as TicketModel?;
                final ticketId =
                    int.tryParse(
                      state.uri.queryParameters["ticketId"] ?? "0",
                    ) ??
                    0;
                final queryParameterSystemGeneratedCode =
                    state.uri.queryParameters['systemGeneratedCode'];
                final systemGeneratedCode =
                    queryParameterSystemGeneratedCode != null &&
                            queryParameterSystemGeneratedCode.isNotEmpty
                        ? EncryptionManager.decryptData(
                          Uri.decodeComponent(
                            queryParameterSystemGeneratedCode,
                          ),
                        )
                        : "";
                return TicketViewScreen(
                  ticket: ticket,
                  ticketId: ticketId,
                  systemGeneratedCode: systemGeneratedCode,
                );
              },
            ),
            GoRoute(
              path: AppRoutes.assignTicket,
              name: AppRoutes.assignTicket,
              builder: (context, state) {
                final ticket = state.extra as TicketModel?;
                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AssignTicketMaster(ticket: ticket, index: index);
              },
            ),
            GoRoute(
              path: AppRoutes.addTicket,
              name: AppRoutes.addTicket,
              builder: (context, state) {
                final ticket = state.extra as TicketModel?;
                return AddTicketScreen(ticket: ticket);
              },
            ),
          ],
        ),
        // TASK TRANSFER
        GoRoute(
          path: AppRoutes.taskTransferHistory,
          name: AppRoutes.taskTransferHistory,
          builder: (context, state) {
            return TaskTransferHistoryScreen();
          },
        ),
        // MENU
        GoRoute(
          path: AppRoutes.menu,
          name: AppRoutes.menu,
          builder: (context, state) {
            return const MenuScreen();
          },
        ),
        // PROFILE
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(create: (_) => ProfileCubit(), child: child);
          },
          routes: [
            GoRoute(
              name: AppRoutes.profile,
              path: AppRoutes.profile,
              builder: (context, state) {
                return ProfileScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.updateUserBasicDetails,
              path: AppRoutes.updateUserBasicDetails,
              builder: (context, state) {
                final queryParameterEnquiry =
                    state.uri.queryParameters['updateUserBasicDetails'];
                final updateUserBasicDetails =
                    queryParameterEnquiry != null &&
                            queryParameterEnquiry.isNotEmpty
                        ? UserModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterEnquiry),
                            ),
                          ),
                        )
                        : null;

                return UpdateUserDetailsScreen(
                  userData: updateUserBasicDetails,
                );
              },
            ),
          ],
        ),
        // NOTIFICATION
        GoRoute(
          path: AppRoutes.notificationScreenMobile,
          name: AppRoutes.notificationScreenMobile,
          builder: (context, state) {
            return BlocProvider(
              create: (context) => NotificationCubit(),
              child: NotificationScreen(),
            );
          },
        ),
        // MARKETING CONTENT DOCUMENT
        ShellRoute(
          builder: (context, state, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<ContentFolderCubit>(
                  create: (_) => ContentFolderCubit(),
                ),
                BlocProvider<ContentDocumentCubit>(
                  create: (_) => ContentDocumentCubit(),
                ),
              ],
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.content,
              name: AppRoutes.content,
              builder: (context, state) => ContentFolderScreen(),
            ),
            GoRoute(
              name: AppRoutes.contentDocument,
              path: AppRoutes.contentDocument,
              builder: (context, state) {
                final queryParameterMarketingContentFolderId =
                    state.uri.queryParameters['marketingContentFolderId'];

                if (queryParameterMarketingContentFolderId != null) {
                  final decodedJson = jsonDecode(
                    EncryptionManager.decryptData(
                      Uri.decodeQueryComponent(
                        queryParameterMarketingContentFolderId,
                      ),
                    ),
                  );

                  return BlocProvider(
                    create: (_) => ContentDocumentCubit(),
                    child: ContentDocumentScreen(
                      marketingContentFolderId: decodedJson,
                    ),
                  );
                }
                return TestScreen();
              },
            ),
          ],
        ),
        // PROJECT MANAGEMENT APPROVED BANK
        ShellRoute(
          builder: (context, state, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<ApprovedBankFolderCubit>(
                  create: (_) => ApprovedBankFolderCubit(),
                ),
                BlocProvider<ApprovedBankFileCubit>(
                  create: (_) => ApprovedBankFileCubit(),
                ),
              ],
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.approvedBank,
              name: AppRoutes.approvedBank,
              builder: (context, state) {
                return ApprovedBankFolderScreen();
              },
            ),
            GoRoute(
              path: AppRoutes.addBankScreen,
              name: AppRoutes.addBankScreen,
              builder: (context, state) {
                return AddBankScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.approvedBankFile,
              path: AppRoutes.approvedBankFile,
              builder: (context, state) {
                final queryParameter =
                    state.uri.queryParameters['approvedBankFolderId'];
                if (queryParameter == null) {
                  return TestScreen();
                }

                final decodedJsonApprovedBankFolderId = jsonDecode(
                  EncryptionManager.decryptData(
                    Uri.decodeQueryComponent(queryParameter),
                  ),
                );
                return ApprovedBankFieScreen(
                  approvedBankFolderId: decodedJsonApprovedBankFolderId,
                );
              },
            ),
          ],
        ),
        // VENDOR
        ShellRoute(
          builder: (context, state, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<VendorCubit>(create: (_) => VendorCubit()),
                BlocProvider<VendorAddCubit>(create: (_) => VendorAddCubit()),
              ],
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.vendor,
              name: AppRoutes.vendor,
              builder: (context, state) {
                return const VendorScreen();
              },
            ),
            // ---------------- ADD / EDIT VENDOR ----------------
            GoRoute(
              name: AppRoutes.addVendor,
              path: AppRoutes.addVendor,
              builder: (context, state) {
                final queryParameterVendor =
                    state.uri.queryParameters['vendor'];

                final VendorModel? vendor =
                    queryParameterVendor != null
                        ? VendorModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterVendor),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return BlocProvider(
                  create: (_) => VendorAddCubit(),
                  child: AddVendorScreen(vendor: vendor, index: index),
                );
              },
            ),
            // ---------------- VIEW DETAILS ----------------
            GoRoute(
              path: AppRoutes.viewVendorDetails,
              name: AppRoutes.viewVendorDetails,
              builder: (context, state) {
                final queryParameterVendor =
                    state.uri.queryParameters['vendor'];

                final vendor = VendorModel.fromJson(
                  jsonDecode(
                    EncryptionManager.decryptData(
                      Uri.decodeComponent(queryParameterVendor!),
                    ),
                  ),
                );

                return ViewDetailsVendorScreen(vendor: vendor);
              },
            ),
            // ---------------- VIEW DOCUMENTS ----------------
            GoRoute(
              path: AppRoutes.viewVendorDocument,
              name: AppRoutes.viewVendorDocument,
              builder: (context, state) {
                final queryParameterVendor =
                    state.uri.queryParameters['vendor'];

                final vendor = VendorModel.fromJson(
                  jsonDecode(
                    EncryptionManager.decryptData(
                      Uri.decodeComponent(queryParameterVendor!),
                    ),
                  ),
                );

                return DocumentsViewVendorScreen(vendorModel: vendor);
              },
            ),
          ],
        ),
        // INVENTORY
        ShellRoute(
          builder: (context, state, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => InventoryCubit()),
                BlocProvider<InventoryReportCubit>(
                  create: (_) => InventoryReportCubit(),
                ),
                BlocProvider(create: (_) => ParkingCubit()),
              ],
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.inventoryDashboard,
              path: AppRoutes.inventoryDashboard,
              builder: (context, state) {
                return const InventoryDashboard();
              },
            ),
            GoRoute(
              name: AppRoutes.unitDistributionStatus,
              path: AppRoutes.unitDistributionStatus,
              builder: (context, state) {
                final queryParamsData =
                    state.uri.queryParameters['queryParams'];

                Map<String, dynamic> queryParams = {};
                if (queryParamsData != null) {
                  queryParams = Map<String, dynamic>.from(
                    jsonDecode(
                      EncryptionManager.decryptData(
                        Uri.decodeQueryComponent(queryParamsData),
                      ),
                    ),
                  );
                }
                final type =
                    state.uri.queryParameters['type'] != null
                        ? EncryptionManager.decryptData(
                          Uri.decodeQueryComponent(
                            state.uri.queryParameters['type']!,
                          ),
                        )
                        : '';
                final title =
                    state.uri.queryParameters['title'] != null
                        ? EncryptionManager.decryptData(
                          Uri.decodeQueryComponent(
                            state.uri.queryParameters['title']!,
                          ),
                        )
                        : '';
                final subTitle =
                    state.uri.queryParameters['subTitle'] != null
                        ? EncryptionManager.decryptData(
                          Uri.decodeQueryComponent(
                            state.uri.queryParameters['subTitle']!,
                          ),
                        )
                        : null;
                final projectId =
                    int.tryParse(
                      state.uri.queryParameters['projectId'] ?? '0',
                    ) ??
                    0;

                return UnitDistributionStatusScreen(
                  type: type,
                  title: title,
                  subTitle: subTitle,
                  queryParams: queryParams,
                  projectId: projectId,
                );
              },
            ),

            GoRoute(
              name: AppRoutes.inventory,
              path: AppRoutes.inventory,
              builder: (context, state) {
                return const InventoryScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addInventorySpecification,
              path: AppRoutes.addInventorySpecification,
              builder: (context, state) {
                final queryParameterFlatModel =
                    state.uri.queryParameters['flatModel'];
                final queryParameterFloorModel =
                    state.uri.queryParameters['floorModel'];
                final queryParameterApproval =
                    state.uri.queryParameters['approval'];

                FlatModel? flat;
                FloorModel? floor;

                if (queryParameterFlatModel != null) {
                  final flatJson = jsonDecode(
                    EncryptionManager.decryptData(
                      Uri.decodeQueryComponent(queryParameterFlatModel),
                    ),
                  );
                  flat = FlatModel.fromJson(flatJson);
                }

                if (queryParameterFloorModel != null) {
                  final floorJson = jsonDecode(
                    EncryptionManager.decryptData(
                      Uri.decodeQueryComponent(queryParameterFloorModel),
                    ),
                  );
                  floor = FloorModel.fromJson(floorJson);
                }
                final approval =
                    queryParameterApproval != null
                        ? EncryptionManager.decryptData(
                          Uri.decodeQueryComponent(queryParameterApproval),
                        )
                        : null;

                return AddInventorySpecificationScreen(
                  flatModel: flat,
                  floorModel: floor,
                  approval: approval,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.addUnitSpecification,
              path: AppRoutes.addUnitSpecification,
              builder: (context, state) {
                final queryParameterUnitSpec =
                    state.uri.queryParameters['unitSpecificationModel'];
                final queryParameterFlatId = int.tryParse(
                  state.uri.queryParameters['inventoryFlatId'] ?? '',
                );
                final queryParameterBuildingId = int.tryParse(
                  state.uri.queryParameters['inventoryBuildingId'] ?? '',
                );
                final queryParameterWingId = int.tryParse(
                  state
                          .uri
                          .queryParameters['inventoryFlatFloorBasementPodiumWingId'] ??
                      '',
                );
                final queryParameterFloorId = int.tryParse(
                  state.uri.queryParameters['inventoryFloorId'] ?? '',
                );

                FlatSpecificationModel? unitSpec;
                if (queryParameterUnitSpec != null) {
                  final unitSpecJson = jsonDecode(
                    EncryptionManager.decryptData(
                      Uri.decodeQueryComponent(queryParameterUnitSpec),
                    ),
                  );
                  unitSpec = FlatSpecificationModel.fromJson(unitSpecJson);
                }

                return AddUnitSpecificationScreen(
                  unitSpecificationModel: unitSpec,
                  inventoryFlatId: queryParameterFlatId,
                  inventoryBuildingId: queryParameterBuildingId,
                  inventoryFlatFloorBasementPodiumWingId: queryParameterWingId,
                  inventoryFloorId: queryParameterFloorId,
                  onSave: (savedSpec) {
                    // Return the saved spec via pop
                    goRouter.pop(savedSpec);
                  },
                );
              },
            ),
            GoRoute(
              name: AppRoutes.viewUnitSpecification,
              path: AppRoutes.viewUnitSpecification,
              builder: (context, state) {
                final queryParameterFlatModel =
                    state.uri.queryParameters['flatModel'];

                FlatModel? flatModel;
                if (queryParameterFlatModel != null) {
                  final faltJson = jsonDecode(
                    EncryptionManager.decryptData(
                      Uri.decodeQueryComponent(queryParameterFlatModel),
                    ),
                  );
                  flatModel = FlatModel.fromJson(faltJson);
                }

                return UnitSpecificationViewScreen(flatModel: flatModel!);
              },
            ),
            GoRoute(
              name: AppRoutes.inventoryParkingOverallReport,
              path: AppRoutes.inventoryParkingOverallReport,
              builder: (context, state) {
                return InventoryOverallReport();
              },
            ),
            GoRoute(
              name: AppRoutes.inventoryParkingOverallReportOverview,
              path: AppRoutes.inventoryParkingOverallReportOverview,
              builder: (context, state) {
                final projectId =
                    int.tryParse(
                      EncryptionManager.decryptData(
                        state.uri.queryParameters['projectId'] ?? '',
                      ),
                    ) ??
                    0;

                return InventoryOverallReportOverview(projectId: projectId);
              },
            ),
          ],
        ),
        // PARKING
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(create: (_) => ParkingCubit(), child: child);
          },
          routes: [
            GoRoute(
              name: AppRoutes.parking,
              path: AppRoutes.parking,
              builder: (context, state) {
                return const ParkingScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.editParking,
              path: AppRoutes.editParking,
              builder: (context, state) {
                final queryParameterParkingModel =
                    state.uri.queryParameters['parking'];

                ParkingModel? parking;

                if (queryParameterParkingModel != null) {
                  final parkingJson = jsonDecode(
                    EncryptionManager.decryptData(
                      Uri.decodeQueryComponent(queryParameterParkingModel),
                    ),
                  );
                  parking = ParkingModel.fromJson(parkingJson);
                }

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return EditParkingScreen(parking: parking!, index: index);
              },
            ),
          ],
        ),
        // CHANNEL PARTNER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => ChannelPartnerCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.channelPartnerDashboard,
              path: AppRoutes.channelPartnerDashboard,
              builder: (context, state) {
                return const ChannelPartnerDashboardScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.channelPartner,
              path: AppRoutes.channelPartner,
              builder: (context, state) {
                return const ChannelPartnerScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addChannelPartner,
              path: AppRoutes.addChannelPartner,
              builder: (context, state) {
                final queryParameterChannelPartner =
                    state.uri.queryParameters['channelPartner'];

                final ChannelPartnerModel? channelPartner =
                    queryParameterChannelPartner != null
                        ? ChannelPartnerModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterChannelPartner),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return BlocProvider(
                  create: (_) => VendorAddCubit(),
                  child: AddChannelPartnerScreen(
                    channelPartnerModel: channelPartner,
                    index: index,
                  ),
                );
              },
            ),
            GoRoute(
              name: AppRoutes.channelPartnerView,
              path: AppRoutes.channelPartnerView,
              builder: (context, state) {
                final queryParameterChannelPartner =
                    state.uri.queryParameters['channelPartner'];

                final ChannelPartnerModel? channelPartner =
                    queryParameterChannelPartner != null
                        ? ChannelPartnerModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterChannelPartner),
                            ),
                          ),
                        )
                        : null;

                return ChannelPartnerViewScreen(
                  channelPartnerModel: channelPartner!,
                );
              },
            ),
            GoRoute(
              path: AppRoutes.cpUniverse,
              name: AppRoutes.cpUniverse,
              builder: (context, state) {
                return const CpUniverseScreen();
              },
            ),
          ],
        ),
        // DOCUMENT
        ShellRoute(
          builder: (context, state, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<DocumentCubit>(create: (_) => DocumentCubit()),
                BlocProvider<DocumentCategoryCubit>(
                  create: (_) => DocumentCategoryCubit(),
                ),
                BlocProvider<RERADocumentCategoryCubit>(
                  create: (_) => RERADocumentCategoryCubit(),
                ),
                BlocProvider<RERADocumentCubit>(
                  create: (_) => RERADocumentCubit(),
                ),
                BlocProvider<ApprovalDocumentCubit>(
                  create: (_) => ApprovalDocumentCubit(),
                ),
                BlocProvider<ApprovalCategoryCubit>(
                  create: (_) => ApprovalCategoryCubit(),
                ),
              ],
              child: child,
            );
          },
          routes: [
            //Project Document
            ShellRoute(
              builder: (context, state, child) {
                return BlocProvider<DocumentCubit>.value(
                  value: context.read<DocumentCubit>(),
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  name: AppRoutes.document,
                  path: AppRoutes.document,
                  builder: (context, state) {
                    return const DocumentScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.addDocument,
                  path: AppRoutes.addDocument,
                  builder: (context, state) {
                    final queryParameterDocument =
                        state.uri.queryParameters['document'];

                    final DocumentModel? document =
                        queryParameterDocument != null
                            ? DocumentModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterDocument),
                                ),
                              ),
                            )
                            : null;

                    final index =
                        int.tryParse(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(
                              state.uri.queryParameters['index'] ?? '0',
                            ),
                          ),
                        ) ??
                        0;

                    final isEdit = bool.parse(
                      EncryptionManager.decryptData(
                        Uri.decodeComponent(
                          state.uri.queryParameters['isEdit'] ?? 'false',
                        ),
                      ),
                    );
                    return AddDocumentScreen(
                      documentModel: document,
                      index: index,
                      isEdit: isEdit,
                    );
                  },
                ),
                GoRoute(
                  name: AppRoutes.viewDocument,
                  path: AppRoutes.viewDocument,
                  builder: (context, state) {
                    final queryParameterDocument =
                        state.uri.queryParameters['document'];
                    final DocumentModel? document =
                        queryParameterDocument != null
                            ? DocumentModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterDocument),
                                ),
                              ),
                            )
                            : null;

                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;
                    return ViewDocumentScreen(
                      documentModel: document!,
                      index: index,
                    );
                  },
                ),
              ],
            ),

            //Project Document Category
            ShellRoute(
              builder: (context, state, child) {
                return BlocProvider<DocumentCategoryCubit>.value(
                  value: context.read<DocumentCategoryCubit>(),
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  name: AppRoutes.category,
                  path: AppRoutes.category,
                  builder: (context, state) {
                    return const DocumentCategoryScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.addDocumentCategory,
                  path: AppRoutes.addDocumentCategory,
                  builder: (context, state) {
                    final queryParameterDocumentCategory =
                        state.uri.queryParameters['documentCategory'];

                    final DocumentCategoryModel? documentCategory =
                        queryParameterDocumentCategory != null
                            ? DocumentCategoryModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(
                                    queryParameterDocumentCategory,
                                  ),
                                ),
                              ),
                            )
                            : null;

                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;
                    return AddDocumentCategoryScreen(
                      documentCategoryModel: documentCategory,
                      index: index,
                    );
                  },
                ),
                GoRoute(
                  name: AppRoutes.viewDocumentCategory,
                  path: AppRoutes.viewDocumentCategory,
                  builder: (context, state) {
                    final queryParameterDocumentCategory =
                        state.uri.queryParameters['documentCategory'];

                    final DocumentCategoryModel? documentCategory =
                        queryParameterDocumentCategory != null
                            ? DocumentCategoryModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(
                                    queryParameterDocumentCategory,
                                  ),
                                ),
                              ),
                            )
                            : null;

                    return ViewDocumentCategoryScreen(
                      documentCategoryModel: documentCategory!,
                    );
                  },
                ),
              ],
            ),

            // Rera Document
            ShellRoute(
              builder: (context, state, child) {
                return BlocProvider<RERADocumentCubit>.value(
                  value: context.read<RERADocumentCubit>(),
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  name: AppRoutes.rera,
                  path: AppRoutes.rera,
                  builder: (context, state) {
                    return const RERADocumentScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.addReraDocument,
                  path: AppRoutes.addReraDocument,
                  builder: (context, state) {
                    final queryParameterDocument =
                        state.uri.queryParameters['reraDocument'];

                    final RERADocumentModel? document =
                        queryParameterDocument != null
                            ? RERADocumentModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterDocument),
                                ),
                              ),
                            )
                            : null;

                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;

                    final isEdit = bool.parse(
                      EncryptionManager.decryptData(
                        Uri.decodeComponent(
                          state.uri.queryParameters['isEdit'] ?? 'false',
                        ),
                      ),
                    );
                    return AddRERADocumentScreen(
                      documentModel: document,
                      index: index,
                      isEdit: isEdit,
                    );
                  },
                ),
                GoRoute(
                  name: AppRoutes.viewReraDocument,
                  path: AppRoutes.viewReraDocument,
                  builder: (context, state) {
                    final queryParameterDocument =
                        state.uri.queryParameters['reraDocument'];
                    final RERADocumentModel? document =
                        queryParameterDocument != null
                            ? RERADocumentModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterDocument),
                                ),
                              ),
                            )
                            : null;

                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;
                    return ViewRERADocumentScreen(
                      documentModel: document!,
                      index: index,
                    );
                  },
                ),
              ],
            ),

            //Project RERA Document Category
            ShellRoute(
              builder: (context, state, child) {
                return BlocProvider<RERADocumentCategoryCubit>.value(
                  value: context.read<RERADocumentCategoryCubit>(),
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  name: AppRoutes.reraCategory,
                  path: AppRoutes.reraCategory,
                  builder: (context, state) {
                    return const RERADocumentCategoryScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.addReraDocumentCategory,
                  path: AppRoutes.addReraDocumentCategory,
                  builder: (context, state) {
                    final queryParameterRERADocumentCategory =
                        state.uri.queryParameters['reraDocumentCategory'];

                    final RERADocumentCategoryModel? reraDocumentCategory =
                        queryParameterRERADocumentCategory != null
                            ? RERADocumentCategoryModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(
                                    queryParameterRERADocumentCategory,
                                  ),
                                ),
                              ),
                            )
                            : null;

                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;
                    return AddRERADocumentCategoryScreen(
                      reraDocumentCategoryModel: reraDocumentCategory,
                      index: index,
                    );
                  },
                ),
                GoRoute(
                  name: AppRoutes.viewReraDocumentCategory,
                  path: AppRoutes.viewReraDocumentCategory,
                  builder: (context, state) {
                    final queryParameterRERADocumentCategory =
                        state.uri.queryParameters['reraDocumentCategory'];

                    final RERADocumentCategoryModel? reraDocumentCategory =
                        queryParameterRERADocumentCategory != null
                            ? RERADocumentCategoryModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(
                                    queryParameterRERADocumentCategory,
                                  ),
                                ),
                              ),
                            )
                            : null;
                    return ViewRERADocumentCategoryScreen(
                      reraDocumentCategoryModel: reraDocumentCategory!,
                    );
                  },
                ),
              ],
            ),

            //Project Approval Document Category
            ShellRoute(
              builder: (context, state, child) {
                return BlocProvider<ApprovalCategoryCubit>.value(
                  value: context.read<ApprovalCategoryCubit>(),
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  name: AppRoutes.approvalCategory,
                  path: AppRoutes.approvalCategory,
                  builder: (context, state) {
                    return const ApprovalCategoryScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.addApprovalCategory,
                  path: AppRoutes.addApprovalCategory,
                  builder: (context, state) {
                    final queryParameterApprovalDocumentCategory =
                        state.uri.queryParameters['approvalCategory'];

                    final ApprovalDocumentCategoryModel?
                    approvalDocumentCategory =
                        queryParameterApprovalDocumentCategory != null
                            ? ApprovalDocumentCategoryModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(
                                    queryParameterApprovalDocumentCategory,
                                  ),
                                ),
                              ),
                            )
                            : null;

                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;
                    return AddApprovalCategoryScreen(
                      approvalCategoryModel: approvalDocumentCategory,
                      index: index,
                    );
                  },
                ),
                GoRoute(
                  name: AppRoutes.viewApprovalCategory,
                  path: AppRoutes.viewApprovalCategory,
                  builder: (context, state) {
                    final queryParameterApprovalDocumentCategory =
                        state.uri.queryParameters['approvalCategory'];

                    final ApprovalDocumentCategoryModel?
                    approvalDocumentCategory =
                        queryParameterApprovalDocumentCategory != null
                            ? ApprovalDocumentCategoryModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(
                                    queryParameterApprovalDocumentCategory,
                                  ),
                                ),
                              ),
                            )
                            : null;
                    return ViewApprovalCategoryScreen(
                      approvalCategoryModel: approvalDocumentCategory!,
                    );
                  },
                ),
              ],
            ),
            //Approval Document
            ShellRoute(
              builder: (context, state, child) {
                return BlocProvider<ApprovalDocumentCubit>.value(
                  value: context.read<ApprovalDocumentCubit>(),
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  name: AppRoutes.approvalDocument,
                  path: AppRoutes.approvalDocument,
                  builder: (context, state) {
                    return const ApprovalDocumentScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.addApprovalDocument,
                  path: AppRoutes.addApprovalDocument,
                  builder: (context, state) {
                    final queryParameterApprovalDocument =
                        state.uri.queryParameters['approvalDocument'];

                    final ApprovalDocumentModel? document =
                        queryParameterApprovalDocument != null
                            ? ApprovalDocumentModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(
                                    queryParameterApprovalDocument,
                                  ),
                                ),
                              ),
                            )
                            : null;
                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;

                    final isEdit = bool.parse(
                      EncryptionManager.decryptData(
                        Uri.decodeComponent(
                          state.uri.queryParameters['isEdit'] ?? 'false',
                        ),
                      ),
                    );
                    return AddApprovalDocumentScreen(
                      documentModel: document,
                      index: index,
                      isEdit: isEdit,
                    );
                  },
                ),
                GoRoute(
                  name: AppRoutes.viewApprovalDocument,
                  path: AppRoutes.viewApprovalDocument,
                  builder: (context, state) {
                    final queryParameterApprovalDocument =
                        state.uri.queryParameters['approvalDocument'];

                    final ApprovalDocumentModel? document =
                        queryParameterApprovalDocument != null
                            ? ApprovalDocumentModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(
                                    queryParameterApprovalDocument,
                                  ),
                                ),
                              ),
                            )
                            : null;

                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;
                    return ViewApprovalDocumentScreen(
                      documentModel: document!,
                      index: index,
                    );
                  },
                ),
              ],
            ),
            //LEGAL (LITIGATION)
            ShellRoute(
              builder: (context, state, child) {
                return MultiBlocProvider(
                  providers: [
                    BlocProvider<LitigationDashboardCubit>(
                      create: (_) => LitigationDashboardCubit(),
                    ),
                    BlocProvider<LitigationCubit>(
                      create: (_) => LitigationCubit(),
                    ),
                  ],
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  name: AppRoutes.litigationDashboard,
                  path: AppRoutes.litigationDashboard,
                  builder: (context, state) {
                    return const LitigationDashboardScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.litigation,
                  path: AppRoutes.litigation,
                  builder: (context, state) {
                    return const LitigationScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.viewLitigation,
                  path: AppRoutes.viewLitigation,
                  builder: (context, state) {
                    final queryParameterLitigation =
                        state.uri.queryParameters['litigation'];

                    final LitigationModel? litigation =
                        queryParameterLitigation != null
                            ? LitigationModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterLitigation),
                                ),
                              ),
                            )
                            : null;
                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;
                    return LitigationViewScreen(
                      litigationModel: litigation!,
                      index: index,
                    );
                  },
                ),
                GoRoute(
                  name: AppRoutes.addLitigation,
                  path: AppRoutes.addLitigation,
                  builder: (context, state) {
                    final queryParameterLitigation =
                        state.uri.queryParameters['litigation'];

                    final LitigationModel? litigation =
                        queryParameterLitigation != null
                            ? LitigationModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterLitigation),
                                ),
                              ),
                            )
                            : null;
                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;
                    return AddLitigationScreen(
                      litigationModel: litigation,
                      index: index,
                    );
                  },
                ),
                GoRoute(
                  name: AppRoutes.addLitigationHearing,
                  path: AppRoutes.addLitigationHearing,
                  builder: (context, state) {
                    final queryParameterLitigationHearing =
                        state.uri.queryParameters['litigationHearing'];
                    final queryParameterLitigation =
                        state.uri.queryParameters['litigation'];

                    final LitigationModel? litigation =
                        queryParameterLitigation != null
                            ? LitigationModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterLitigation),
                                ),
                              ),
                            )
                            : null;

                    final LitigationHearingModel? litigationHearing =
                        queryParameterLitigationHearing != null
                            ? LitigationHearingModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(
                                    queryParameterLitigationHearing,
                                  ),
                                ),
                              ),
                            )
                            : null;
                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;
                    return AddLitigationHearingScreen(
                      litigationHearingModel: litigationHearing,
                      index: index,
                      litigationModel: litigation!,
                    );
                  },
                ),
              ],
            ),
            // PAYROLL DASHBOARD CUBIT
            ShellRoute(
              builder: (context, state, child) {
                return BlocProvider(
                  create: (_) => PayrollDashboardCubit(),
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  name: AppRoutes.payrollDashboard,
                  path: AppRoutes.payrollDashboard,
                  builder: (context, state) {
                    return const PayrollDashboardScreen();
                  },
                ),
              ],
            ),
            // OUTDOOR
            ShellRoute(
              builder: (context, state, child) {
                return BlocProvider(
                  create: (_) => OutdoorCubit(),
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  name: AppRoutes.outdoor,
                  path: AppRoutes.outdoor,
                  builder: (context, state) {
                    return OutdoorScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.viewOutdoor,
                  path: AppRoutes.viewOutdoor,
                  builder: (context, state) {
                    final queryParameterOutdoor =
                        state.uri.queryParameters['outdoor'];
                    final OutdoorModel? outdoor =
                        queryParameterOutdoor != null
                            ? OutdoorModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterOutdoor),
                                ),
                              ),
                            )
                            : null;
                    return OutdoorViewScreen(outdoorModel: outdoor!);
                  },
                ),
                GoRoute(
                  name: AppRoutes.addOutdoor,
                  path: AppRoutes.addOutdoor,
                  builder: (context, state) {
                    final queryParameterOutdoor =
                        state.uri.queryParameters['outdoor'];

                    final OutdoorModel? outdoor =
                        queryParameterOutdoor != null
                            ? OutdoorModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterOutdoor),
                                ),
                              ),
                            )
                            : null;

                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;
                    return AddOutdoorScreen(
                      outdoorModel: outdoor,
                      index: index,
                    );
                  },
                ),
              ],
            ),
            // LEAVE
            ShellRoute(
              builder: (context, state, child) {
                return BlocProvider(create: (_) => LeaveCubit(), child: child);
              },
              routes: [
                GoRoute(
                  name: AppRoutes.leave,
                  path: AppRoutes.leave,
                  builder: (context, state) {
                    return LeaveScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.viewLeave,
                  path: AppRoutes.viewLeave,
                  builder: (context, state) {
                    final queryParameterLeave =
                        state.uri.queryParameters['leave'];
                    final LeaveModel? leave =
                        queryParameterLeave != null
                            ? LeaveModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterLeave),
                                ),
                              ),
                            )
                            : null;
                    return LeaveViewScreen(leaveModel: leave!);
                  },
                ),
                GoRoute(
                  name: AppRoutes.applyLeave,
                  path: AppRoutes.applyLeave,
                  builder: (context, state) {
                    final queryParameterLeave =
                        state.uri.queryParameters['leave'];

                    final LeaveModel? leave =
                        queryParameterLeave != null
                            ? LeaveModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterLeave),
                                ),
                              ),
                            )
                            : null;

                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;
                    return ApplyLeaveScreen(leaveModel: leave, index: index);
                  },
                ),
              ],
            ),
            // COMP OFF
            ShellRoute(
              builder: (context, state, child) {
                return BlocProvider(
                  create: (_) => CompOffCubit(),
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  name: AppRoutes.compOff,
                  path: AppRoutes.compOff,
                  builder: (context, state) {
                    return CompOffScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.viewCompOff,
                  path: AppRoutes.viewCompOff,
                  builder: (context, state) {
                    final queryParameterCompOff =
                        state.uri.queryParameters['compOff'];
                    final CompOffModel? compOff =
                        queryParameterCompOff != null
                            ? CompOffModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterCompOff),
                                ),
                              ),
                            )
                            : null;
                    return CompOffViewScreen(compOffModel: compOff!);
                  },
                ),
                GoRoute(
                  name: AppRoutes.addCompOff,
                  path: AppRoutes.addCompOff,
                  builder: (context, state) {
                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;
                    final queryParameterCompOff =
                        state.uri.queryParameters['compOff'];
                    final compOff =
                        queryParameterCompOff != null &&
                                queryParameterCompOff.isNotEmpty
                            ? CompOffModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterCompOff),
                                ),
                              ),
                            )
                            : null;

                    return AddCompOffScreen(
                      compOffModel: compOff,
                      index: index,
                    );
                  },
                ),
              ],
            ),
            // CALL TRACKER
            ShellRoute(
              builder: (context, state, child) {
                return BlocProvider(
                  create: (_) => CallTrackerCubit(),
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  name: AppRoutes.callTracker,
                  path: AppRoutes.callTracker,
                  builder: (context, state) {
                    return CallTrackerScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.updateCallTracker,
                  path: AppRoutes.updateCallTracker,
                  builder: (context, state) {
                    final queryParameterCallLog =
                        state.uri.queryParameters['callLog'];
                    final callLog =
                        queryParameterCallLog != null &&
                                queryParameterCallLog.isNotEmpty
                            ? CallLogModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterCallLog),
                                ),
                              ),
                            )
                            : null;

                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;

                    return UpdateCallLogScreen(
                      callLogModel: callLog!,
                      index: index,
                    );
                  },
                ),
                GoRoute(
                  name: AppRoutes.addCallingData,
                  path: AppRoutes.addCallingData,
                  builder: (context, state) {
                    final queryParameterCallLog =
                        state.uri.queryParameters['callingData'];
                    final callingData =
                        queryParameterCallLog != null &&
                                queryParameterCallLog.isNotEmpty
                            ? CallingDataModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterCallLog),
                                ),
                              ),
                            )
                            : null;

                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;

                    return AddCallingDataScreen(
                      callingDataModel: callingData,
                      index: index,
                    );
                  },
                ),
              ],
            ),

            // SALES REPORT
            ShellRoute(
              builder: (context, state, child) {
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => PerformanceCubit()),
                    BlocProvider(create: (_) => AchievementCubit()),
                  ],
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  name: AppRoutes.performanceReport,
                  path: AppRoutes.performanceReport,
                  builder: (context, state) {
                    return const PerformanceScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.viewPerformanceReport,
                  path: AppRoutes.viewPerformanceReport,
                  builder: (context, state) {
                    final sourcingParam = state.uri.queryParameters['sourcing'];
                    final closingParam = state.uri.queryParameters['closing'];

                    PerformanceReportSourcingModel? sourcing;
                    PerformanceReportClosingModel? closing;

                    if (sourcingParam != null && sourcingParam.isNotEmpty) {
                      sourcing = PerformanceReportSourcingModel.fromJson(
                        jsonDecode(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(sourcingParam),
                          ),
                        ),
                      );
                    }

                    if (closingParam != null && closingParam.isNotEmpty) {
                      closing = PerformanceReportClosingModel.fromJson(
                        jsonDecode(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(closingParam),
                          ),
                        ),
                      );
                    }

                    return ViewPerformanceScreen(
                      sourcing: sourcing,
                      closing: closing,
                    );
                  },
                ),
                GoRoute(
                  name: AppRoutes.achievementReport,
                  path: AppRoutes.achievementReport,
                  builder: (context, state) {
                    return const AchievementScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.managerAchievementReport,
                  path: AppRoutes.managerAchievementReport,
                  builder: (context, state) {
                    final type = state.uri.queryParameters['type'] ?? '';
                    final filterType =
                        state.uri.queryParameters['filterType'] ?? '';
                    final fromDate =
                        state.uri.queryParameters['fromDate'] ?? '';
                    final toDate = state.uri.queryParameters['toDate'] ?? '';
                    final parseFromDate =
                        fromDate.isNotEmpty
                            ? DateTime.parse(
                              EncryptionManager.decryptData(
                                Uri.decodeComponent(fromDate),
                              ),
                            )
                            : null;
                    final parseToDate =
                        toDate.isNotEmpty
                            ? DateTime.parse(
                              EncryptionManager.decryptData(
                                Uri.decodeComponent(toDate),
                              ),
                            )
                            : null;
                    final projectParam =
                        state.uri.queryParameters['projectAchievement'];

                    ProjectAchievementReportModel? projectAchievement;

                    if (projectParam != null && projectParam.isNotEmpty) {
                      projectAchievement =
                          ProjectAchievementReportModel.fromJson(
                            jsonDecode(
                              EncryptionManager.decryptData(
                                Uri.decodeComponent(projectParam),
                              ),
                            ),
                          );
                    }

                    return ManagerAchievementReport(
                      type: type,
                      filterType: filterType,
                      fromDate: parseFromDate,
                      toDate: parseToDate,
                      projectAchievementReportModel: projectAchievement!,
                    );
                  },
                ),
              ],
            ),
            // SALES TARGET
            ShellRoute(
              builder: (context, state, child) {
                return BlocProvider(create: (_) => TargetCubit(), child: child);
              },
              routes: [
                GoRoute(
                  name: AppRoutes.salesTarget,
                  path: AppRoutes.salesTarget,
                  builder: (context, state) {
                    return const TargetScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.viewTarget,
                  path: AppRoutes.viewTarget,
                  builder: (context, state) {
                    final queryParameterSourcing =
                        state.uri.queryParameters['sourcing'];
                    final queryParameterClosing =
                        state.uri.queryParameters['closing'];
                    final sourcingTarget =
                        queryParameterSourcing != null &&
                                queryParameterSourcing.isNotEmpty
                            ? SalesTargetSourcingModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterSourcing),
                                ),
                              ),
                            )
                            : null;
                    final closingTarget =
                        queryParameterClosing != null &&
                                queryParameterClosing.isNotEmpty
                            ? SaleTargetClosingModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterClosing),
                                ),
                              ),
                            )
                            : null;

                    return TargetViewScreen(
                      sourcing: sourcingTarget,
                      closing: closingTarget,
                    );
                  },
                ),
              ],
            ),

            // SALES BOOKING
            ShellRoute(
              builder: (context, state, child) {
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => SalesDashboardCubit()),
                    BlocProvider(create: (_) => BookingCubit()),
                  ],
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  name: AppRoutes.salesDashboard,
                  path: AppRoutes.salesDashboard,
                  builder: (context, state) {
                    return const SalesDashboardScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.booking,
                  path: AppRoutes.booking,
                  builder: (context, state) {
                    return const BookingScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.addBooking,
                  path: AppRoutes.addBooking,
                  builder: (context, state) {
                    final queryParameterBooking =
                        state.uri.queryParameters['booking'];
                    final queryParameterInventoryObject =
                        state.uri.queryParameters['inventoryObject'];
                    final booking =
                        queryParameterBooking != null &&
                                queryParameterBooking.isNotEmpty
                            ? BookingModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterBooking),
                                ),
                              ),
                            )
                            : null;
                    final inventoryObject =
                        queryParameterInventoryObject != null &&
                                queryParameterInventoryObject.isNotEmpty
                            ? (jsonDecode(
                                      EncryptionManager.decryptData(
                                        Uri.decodeComponent(
                                          queryParameterInventoryObject,
                                        ),
                                      ),
                                    )
                                    as List<dynamic>)
                                .map<Map<String, dynamic>>(
                                  (e) => Map<String, dynamic>.from(
                                    e as Map<String, dynamic>,
                                  ),
                                )
                                .toList()
                            : null;

                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;

                    return AddBookingScreen(
                      bookingModel: booking,
                      index: index,
                      inventoryObject: inventoryObject,
                    );
                  },
                ),
                GoRoute(
                  name: AppRoutes.viewBooking,
                  path: AppRoutes.viewBooking,
                  builder: (context, state) {
                    final queryParameterBooking =
                        state.uri.queryParameters['bookingId'];
                    final queryParameterProjectId =
                        state.uri.queryParameters['projectId'];

                    final bookingId =
                        queryParameterBooking != null &&
                                queryParameterBooking.isNotEmpty
                            ? int.parse(
                              EncryptionManager.decryptData(
                                Uri.decodeComponent(queryParameterBooking),
                              ),
                            )
                            : 0;
                    final projectId =
                        queryParameterProjectId != null &&
                                queryParameterProjectId.isNotEmpty
                            ? int.parse(
                              EncryptionManager.decryptData(
                                Uri.decodeComponent(queryParameterProjectId),
                              ),
                            )
                            : 0;

                    return BookingViewScreen(
                      projectId: projectId,
                      bookingId: bookingId,
                    );
                  },
                ),
                GoRoute(
                  name: AppRoutes.approvalLogHistory,
                  path: AppRoutes.approvalLogHistory,
                  builder: (context, state) {
                    /// SUBTITLE
                    final titleParam = state.uri.queryParameters['title'];
                    final subTitleParam = state.uri.queryParameters['subTitle'];
                    final title =
                        titleParam != null && titleParam.isNotEmpty
                            ? EncryptionManager.decryptData(
                              Uri.decodeComponent(titleParam),
                            )
                            : "";
                    final subTitle =
                        subTitleParam != null && subTitleParam.isNotEmpty
                            ? EncryptionManager.decryptData(
                              Uri.decodeComponent(subTitleParam),
                            )
                            : "";

                    /// APPROVAL LIST
                    final approvalListParam =
                        state.uri.queryParameters['approvalList'];

                    final List<ApprovalLogHistory> approvalList =
                        approvalListParam != null &&
                                approvalListParam.isNotEmpty
                            ? (jsonDecode(
                                      EncryptionManager.decryptData(
                                        Uri.decodeComponent(approvalListParam),
                                      ),
                                    )
                                    as List)
                                .map((e) => ApprovalLogHistory.fromJson(e))
                                .toList()
                            : [];

                    return ApprovalLogHistoryScreen(
                      title: title,
                      subTitle: subTitle,
                      items: approvalList,
                    );
                  },
                ),
                GoRoute(
                  name: AppRoutes.salesPerformanceReport,
                  path: AppRoutes.salesPerformanceReport,
                  builder: (context, state) {
                    return const PerformanceWithoutAccessScreen();
                  },
                ),
              ],
            ),
            // SALES ENQUIRY
            ShellRoute(
              builder: (context, state, child) {
                return BlocProvider(
                  create: (_) => EnquiryCubit(),
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  name: AppRoutes.enquiry,
                  path: AppRoutes.enquiry,
                  builder: (context, state) {
                    final queryParameterEnquiryName =
                        EncryptionManager.decryptData(
                          Uri.decodeComponent(
                            state.uri.queryParameters['enquiryName'] ?? '',
                          ),
                        );
                    final queryParameterEnquiryCode =
                        EncryptionManager.decryptData(
                          Uri.decodeComponent(
                            state.uri.queryParameters['enquiryCode'] ?? '',
                          ),
                        );
                    return EnquiryScreen(
                      enquiryName: queryParameterEnquiryName,
                      enquiryCode: queryParameterEnquiryCode,
                    );
                  },
                ),
                GoRoute(
                  name: AppRoutes.addEnquiry,
                  path: AppRoutes.addEnquiry,
                  builder: (context, state) {
                    final queryParameterEnquiry =
                        state.uri.queryParameters['enquiry'];
                    final enquiry =
                        queryParameterEnquiry != null &&
                                queryParameterEnquiry.isNotEmpty
                            ? EnquiryModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterEnquiry),
                                ),
                              ),
                            )
                            : null;

                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;
                    return AddEnquiryScreen(
                      enquiryModel: enquiry,
                      index: index,
                    );
                  },
                ),
                GoRoute(
                  name: AppRoutes.viewEnquiry,
                  path: AppRoutes.viewEnquiry,
                  builder: (context, state) {
                    final encryptedId = state.uri.queryParameters['enquiryId'];

                    final enquiryId =
                        encryptedId != null
                            ? int.tryParse(
                              EncryptionManager.decryptData(
                                Uri.decodeComponent(encryptedId),
                              ),
                            )
                            : null;

                    return ViewEnquiryScreen(enquiryId: enquiryId ?? 0);
                  },
                ),
              ],
            ),
            // SALES SOURCING
            ShellRoute(
              builder: (context, state, child) {
                return BlocProvider(
                  create: (_) => SourcingCubit(),
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  name: AppRoutes.sourcing,
                  path: AppRoutes.sourcing,
                  builder: (context, state) {
                    return const SourcingScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.viewSourcing,
                  path: AppRoutes.viewSourcing,
                  builder: (context, state) {
                    final queryParameterChannelPartner =
                        state.uri.queryParameters['channelPartner'];

                    final ChannelPartnerModel? channelPartner =
                        queryParameterChannelPartner != null
                            ? ChannelPartnerModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(
                                    queryParameterChannelPartner,
                                  ),
                                ),
                              ),
                            )
                            : null;
                    final projectId =
                        int.tryParse(
                          state.uri.queryParameters['projectId'] ?? '',
                        ) ??
                        0;
                    return SourcingViewScreen(
                      channelPartner: channelPartner!,
                      projectId: projectId,
                    );
                  },
                ),
              ],
            ),
            // SALES OTHER CHARGES
            ShellRoute(
              builder: (context, state, child) {
                return BlocProvider(
                  create: (_) => OtherChargesCubit(),
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  name: AppRoutes.otherCharges,
                  path: AppRoutes.otherCharges,
                  builder: (context, state) {
                    return const OtherChargesScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.addOtherCharges,
                  path: AppRoutes.addOtherCharges,
                  builder: (context, state) {
                    final queryParameterOtherCharges =
                        state.uri.queryParameters['otherCharges'];
                    final otherCharges =
                        queryParameterOtherCharges != null &&
                                queryParameterOtherCharges.isNotEmpty
                            ? OtherChargeModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(
                                    queryParameterOtherCharges,
                                  ),
                                ),
                              ),
                            )
                            : null;

                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;
                    final projectId =
                        int.tryParse(
                          state.uri.queryParameters['projectId'] ?? '',
                        ) ??
                        0;
                    return AddOtherChargesScreen(
                      otherChargeModel: otherCharges,
                      index: index,
                      projectId: projectId,
                    );
                  },
                ),
              ],
            ),
            // SALES CLASSIFICATION PARAMETERS
            ShellRoute(
              builder: (context, state, child) {
                return BlocProvider(
                  create: (_) => ClassificationParametersCubit(),
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  name: AppRoutes.classificationParameter,
                  path: AppRoutes.classificationParameter,
                  builder: (context, state) {
                    return ClassificationParameterScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.addClassificationParameter,
                  path: AppRoutes.addClassificationParameter,
                  builder: (context, state) {
                    final queryParameterEnquiry =
                        state.uri.queryParameters['classificationParameter'];
                    final classificationParameter =
                        queryParameterEnquiry != null &&
                                queryParameterEnquiry.isNotEmpty
                            ? ClassificationParameterModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterEnquiry),
                                ),
                              ),
                            )
                            : null;

                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;
                    return AddClassificationParameterScreen(
                      classificationParamterModel: classificationParameter,
                      index: index,
                    );
                  },
                ),
              ],
            ),
            // PAYMENT SCHEDULE
            ShellRoute(
              builder: (context, state, child) {
                return BlocProvider(
                  create: (_) => PaymentScheduleCubit(),
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  name: AppRoutes.paymentSchedule,
                  path: AppRoutes.paymentSchedule,
                  builder: (context, state) {
                    return const PaymentScheduleScreen();
                  },
                ),

                GoRoute(
                  name: AppRoutes.addPaymentSchedule,
                  path: AppRoutes.addPaymentSchedule,
                  builder: (context, state) {
                    final queryParameterPaymentSchedule =
                        state.uri.queryParameters['paymentSchedule'];
                    final paymentSchedule =
                        queryParameterPaymentSchedule != null &&
                                queryParameterPaymentSchedule.isNotEmpty
                            ? PaymentScheduleMasterModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(
                                    queryParameterPaymentSchedule,
                                  ),
                                ),
                              ),
                            )
                            : null;

                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;
                    return AddPaymentScheduleScreen(
                      paymentScheduleMaster: paymentSchedule,
                      index: index,
                    );
                  },
                ),
              ],
            ),

            ShellRoute(
              builder: (context, state, child) {
                return BlocProvider(
                  create: (_) => PaymentScheduleSchemeCubit(),
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  name: AppRoutes.paymentScheduleScheme,
                  path: AppRoutes.paymentScheduleScheme,
                  builder: (context, state) {
                    return const PaymentScheduleSchemeScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.addPaymentScheduleScheme,
                  path: AppRoutes.addPaymentScheduleScheme,
                  builder: (context, state) {
                    final queryParameterPaymentScheduleScheme =
                        state.uri.queryParameters['scheme'];
                    final paymentScheduleScheme =
                        queryParameterPaymentScheduleScheme != null &&
                                queryParameterPaymentScheduleScheme.isNotEmpty
                            ? PaymentScheduleSchemeModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(
                                    queryParameterPaymentScheduleScheme,
                                  ),
                                ),
                              ),
                            )
                            : null;

                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;
                    return AddPaymentScheduleSchemeScreen(
                      paymentScheduleSchemeModel: paymentScheduleScheme,
                      index: index,
                    );
                  },
                ),
              ],
            ),

            // ATTENDANCE
            GoRoute(
              name: AppRoutes.attendance,
              path: AppRoutes.attendance,
              builder: (context, state) {
                return BlocProvider(
                  create: (context) => AttendanceCubit(),
                  child: AttendanceScreen(),
                );
              },
            ),
            // RESIGNATION
            ShellRoute(
              builder: (context, state, child) {
                return BlocProvider(
                  create: (_) => ResignationCubit(),
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  name: AppRoutes.resignation,
                  path: AppRoutes.resignation,
                  builder: (context, state) {
                    return ResignationScreen();
                  },
                ),
                GoRoute(
                  name: AppRoutes.addresignation,
                  path: AppRoutes.addresignation,
                  builder: (context, state) {
                    final queryParameterResignation =
                        state.uri.queryParameters['resignation'];

                    final ResignationModel? resignation =
                        queryParameterResignation != null
                            ? ResignationModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(
                                    queryParameterResignation,
                                  ),
                                ),
                              ),
                            )
                            : null;

                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;
                    return AddResignationScreen(
                      resignationModel: resignation,
                      index: index,
                    );
                  },
                ),
              ],
            ),
            // PAYROLL REPORT
            GoRoute(
              name: AppRoutes.payrollReport,
              path: AppRoutes.payrollReport,
              builder: (context, state) {
                return BlocProvider(
                  create: (context) => PayrollReportCubit(),
                  child: PayrollReportScreen(),
                );
              },
            ),
          ],
        ),
        // STOCK MANAGEMENT
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => StockManagementCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.stockManagement,
              path: AppRoutes.stockManagement,
              builder: (context, state) {
                return StockManagementScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addStockManagement,
              path: AppRoutes.addStockManagement,
              builder: (context, state) {
                final queryParameterStock = state.uri.queryParameters['stock'];
                final StockManagementModel? stock =
                    queryParameterStock != null
                        ? StockManagementModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterStock),
                            ),
                          ),
                        )
                        : null;
                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
                final isRemove =
                    state.uri.queryParameters['isRemove'] == "true";
                return AddStockManagementScreen(
                  stock: stock,
                  index: index,
                  isRemove: isRemove,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.viewStockManagement,
              path: AppRoutes.viewStockManagement,
              builder: (context, state) {
                final queryParameterMaterialName =
                    state.uri.queryParameters['materialName'];
                final queryParameterSubMaterialName =
                    state.uri.queryParameters['subMaterialName'];

                final queryParameterSubMaterialMasterId =
                    state.uri.queryParameters['subMaterialMasterId'];

                final materialName =
                    queryParameterMaterialName != null &&
                            queryParameterMaterialName.isNotEmpty
                        ? EncryptionManager.decryptData(
                          Uri.decodeComponent(queryParameterMaterialName),
                        )
                        : "";
                final subMaterialName =
                    queryParameterSubMaterialName != null &&
                            queryParameterSubMaterialName.isNotEmpty
                        ? EncryptionManager.decryptData(
                          Uri.decodeComponent(queryParameterSubMaterialName),
                        )
                        : "";

                final subMaterialMasterId =
                    queryParameterSubMaterialMasterId != null &&
                            queryParameterSubMaterialMasterId.isNotEmpty
                        ? int.parse(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(
                              queryParameterSubMaterialMasterId,
                            ),
                          ),
                        )
                        : 0;

                return ViewStockManagementScreen(
                  materialName: materialName,
                  subMaterialName: subMaterialName,
                  subMaterialMasterId: subMaterialMasterId,
                );
              },
            ),
          ],
        ),

        // MATERIAL REQUISITION
        ShellRoute(
          // navigatorKey: shellNavigatorKey,
          builder: (context, state, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => FinalizeVendorCubit()),
                BlocProvider(create: (context) => PurchaseOrderCubit()),
                BlocProvider(create: (context) => GrnCubit()),
                BlocProvider(create: (context) => InvoiceCubit()),
                BlocProvider(create: (context) => MaterialRequisitionCubit()),
              ],
              child: child,
            );
          },

          routes: [
            GoRoute(
              path: AppRoutes.materialRequisition,
              name: AppRoutes.materialRequisition,
              builder: (context, state) => MaterialRequisitonScreen(),
            ),
            GoRoute(
              name: AppRoutes.addMaterialRequisition,
              path: AppRoutes.addMaterialRequisition,
              builder: (context, state) {
                final queryParameterMaterialRequisition =
                    state.uri.queryParameters['materialRequisition'];

                final MaterialRequisitionModel? materialRequisition =
                    queryParameterMaterialRequisition != null
                        ? MaterialRequisitionModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(
                                queryParameterMaterialRequisition,
                              ),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
                return AddMaterialRequisitionScreen(
                  materialRequisitionModel: materialRequisition,
                  index: index,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.addMaterial,
              path: AppRoutes.addMaterial,
              builder: (context, state) {
                final queryParameterMaterialDetails =
                    state.uri.queryParameters['material'];

                final MaterialRequisitionDetailModel? materialDetails =
                    queryParameterMaterialDetails != null
                        ? MaterialRequisitionDetailModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(
                                queryParameterMaterialDetails,
                              ),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
                return AddMaterialScreen(
                  materialDetails: materialDetails,
                  index: index,
                );
              },
            ),
            GoRoute(
              path: AppRoutes.copyMaterialRequisition,
              name: AppRoutes.copyMaterialRequisition,

              builder: (context, state) {
                final queryParameterMaterialRequisition =
                    state.uri.queryParameters['materialRequisition'];

                final MaterialRequisitionModel? materialRequisition =
                    queryParameterMaterialRequisition != null
                        ? MaterialRequisitionModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(
                                queryParameterMaterialRequisition,
                              ),
                            ),
                          ),
                        )
                        : null;
                return CopyMaterialRequisitionScreen(
                  materialRequisitionModel: materialRequisition!,
                );
              },
            ),

            GoRoute(
              name: AppRoutes.viewMaterialRequisition,
              path: AppRoutes.viewMaterialRequisition,
              builder: (context, state) {
                final queryParameterMaterialRequisitionId =
                    state.uri.queryParameters['materialRequisitionId'];
                final queryParameterProjectId =
                    state.uri.queryParameters['projectId'];
                final queryParameterUniquekey =
                    state.uri.queryParameters['uniquekey'];

                final materialRequisitionId =
                    queryParameterMaterialRequisitionId != null &&
                            queryParameterMaterialRequisitionId.isNotEmpty
                        ? int.parse(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(
                              queryParameterMaterialRequisitionId,
                            ),
                          ),
                        )
                        : 0;
                final projectId =
                    queryParameterProjectId != null &&
                            queryParameterProjectId.isNotEmpty
                        ? int.parse(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(queryParameterProjectId),
                          ),
                        )
                        : 0;
                final uniquekey =
                    queryParameterUniquekey != null &&
                            queryParameterUniquekey.isNotEmpty
                        ? EncryptionManager.decryptData(
                          Uri.decodeComponent(queryParameterUniquekey),
                        )
                        : "";
                return MaterialRequisitionViewScreen(
                  materialRequisitionId: materialRequisitionId,
                  projectId: projectId,
                  uniquekey: uniquekey,
                );
              },
            ),
            GoRoute(
              path: AppRoutes.finalizeVendor,
              name: AppRoutes.finalizeVendor,
              builder: (context, state) {
                final queryParameterMaterialRequisitionId =
                    state.uri.queryParameters['materialRequisitionId'];
                final queryParameterProjectId =
                    state.uri.queryParameters['projectId'];
                final queryParameterUniquekey =
                    state.uri.queryParameters['uniquekey'];

                final materialRequisitionId =
                    queryParameterMaterialRequisitionId != null &&
                            queryParameterMaterialRequisitionId.isNotEmpty
                        ? int.parse(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(
                              queryParameterMaterialRequisitionId,
                            ),
                          ),
                        )
                        : 0;
                final projectId =
                    queryParameterProjectId != null &&
                            queryParameterProjectId.isNotEmpty
                        ? int.parse(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(queryParameterProjectId),
                          ),
                        )
                        : 0;
                final uniquekey =
                    queryParameterUniquekey != null &&
                            queryParameterUniquekey.isNotEmpty
                        ? EncryptionManager.decryptData(
                          Uri.decodeComponent(queryParameterUniquekey),
                        )
                        : "";
                final queryParameterSystemGeneratedCode =
                    state.uri.queryParameters['systemGeneratedCode'];
                final materialRequisitionSystemGeneratedCode =
                    queryParameterSystemGeneratedCode != null &&
                            queryParameterSystemGeneratedCode.isNotEmpty
                        ? EncryptionManager.decryptData(
                          Uri.decodeComponent(
                            queryParameterSystemGeneratedCode,
                          ),
                        )
                        : "";
                return FinalizeVendorScreen(
                  materialRequisitionId: materialRequisitionId,
                  projectId: projectId,
                  uniquekey: uniquekey,
                  systemGeneratedCode: materialRequisitionSystemGeneratedCode,
                );
              },
            ),
            GoRoute(
              path: AppRoutes.finalizeVendorGetQuotation,
              name: AppRoutes.finalizeVendorGetQuotation,
              builder: (context, state) {
                final queryParameterSystemGeneratedCode =
                    state.uri.queryParameters['systemGeneratedCode'];
                final materialRequisitionSystemGeneratedCode =
                    queryParameterSystemGeneratedCode != null &&
                            queryParameterSystemGeneratedCode.isNotEmpty
                        ? EncryptionManager.decryptData(
                          Uri.decodeComponent(
                            queryParameterSystemGeneratedCode,
                          ),
                        )
                        : "";
                final queryParameterMaterialRequisitionId =
                    state.uri.queryParameters['materialRequisitionId'];
                final queryParameterProjectId =
                    state.uri.queryParameters['projectId'];
                final queryParameterUniquekey =
                    state.uri.queryParameters['uniquekey'];

                final materialRequisitionId =
                    queryParameterMaterialRequisitionId != null &&
                            queryParameterMaterialRequisitionId.isNotEmpty
                        ? int.parse(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(
                              queryParameterMaterialRequisitionId,
                            ),
                          ),
                        )
                        : 0;
                final projectId =
                    queryParameterProjectId != null &&
                            queryParameterProjectId.isNotEmpty
                        ? int.parse(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(queryParameterProjectId),
                          ),
                        )
                        : 0;
                final uniquekey =
                    queryParameterUniquekey != null &&
                            queryParameterUniquekey.isNotEmpty
                        ? EncryptionManager.decryptData(
                          Uri.decodeComponent(queryParameterUniquekey),
                        )
                        : "";
                return FinalizeVendorGetQuotationScreen(
                  systemgeneratedCode: materialRequisitionSystemGeneratedCode,
                  materialRequisitionId: materialRequisitionId,
                  projectId: projectId,
                  uniquekey: uniquekey,
                );
              },
            ),
            GoRoute(
              path: AppRoutes.finalizeEditVendor,
              name: AppRoutes.finalizeEditVendor,
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                final vendor =
                    extra?['vendor'] as FinalizeVendorForComparisonModel?;
                final materials =
                    extra?['materials']
                        as List<MaterialRequisitionDetailModel>?;
                final systemGeneratedCode = extra?['systemGeneratedCode'] ?? "";
                final projectId = extra?['projectId'] ?? 0;
                final materialRequisitionId =
                    extra?['materialRequisitionId'] ?? 0;
                final uniquekey = extra?['uniquekey'] ?? "";
                return FinalizeVendorEditScreen(
                  systemgeneratedCode: systemGeneratedCode,
                  vendor: vendor,
                  materials: materials,
                  projectId: projectId,
                  uniquekey: uniquekey,
                  materialRequisitionId: materialRequisitionId,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.generatePurchaseOrder,
              path: AppRoutes.generatePurchaseOrder,
              builder: (context, state) {
                final queryParameterMaterialRequisitionId =
                    state.uri.queryParameters['materialRequisitionId'];
                final queryParameterProjectId =
                    state.uri.queryParameters['projectId'];
                final queryParameterUniquekey =
                    state.uri.queryParameters['uniquekey'];

                final materialRequisitionId =
                    queryParameterMaterialRequisitionId != null &&
                            queryParameterMaterialRequisitionId.isNotEmpty
                        ? int.parse(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(
                              queryParameterMaterialRequisitionId,
                            ),
                          ),
                        )
                        : 0;
                final projectId =
                    queryParameterProjectId != null &&
                            queryParameterProjectId.isNotEmpty
                        ? int.parse(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(queryParameterProjectId),
                          ),
                        )
                        : 0;
                final uniquekey =
                    queryParameterUniquekey != null &&
                            queryParameterUniquekey.isNotEmpty
                        ? EncryptionManager.decryptData(
                          Uri.decodeComponent(queryParameterUniquekey),
                        )
                        : "";

                return GeneratePurchaseOrderScreen(
                  materialRequisitionId: materialRequisitionId,
                  projectId: projectId,
                  uniquekey: uniquekey,
                );
              },
            ),

            GoRoute(
              name: AppRoutes.addGrn,
              path: AppRoutes.addGrn,
              builder: (context, state) {
                final queryParameterGrn =
                    state.uri.queryParameters['grnMaterial'];
                final queryParameterMaterialRequisitionId =
                    state.uri.queryParameters['materialRequisitionId'];
                final queryParameterProjectId =
                    state.uri.queryParameters['projectId'];
                final queryParameterUniquekey =
                    state.uri.queryParameters['uniquekey'];

                final GRNModel? grn =
                    queryParameterGrn != null
                        ? GRNModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterGrn),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
                final materialRequisitionId =
                    queryParameterMaterialRequisitionId != null &&
                            queryParameterMaterialRequisitionId.isNotEmpty
                        ? int.parse(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(
                              queryParameterMaterialRequisitionId,
                            ),
                          ),
                        )
                        : 0;
                final projectId =
                    queryParameterProjectId != null &&
                            queryParameterProjectId.isNotEmpty
                        ? int.parse(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(queryParameterProjectId),
                          ),
                        )
                        : 0;
                final uniquekey =
                    queryParameterUniquekey != null &&
                            queryParameterUniquekey.isNotEmpty
                        ? EncryptionManager.decryptData(
                          Uri.decodeComponent(queryParameterUniquekey),
                        )
                        : "";
                return AddGrnScreen(
                  grnModel: grn,
                  index: index,
                  materialRequisitionId: materialRequisitionId,
                  projectId: projectId,
                  uniquekey: uniquekey,
                );
              },
              routes: [
                GoRoute(
                  name: AppRoutes.addGrnMaterial,
                  path: AppRoutes.addGrnMaterial,
                  builder: (context, state) {
                    final queryParameterMaterialDetails =
                        state.uri.queryParameters['material'];
                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;
                    final parentEditMode =
                        bool.tryParse(
                          state.uri.queryParameters['isEdit'] ?? '',
                        ) ??
                        false;
                    final MaterialRequisitionDetailGrnDatum? materialDetails =
                        queryParameterMaterialDetails != null
                            ? MaterialRequisitionDetailGrnDatum.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(
                                    queryParameterMaterialDetails,
                                  ),
                                ),
                              ),
                            )
                            : null;

                    return AddGrnMaterialScreen(
                      materialDetails: materialDetails,
                      index: index,
                      isParentEditMode: parentEditMode,
                    );
                  },
                ),
                GoRoute(
                  name: AppRoutes.viewGrn,
                  path: AppRoutes.viewGrn,
                  builder: (context, state) {
                    final queryParameterGrn = state.uri.queryParameters['grn'];

                    final GRNModel? grn =
                        queryParameterGrn != null
                            ? GRNModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterGrn),
                                ),
                              ),
                            )
                            : null;
                    return ViewGrnScreen(grnModel: grn!);
                  },
                ),
                GoRoute(
                  name: AppRoutes.grnSummary,
                  path: AppRoutes.grnSummary,
                  builder: (context, state) {
                    final queryParameterMaterialRequisitionId =
                        state.uri.queryParameters['materialRequisitionId'];
                    final queryParameterProjectId =
                        state.uri.queryParameters['projectId'];
                    final queryParameterUniquekey =
                        state.uri.queryParameters['uniquekey'];

                    final materialRequisitionId =
                        queryParameterMaterialRequisitionId != null &&
                                queryParameterMaterialRequisitionId.isNotEmpty
                            ? int.parse(
                              EncryptionManager.decryptData(
                                Uri.decodeComponent(
                                  queryParameterMaterialRequisitionId,
                                ),
                              ),
                            )
                            : 0;
                    final projectId =
                        queryParameterProjectId != null &&
                                queryParameterProjectId.isNotEmpty
                            ? int.parse(
                              EncryptionManager.decryptData(
                                Uri.decodeComponent(queryParameterProjectId),
                              ),
                            )
                            : 0;
                    final uniquekey =
                        queryParameterUniquekey != null &&
                                queryParameterUniquekey.isNotEmpty
                            ? EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterUniquekey),
                            )
                            : "";

                    return GrnSummaryScreen(
                      materialRequisitionId: materialRequisitionId,
                      projectId: projectId,
                      uniquekey: uniquekey,
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              name: AppRoutes.addInvoice,
              path: AppRoutes.addInvoice,
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                final grn = extra?['grn'] as GRNModel?;
                final systemGeneratedCode = extra?['systemGeneratedCode'] ?? "";
                return AddInvoiceScreen(
                  systemgeneratedCode: systemGeneratedCode,
                  grn: grn,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.makePayment,
              path: AppRoutes.makePayment,
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                final grn = extra?['grn'] as GRNModel?;
                final systemGeneratedCode = extra?['systemGeneratedCode'] ?? "";
                return MakePaymentScreen(
                  systemgeneratedCode: systemGeneratedCode,
                  grn: grn,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.makePaymentScreen,
              path: AppRoutes.makePaymentScreen,
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                final systemGeneratedCode = extra?['systemGeneratedCode'] ?? "";
                return AddMakePaymentScreen(
                  systemgeneratedCode: systemGeneratedCode,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.viewPayment,
              path: AppRoutes.viewPayment,
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                final systemGeneratedCode = extra?['systemGeneratedCode'] ?? "";
                final invoiceNumber = extra?['invoiceNumber'] ?? "";
                return ViewPaymentScreen(
                  systemgeneratedCode: systemGeneratedCode,
                  invoiceNumber: invoiceNumber,
                );
              },
            ),
          ],
        ),
        // CRM Pay Track
        ShellRoute(
          builder: (context, state, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => CrmDashboardCubit(), child: child),
                BlocProvider(create: (_) => PayTrackCubit(), child: child),
                BlocProvider(create: (_) => BookingCubit(), child: child),
                BlocProvider(create: (_) => CallTrackerCubit(), child: child),
                BlocProvider(create: (_) => LoanDetailsCubit(), child: child),
                BlocProvider(create: (_) => FilesCubit(), child: child),
                BlocProvider(create: (_) => PaymentCubit(), child: child),
                BlocProvider(
                  create: (_) => RequestManagementCubit(),
                  child: child,
                ),
                BlocProvider(create: (_) => SnagChecklistCubit(), child: child),
                BlocProvider(
                  create: (_) => FlatHandoverChecklistCubit(),
                  child: child,
                ),
              ],
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.crmDashbaord,
              path: AppRoutes.crmDashbaord,
              builder: (context, state) {
                return const CrmDashboardScreen();
              },
            ),
            GoRoute(
              path: AppRoutes.payTrackMaster,
              name: AppRoutes.payTrackMaster,
              builder: (context, state) => PayTrackScreen(),
            ),
            GoRoute(
              name: AppRoutes.viewPayTrackMaster,
              path: AppRoutes.viewPayTrackMaster,
              builder: (context, state) {
                final queryParameterProjectId =
                    state.uri.queryParameters['projectId'];
                final queryParameterBookingId =
                    state.uri.queryParameters['bookingId'];
                final queryParameterEnquiryId =
                    state.uri.queryParameters['enquiryId'];
                final queryParameterApplicantName =
                    state.uri.queryParameters['applicantName'];
                final projectId =
                    queryParameterProjectId != null &&
                            queryParameterProjectId.isNotEmpty
                        ? int.parse(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(queryParameterProjectId),
                          ),
                        )
                        : 0;
                final bookingId =
                    queryParameterBookingId != null &&
                            queryParameterBookingId.isNotEmpty
                        ? int.parse(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(queryParameterBookingId),
                          ),
                        )
                        : 0;
                final enquiryId =
                    queryParameterEnquiryId != null &&
                            queryParameterEnquiryId.isNotEmpty
                        ? int.parse(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(queryParameterEnquiryId),
                          ),
                        )
                        : 0;
                final applicantName =
                    queryParameterApplicantName != null &&
                            queryParameterApplicantName.isNotEmpty
                        ? EncryptionManager.decryptData(
                          Uri.decodeComponent(queryParameterApplicantName),
                        )
                        : "";
                return PayTrackViewScreen(
                  applicantName: applicantName,
                  projectId: projectId,
                  bookingId: bookingId,
                  enquiryId: enquiryId,
                );
              },
            ),
            GoRoute(
              path: AppRoutes.addBankLoanDocument,
              name: AppRoutes.addBankLoanDocument,
              builder: (context, state) {
                final queryParameterBookingId =
                    state.uri.queryParameters['bookingId'];

                final queryParameterProjectId =
                    state.uri.queryParameters['projectId'];

                final queryParameterDocument =
                    state.uri.queryParameters['document'];

                final queryParameterIndex = state.uri.queryParameters['index'];

                final bookingId =
                    queryParameterBookingId != null &&
                            queryParameterBookingId.isNotEmpty
                        ? int.parse(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(queryParameterBookingId),
                          ),
                        )
                        : 0;

                final projectId =
                    queryParameterProjectId != null &&
                            queryParameterProjectId.isNotEmpty
                        ? int.parse(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(queryParameterProjectId),
                          ),
                        )
                        : 0;

                final PayTrackBookingFilesModel? document =
                    queryParameterDocument != null
                        ? PayTrackBookingFilesModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterDocument),
                            ),
                          ),
                        )
                        : null;

                final index = int.tryParse(queryParameterIndex ?? '') ?? 0;

                return AddBankLoanDocumentScreen(
                  projectId: projectId,
                  bookingId: bookingId,
                  payTrackBookingFilesModel: document,
                  index: index,
                );
              },
            ),
            GoRoute(
              path: AppRoutes.addActiveBank,
              name: AppRoutes.addActiveBank,
              builder: (context, state) {
                final queryParameterBookingId =
                    state.uri.queryParameters['bookingId'];

                final queryParameterProjectId =
                    state.uri.queryParameters['projectId'];

                final queryParameterDocument =
                    state.uri.queryParameters['document'];

                final queryParameterIndex = state.uri.queryParameters['index'];

                final bookingId =
                    queryParameterBookingId != null &&
                            queryParameterBookingId.isNotEmpty
                        ? int.parse(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(queryParameterBookingId),
                          ),
                        )
                        : 0;

                final projectId =
                    queryParameterProjectId != null &&
                            queryParameterProjectId.isNotEmpty
                        ? int.parse(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(queryParameterProjectId),
                          ),
                        )
                        : 0;

                final BookingLoanDetailsModel? document =
                    queryParameterDocument != null
                        ? BookingLoanDetailsModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterDocument),
                            ),
                          ),
                        )
                        : null;

                final index = int.tryParse(queryParameterIndex ?? '') ?? 0;

                return AddActiveBankScreen(
                  bookingId: bookingId,
                  projectId: projectId,
                  details: document,
                  index: index,
                );
              },
            ),
            GoRoute(
              path: AppRoutes.addPaymentLedger,
              name: AppRoutes.addPaymentLedger,
              builder: (context, state) {
                final paymentLedgerParam =
                    state.uri.queryParameters['paymentLedger'];

                List<PayTrackPaymentLedgerSummaryModel> paymentLedgerList = [];

                if (paymentLedgerParam != null &&
                    paymentLedgerParam.isNotEmpty) {
                  final decodedData = jsonDecode(
                    Uri.decodeComponent(paymentLedgerParam),
                  );

                  paymentLedgerList =
                      (decodedData as List)
                          .map(
                            (e) =>
                                PayTrackPaymentLedgerSummaryModel.fromJson(e),
                          )
                          .toList();
                }
                return AddPaymentLedgerScreen(
                  paymentLedgerList: paymentLedgerList,
                );
              },
            ),
            GoRoute(
              path: AppRoutes.viewPaymentLedger,
              name: AppRoutes.viewPaymentLedger,
              builder: (context, state) {
                final paymentLedgerSummaryParam =
                    state.uri.queryParameters['paymentLedgerSummary'];

                PayTrackPaymentLedgerSummaryModel? summary;

                if (paymentLedgerSummaryParam != null &&
                    paymentLedgerSummaryParam.isNotEmpty) {
                  final decodedData = jsonDecode(
                    Uri.decodeComponent(paymentLedgerSummaryParam),
                  );

                  summary = PayTrackPaymentLedgerSummaryModel.fromJson(
                    decodedData,
                  );
                }

                return ViewPaymentLedgerScreen(
                  summary:
                      summary ??
                      PayTrackPaymentLedgerSummaryModel(
                        payTrackPaymentLedgerId: 0,
                        uniquekey: "",
                        bookingId: 0,
                        projectId: 0,
                        bookingOtherChargesId: 0,
                        chargeName: "",
                        paymentFor: "",
                        paymentMode: "",
                        paymentReceivedFrom: "",
                        bankListMasterId: 0,
                        bankName: "",
                        projectBankListMasterId: 0,
                        projectBankName: "",
                        projectAccountNumber: "",
                        projectIfscCode: "",
                        receivedAmount: 0,
                        transactionChequeDemandDraftNumber: "",
                        transactionChequeDemandDraftUrl: "",
                        transactionChequeDemandDraftDate: DateTime.now(),
                        approvalStatus: "",
                        isApproval: false,
                        paymentReceiptUrl: "",
                        createdById: 0,
                        createdBy: "",
                        createdDate: DateTime.now(),
                        modifiedById: 0,
                        modifiedBy: "",
                        modifiedDate: DateTime.now(),
                      ),
                );
              },
            ),
            GoRoute(
              path: AppRoutes.addRefundScreen,
              name: AppRoutes.addRefundScreen,
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>? ?? {};
                final booking = extra['booking'] as BookingModel;

                return AddRefundScreen(booking: booking);
              },
            ),
            GoRoute(
              path: AppRoutes.addApplicantDetailsRequests,
              name: AppRoutes.addApplicantDetailsRequests,
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>? ?? {};
                return AddApplicantDetailsRequestsScreen(
                  bookingId: extra['bookingId'],
                  projectId: extra['projectId'],
                );
              },
            ),
            GoRoute(
              path: AppRoutes.swapBookedParking,
              name: AppRoutes.swapBookedParking,
              builder: (context, state) {
                return AddParkingDetailsScreen();
              },
            ),
            GoRoute(
              path: AppRoutes.addFlatSpecificationRemarkScreen,
              name: AppRoutes.addFlatSpecificationRemarkScreen,
              builder: (context, state) {
                return AddFlatSpecificationRemarkScreen();
              },
            ),
            GoRoute(
              path: AppRoutes.modifiedRequestsMakePayment,
              name: AppRoutes.modifiedRequestsMakePayment,
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>;
                return ModifiedRequestsMakePaymentScreen(
                  uniquekey: extra["uniquekey"],
                  bookingId: extra["bookingId"],
                  projectId: extra["projectId"],
                );
              },
            ),
            GoRoute(
              path: AppRoutes.addFlatHandoverDocuments,
              name: AppRoutes.addFlatHandoverDocuments,
              builder: (context, state) {
                return AddFlatHandoverScreen();
              },
            ),
            GoRoute(
              path: AppRoutes.addFiles,
              name: AppRoutes.addFiles,
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>? ?? {};
                return AddFilesScreen(
                  projectId: extra['projectId'],
                  bookingId: extra['bookingId'],
                  filesModel: extra['file'],
                  index: extra['index'],
                  isEdit: extra['isEdit'] ?? false,
                );
              },
            ),
          ],
        ),
        // CRM BROKERAGE
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(create: (_) => BrokerageCubit(), child: child);
          },
          routes: [
            GoRoute(
              name: AppRoutes.brokerage,
              path: AppRoutes.brokerage,
              builder: (context, state) {
                return const BrokerageScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.viewBrokerage,
              path: AppRoutes.viewBrokerage,
              builder: (context, state) {
                final queryParameterBrokerage =
                    state.uri.queryParameters['brokerage'];

                final BrokerageModel? brokerage =
                    queryParameterBrokerage != null
                        ? BrokerageModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterBrokerage),
                            ),
                          ),
                        )
                        : null;

                return ViewBrokerageScreen(brokerageModel: brokerage!);
              },
            ),
            GoRoute(
              name: AppRoutes.addBrokerageInvoice,
              path: AppRoutes.addBrokerageInvoice,
              builder: (context, state) {
                final queryParameterBrokerageInvoice =
                    state.uri.queryParameters['brokerageInvoice'];

                final BrokerageInvoiceModel? invoice =
                    queryParameterBrokerageInvoice != null
                        ? BrokerageInvoiceModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(
                                queryParameterBrokerageInvoice,
                              ),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                final queryParameterBooking =
                    state.uri.queryParameters['bookingId'];
                final queryParameterProjectId =
                    state.uri.queryParameters['projectId'];

                final bookingId =
                    queryParameterBooking != null &&
                            queryParameterBooking.isNotEmpty
                        ? int.parse(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(queryParameterBooking),
                          ),
                        )
                        : 0;
                final projectId =
                    queryParameterProjectId != null &&
                            queryParameterProjectId.isNotEmpty
                        ? int.parse(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(queryParameterProjectId),
                          ),
                        )
                        : 0;

                return AddBrokerageInvoiceScreen(
                  brokerageInvoiceModel: invoice,
                  index: index,
                  projectId: projectId,
                  bookingId: bookingId,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.addBrokeragePayment,
              path: AppRoutes.addBrokeragePayment,
              builder: (context, state) {
                final queryParameterBrokerageInvoice =
                    state.uri.queryParameters['brokerageInvoice'];

                final BrokerageInvoiceModel? invoice =
                    queryParameterBrokerageInvoice != null
                        ? BrokerageInvoiceModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(
                                queryParameterBrokerageInvoice,
                              ),
                            ),
                          ),
                        )
                        : null;

                return AddBrokeragePayment(invoiceModel: invoice!);
              },
            ),
          ],
        ),
        // TAX TRACKER
        GoRoute(
          name: AppRoutes.addTaxTracker,
          path: AppRoutes.addTaxTracker,
          builder: (context, state) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => TaxTrackerCubit()),
                BlocProvider(create: (_) => EmployeeMasterCubit()),
              ],
              child: const AddTaxTrackerScreen(),
            );
          },
        ),
        GoRoute(
          name: AppRoutes.taxTracker,
          path: AppRoutes.taxTracker,
          builder: (context, state) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => TaxTrackerCubit()),
                BlocProvider(create: (_) => CompanyMasterCubit()),
              ],
              child: const TaxTrackerScreen(),
            );
          },
        ),
        GoRoute(
          name: AppRoutes.viewTaxTracker,
          path: AppRoutes.viewTaxTracker,
          builder: (context, state) {
            return BlocProvider(
              create: (_) => TaxTrackerCubit(),
              child: const ViewTaxTrackerScreen(),
            );
          },
        ),
      ],
    ),
  ],
);
