class AppRoutes {
  static String testScreen = "/testScreen";
  static String splashScreen = "/splash";
  static String notAuthorized = "/notAuthorized";
  static String login = "/login";
  static String otp = "/otp";
  static String projectList = "/projectList";

  // DASHBOARD
  static String dashboardScreen = "/dashboard";

  // MASTER
  static String departmentMaster = "/departmentMaster";
  static String addDepartment = "/addDepartment";
  static String companyMaster = "/companyMaster";
  static String addCompany = "/addCompany";
  static String addCompanyPartner = "addCompanyPartner";
  static String viewCompanyDetails = "/viewCompanyDetails";
  static String viewCompanyDocument = "/viewCompanyDocument";
  static String viewCompanyPartner = "/viewCompanyPartner";
  static String designationMaster = "/designationMaster";
  static String addDesignation = "/addDesignation";
  static String bankListMaster = "/bankListMaster";
  static String projectMaster = "/projectMaster";
  static String addProjectMaster = "/addProjectMaster";
  static String projectDetails = "/projectDetails";
  static String globalProjectDetails = "/globalProjectDetails";
  static String projectMasterAccess = "/projectMasterAccess";
  static String addBankDetails = "/addBankDetails";
  static String employeeMaster = "/employeeMaster";
  static String addUpdateEmployee = "/addUpdateEmployee";
  static String employeeViewDetails = "/employeeViewDetails";
  static String employeeModuleAccess = "/employeeModuleAccess";
  static String selectEmployeeMobile = "/selectEmployeeMobile";
  static String selectCompanyMobile = "/selectCompanyMobile";
  static String termsAndConditions = "/tnc";
  static String addTermsAndConditions = "/addTnc";
  static String rera = "/rera";

  // PROCUREMENT MASTER
  static String materialMaster = "/materialMaster";
  static String addMaterialMaster = "/addMaterialMaster";
  static String uomMaster = "/uomMaster";
  static String activityMaster = "/activityMaster";
  static String contractMaster = "/contractMaster";
  static String subMaterialMaster = "/subMaterialMaster";
  static String addSubMaterialMaster = "/addSubMaterialMaster";

  // PROCUREMENT
  static String materialRequisition = "/materialRequisition";
  static String addMaterialRequisitionMobile = "/addMaterialRequisitionMobile";
  static String requisitionDetails = "/requisitionDetails";
  static String vendorSelection = "/vendorSelection";
  static String summaryScreen = "/summaryScreen";
  static String materialRequisitionReports = "/materialRequisitionReports";

  // VENDOR
  static String vendor = "/vendor";
  static String addVendor = "/addVendor";
  static String viewVendorDetails = "/viewVendorDetails";
  static String viewVendorDocument = "/viewVendorDocument";

  // INVENTORY
  static String inventory = "/inventory";
  static String addInventory = "/addInventory";
  static String addInventorySpecification = "/addInventorySpecification";

  // PARKING
  static String parking = "/parking";

  // INVOICE
  static String viewInvoiceMobile = "/viewInvoiceMobile";

  // GRN
  static String grnSummaryMobile = "/grnSummaryMobile";

  // NOTIFICATION
  static String notificationScreenMobile = "/notificationScreenMobile";

  // SALES
  static String callTracker = "/callTracker";
  static String enquiry = "/enquiry";
  static String addEnquiry = "/addEnquiry";
  static String channelPartner = "/channelPartner";
  static String addChannelPartner = "/addChannelPartner";
  static String channelPartnerReport = "/channelPartnerReport";
  static String viewBookingReport = "/channelPartnerBooking";
  static String viewEnquiryReport = "/viewEnquiryReport";
  static String otherCharges = "/otherCharges";
  static String bookingOtherCharges = "/bookingOtherCharges";
  static String booking = "/booking";
  static String addBooking = "/addBooking";
  static String viewBooking = "/viewBooking";
  static String addPaymentSchedule = "/addPaymentSchedule";
  static String enquiryReport = "/enquiryReport";
  static String cpEnquiryReport = "/cpEnquiryReport";
  static String sourcing = "/sourcing";

