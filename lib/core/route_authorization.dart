import 'package:k3h_erp_app/routes/app_routes.dart';

class AuthorizationModel {
  final bool isAccess;
  final bool isAction;
  final bool isExport;
  final bool isView;

  AuthorizationModel({
    this.isAccess = false,
    this.isAction = false,
    this.isExport = false,
    this.isView = false,
  });
}

class Authorization {
  static Map<String, AuthorizationModel> routeAuthorizationMap = {
    AppRoutes.dashboardScreen: AuthorizationModel(isAccess: true),
    // <---- MASTERS ---->
    // COMPANY SETUP
    AppRoutes.departmentMaster: AuthorizationModel(),
    AppRoutes.companyMaster: AuthorizationModel(),
    AppRoutes.addCompany: AuthorizationModel(),
    AppRoutes.designationMaster: AuthorizationModel(),
    AppRoutes.projectMaster: AuthorizationModel(),
    AppRoutes.employeeMaster: AuthorizationModel(),
    AppRoutes.employeeModuleAccess: AuthorizationModel(isAccess: true),
    // PROCUREMENT MASTER
    AppRoutes.materialMaster: AuthorizationModel(),
    AppRoutes.activityMaster: AuthorizationModel(),
    AppRoutes.contractMaster: AuthorizationModel(),
    AppRoutes.subMaterialMaster: AuthorizationModel(),
    // <---- PROCUREMENT ---->
    // MATERIAL REQUISITION
    AppRoutes.materialRequisition: AuthorizationModel(),
    // <---- VENDOR ---->
    AppRoutes.vendor: AuthorizationModel(),
    // <---- INVENTORY ---->
    AppRoutes.inventory: AuthorizationModel(),
    AppRoutes.parking: AuthorizationModel(),

    // <---- REDEVELOPMENT ---->
    AppRoutes.building: AuthorizationModel(),
    AppRoutes.proposedOffer: AuthorizationModel(),
    AppRoutes.rent: AuthorizationModel(),
    AppRoutes.tenant: AuthorizationModel(),
    // <---- SALES ---->
    AppRoutes.callTracker: AuthorizationModel(),
    AppRoutes.enquiry: AuthorizationModel(),
    AppRoutes.booking: AuthorizationModel(),
    AppRoutes.otherCharges: AuthorizationModel(),
    AppRoutes.classificationParameter: AuthorizationModel(),
    // <---- CHANNEL PARTNER ---->
    AppRoutes.channelPartner: AuthorizationModel(),

    // <---- HRM ---->
    AppRoutes.assetMaster: AuthorizationModel(),
    AppRoutes.assetMappingMaster: AuthorizationModel(),
    AppRoutes.branchMaster: AuthorizationModel(),
    AppRoutes.branchAssociation: AuthorizationModel(),
    AppRoutes.leaveTypeMaster: AuthorizationModel(),
    AppRoutes.holidayMaster: AuthorizationModel(),
    AppRoutes.earningMaster: AuthorizationModel(),
    AppRoutes.weekOffMaster: AuthorizationModel(),
    AppRoutes.weekOffMappingMaster: AuthorizationModel(),
    AppRoutes.leaveEncashmentMaster: AuthorizationModel(),
  };

  static Map<String, AuthorizationModel> getDefaultAuthorizationMap() {
    return {
      AppRoutes.dashboardScreen: AuthorizationModel(isAccess: true),

      // MASTERS
      AppRoutes.departmentMaster: AuthorizationModel(),
      AppRoutes.companyMaster: AuthorizationModel(),
      AppRoutes.addCompany: AuthorizationModel(),
      AppRoutes.designationMaster: AuthorizationModel(),
      AppRoutes.projectMaster: AuthorizationModel(),
      AppRoutes.employeeMaster: AuthorizationModel(),
      AppRoutes.employeeModuleAccess: AuthorizationModel(isAccess: true),

      // PROCUREMENT
      AppRoutes.materialMaster: AuthorizationModel(),
      AppRoutes.activityMaster: AuthorizationModel(),
      AppRoutes.contractMaster: AuthorizationModel(),
      AppRoutes.subMaterialMaster: AuthorizationModel(),
      AppRoutes.materialRequisition: AuthorizationModel(),

      // VENDOR
      AppRoutes.vendor: AuthorizationModel(),

      // INVENTORY
      AppRoutes.inventory: AuthorizationModel(),
      AppRoutes.parking: AuthorizationModel(),
      // REDEVELOPMENT
      AppRoutes.building: AuthorizationModel(),
      AppRoutes.proposedOffer: AuthorizationModel(),
      AppRoutes.rent: AuthorizationModel(),
      AppRoutes.tenant: AuthorizationModel(),

      // SALES
      AppRoutes.callTracker: AuthorizationModel(),
      AppRoutes.enquiry: AuthorizationModel(),
      AppRoutes.booking: AuthorizationModel(),
      AppRoutes.otherCharges: AuthorizationModel(),
      AppRoutes.classificationParameter: AuthorizationModel(),

      // CHANNEL PARTNER
      AppRoutes.channelPartner: AuthorizationModel(),

      // HRM
      AppRoutes.assetMaster: AuthorizationModel(),
      AppRoutes.assetMappingMaster: AuthorizationModel(),
      AppRoutes.branchMaster: AuthorizationModel(),
      AppRoutes.branchAssociation: AuthorizationModel(),
      AppRoutes.leaveTypeMaster: AuthorizationModel(),
      AppRoutes.holidayMaster: AuthorizationModel(),
      AppRoutes.earningMaster: AuthorizationModel(),
      AppRoutes.weekOffMaster: AuthorizationModel(),
      AppRoutes.weekOffMappingMaster: AuthorizationModel(),
      AppRoutes.leaveEncashmentMaster: AuthorizationModel(),
    };
  }

  static Future<void> reset() async {
    routeAuthorizationMap = getDefaultAuthorizationMap();
  }
}