  // HRM
  static String assetMaster = "/assetMaster";
  static String addAssetMaster = "/addAssetMaster";
  static String viewAssetMaster = "/viewAssetMaster";
  static String assetMappingMaster = "/assetMappingMaster";
  static String addAssetMappingMaster = "/addAssetMappingMaster";
  static String viewAssetMappingMaster = "/viewAssetMappingMaster";
  static String branchMaster = "/branchMaster";
  static String addBranchMaster = "/addBranchMaster";
  static String viewBranchMaster = "/viewBranchMaster";
  static String branchAssociation = "/branchAssociationsMaster";
  static String addBranchAssociation = "/addBranchAssociationsMaster";
  static String leaveTypeMaster = "/leaveTypeMaster";
  static String addLeaveTypeMaster = "/addLeaveTypeMaster";
  static String leaveEncashmentMaster = "/leaveEncashmentMaster";
  static String addLeaveEncashmentMaster = "/addLeaveEncashmentMaster";
  static String holidayMaster = "/holidayMaster";
  static String addHolidayMaster = "/addHolidayMaster";
  static String holidayMappingMaster = "/holidayMappingMaster";
  static String addHolidayMappingMaster = "/addHolidayMappingMaster";
  static String earningMaster = "/earningMaster";
  static String addEarningMaster = "/addEarningMaster";
  static String deductionMaster = "/deductionMaster";
  static String addDeductionMaster = "/addDeductionMaster";
  static String shiftMaster = "/shiftMaster";
  static String addShiftMaster = "/addShiftMaster";
  static String viewShiftMaster = "/viewShiftMaster";
  static String shiftMappingMaster = "/shiftMappingMaster";
  static String addShiftMappingMaster = "/addShiftMappingMaster";
  static String viewShiftMappingMaster = "/viewShiftMappingMaster";
  static String weekOffMaster = "/weekOffMaster";
  static String addWeekOffMaster = "/addWeekOffMaster";
  static String viewWeekOffMaster = "/viewWeekOffMaster";
  static String weekOffMappingMaster = "/weekOffMappingMaster";
  static String viewWeekOffMappingMaster = "/viewWeekOffMappingMaster";
  static String addWeekOffMappingMaster = "/addWeekOffMappingMaster";

  // STOCK MANAGEMENT
  static String stockManagement = "/stock";
  static String stockManagementHistory = "/stockHistory";

  // REDEVELOPMENT
  static String building = "/building";
  static String addBuilding = "/addBuilding";
  static String viewBuilding = "/viewBuilding";
  static String buildingDescription = "/buildingDescription";
  static String proposedOffer = "/proposedOffer";
  static String rent = "/rent";
  static String tenant = "/tenant";
  static String addTenant = "/addTenant";
  static String viewTenant = "/viewTenant";
  static String viewPayTrackRentLedger = "/viewPayTrackRentLedger";

  // CRM
  static String payTrack = "/payTrack";
  static String paymentSchedule = "/paymentSchedule";
  static String paymentLedger = "/paymentLedger";
  static String crmBooking = "/crmBooking";
  static String crmBrokerage = "/brokerage";
  static String brokerageInvoice = "/brokerageInvoice";
  static String viewPayment = "/viewPayment";
  static String viewFlatAlterationRequest = "/viewFlatAlterationRequest";
  static String viewParkingModificationRequest =
      "/viewParkingModificationRequest";
  static String viewBookingModificationRequest =
      "/viewBookingModificationRequest";
  static String updateBookingModificationRequest =
      "/updateBookingModificationRequest";

  // DOCUMENT
  static String category = "/category";
  static String document = "/document";

  // LEGAL
  static String litigation = "/litigation";
  static String addLitigation = "/addLitigation";
  static String viewLitigation = "/viewLitigation";

  // MARKETING
  static String content = "/content";
  static String contentDocument = "/contentDocument";

  //PROJECT MANAGEMENT
  static String approvedBank = "/approvedBank";
  static String approvedBankFile = "/approvedBankFile";

  // SALES TARGET
  static String salesTarget = "/target";

  // CALENDAR
  static String calendar = "/event";
  static String calendarDetail = "/calendarDetail";
  static String addDetailsCalendar = "/addDetailsCalendar";
  // TASK
  static String taskTransferHistory = "/taskTransferHistory";

  // MENU
  static String menu = "/menu";

  // PROFILE
  static String profile = "/profile";
}
