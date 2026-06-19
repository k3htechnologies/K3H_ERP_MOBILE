class AppRoutes {
  static String testScreen = "/testScreen";
  static String splashScreen = "/splash";
  static String notAuthorized = "/notAuthorized";
  static String register = "/register";
  static String login = "/login";
  // static String projectList = "/projectList";
  static String approvalLogHistory = "/approvalLogHistory";

  /// << -----------------------------------------  $$$  ------------------------------------------- >>
  /// MAIN DASHBOARD
  // DASHBOARD
  static String dashboardScreen = "/dashboard";
  static String employeeAttendanceScreen = "/employeeAttendanceScreen";
  static String pendingApprovalScreen = "/pendingApprovalScreen";
  static String projectOverview = "/projectOverview";

  /// << -----------------------------------------  $$$  ------------------------------------------- >>
  /// SETTINGS

  /// SETTING DASHBAORD
  static String settingDashboard = "/settingDashboard";
  // DEPARTMENT MASTER
  static String departmentMaster = "/departmentMaster";
  static String addDepartment = "/addDepartment";

  // COMPANY MASTER
  static String companyMaster = "/companyMaster";
  static String addCompany = "/addCompany";
  static String addCompanyPartner = "addCompanyPartner";
  static String viewCompanyDetails = "/viewCompanyDetails";
  static String viewCompanyPartner = "/viewCompanyPartner";

  // DESIGNATION MASTER
  static String designationMaster = "/designationMaster";
  static String addDesignation = "/addDesignation";

  // BANK LIST MASTER
  static String bankListMaster = "/bankListMaster";

  // PROJECT MASTER
  static String projectMaster = "/projectMaster";
  static String addProjectMaster = "/addProjectMaster";
  static String projectDetails = "/projectDetails";
  static String addBankDetails = "/addBankDetails";
  static String addEmployeeToModule = "/addEmployeeToModule";
  // TAB ACCESS ROUTES
  static String projectMasterAssignEmployee = "/projectMasterAssignEmployee";
  static String projectMasterBankDetails = "/projectMasterBankDetails";
  static String projectMasterSetCompany = "/projectMasterSetCompany";
  static String projectMasterApprovalSetup = "/projectMasterApprovalSetup";

  // EMPLOYEE MASTER
  static String employeeMaster = "/employeeMaster";
  static String addUpdateEmployee = "/addUpdateEmployee";
  static String employeeViewDetails = "/employeeViewDetails";
  static String employeeModuleAccess = "/employeeModuleAccess";

  // VENDOR
  static String vendor = "/vendor";
  static String addVendor = "/addVendor";
  static String viewVendorDetails = "/viewVendorDetails";
  static String viewVendorDocument = "/viewVendorDocument";

  // TERMS AND CONDITIONS
  static String termsAndConditions = "/tnc";
  static String addTermsAndConditions = "/addTnc";
  static String viewTermsAndConditions = "/viewTnc";

  /// << -----------------------------------------  $$$  ------------------------------------------- >>
  /// PROCUREMENT MASTER
  // MATERIAL MASTER
  static String materialMaster = "/materialMaster";
  static String addMaterialMaster = "/addMaterialMaster";
  static String viewMaterialMaster = "/viewMaterialMaster";

  // UOM MASTER
  static String uomMaster = "/uomMaster";
  static String activityMaster = "/activityMaster";
  static String contractMaster = "/contractMaster";

  // SUB MATERIAL MASTER
  static String subMaterialMaster = "/subMaterialMaster";
  static String addSubMaterialMaster = "/addSubMaterialMaster";
  static String viewSubMaterialMaster = "/viewSubMaterialMaster";

  // PROCUREMENT
  static String materialRequisition = "/materialRequisition";
  static String addMaterial = "/addMaterial";
  static String addMaterialRequisition = "/addMaterialRequisition";
  static String viewMaterialRequisition = "/viewMaterialRequisition";
  static String copyMaterialRequisition = "/copyMaterialRequisition";
  static String addGrn = "/addGrn";
  static String viewGrn = "/viewGrn";
  static String addGrnMaterial = "/addGrnMaterial";
  static String grnSummary = "/grnSummary";
  static String addInvoice = "/addInvoice";
  static String makePayment = "/makePayment";
  static String makePaymentScreen = "/makePaymentScreen";
  static String viewPayment = "/viewPayment";
  static String finalizeVendorGetQuotation = "/finalizeVendorGetQuotation";
  static String finalizeVendor = "/finalizeVendor";
  static String finalizeEditVendor = "/finalizeEditVendor";
  static String generatePurchaseOrder = "/generatePurchaseOrder";

  // TAB ACCESS ROUTES (MATERIAL MASTER VIEW TABS)
  static String getQuotation = 'Get Quotation';
  static String getCompare = 'Get Compare';
  static String finalizedVendor = 'Finalized Vendor';
  static String generatePurchaseOrderTab = 'Generate Purchase Order';
  static String addInvoiceTab = 'Add Invoice';
  static String makePayments = 'Make Payments';

  // STOCK MANAGEMENT
  static String stockManagement = "/stock";
  static String addStockManagement = "/addStockManagement";
  static String viewStockManagement = "/viewStockManagement";

  /// << -----------------------------------------  $$$  ------------------------------------------- >>
  /// INVENTORY

  // INVENTORY
  static String inventoryDashboard = "/inventoryDashboard";
  static String inventory = "/inventory";
  static String addInventorySpecification = "/addInventorySpecification";
  static String addUnitSpecification = "/addUnitSpecification";
  static String viewUnitSpecification = "/viewUnitSpecification";
  static String unitDistributionStatus = "/unitDistributionStatus";

  // INVENTORY REPORT
  static String inventoryParkingOverallReport =
      "/inventoryParkingOverallReport";
  static String inventoryParkingOverallReportOverview =
      "/inventoryParkingOverallReportOverview";
  // PARKING
  static String parking = "/parking";
  static String editParking = "/editParking";

  /// << -----------------------------------------  $$$  ------------------------------------------- >>
  /// NOTIFICATION

  // NOTIFICATION
  static String notificationScreenMobile = "/notificationScreenMobile";

  /// << -----------------------------------------  $$$  ------------------------------------------- >>
  /// SALES

  // SALES CALL TRACKER
  static String callTracker = "/callTracker";
  static String updateCallTracker = "/updateCallTracker";
  static String addCallingData = "/addCallingData";

  // SALES ENQUIRY
  static String enquiry = "/enquiry";
  static String addEnquiry = "/addEnquiry";
  static String viewEnquiry = "/viewEnquiry";

  // SALES CHANNEL PARTNER
  static String channelPartnerDashboard = "/channelPartnerDashboard";
  static String channelPartner = "/channelPartner";
  static String addChannelPartner = "/addChannelPartner";
  static String channelPartnerView = "/channelPartnerView";
  static String cpUniverse = "/cpUniverse";

  // SALES OTHER CHARGES
  static String otherCharges = "/otherCharges";
  static String addOtherCharges = "/addOtherCharges";

  // SALES BOOKING
  static String salesDashboard = "/salesDashboard";
  static String booking = "/booking";
  static String addBooking = "/addBooking";
  static String viewBooking = "/viewBooking";

  // SALES SOURCING
  static String sourcing = "/sourcing";
  static String viewSourcing = "/viewSourcing";

  // SALES TARGET
  static String salesTarget = "/target";
  static String viewTarget = "/viewTarget";

  // PAYMENT SCHEDULE SUMMARY
  static String paymentSchedule = "/paymentSchedule";
  static String addPaymentSchedule = "/addPaymentSchedule";
  static String paymentScheduleScheme = "/paymentScheduleScheme";
  static String addPaymentScheduleScheme = "/addPaymentScheduleScheme";

  // SALES REPORT
  // PERFORMANCE
  static String performanceReport = "/performance";
  static String salesPerformanceReport = "/salesPerformance";
  static String viewPerformanceReport = "/viewPerformance";
  // ACHIEVEMENT
  static String incentiveReport = "/incentiveReport";
  static String enquiryReport = "/enquiryReport";
  static String cpEnquiryReport = "/cpEnquiryReport";
  static String achievementReport = "/achievement";
  static String achievementDrillDownReport = "/achievementDrillDownReport";
  static String achievementDrillDownReportForEnquiry =
      "/achievementDrillDownReportForEnquiry";
  static String achievementDrillDownReportForBooking =
      "/achievementDrillDownReportForBooking";
  static String achievementDrillDownReportForChannelPartner =
      "/achievementDrillDownReportForChannelPartner";

  static String managerAchievementReport = "/managerAchievementReport";

  static String ibmObmReport = "/ibmObmReport";

  // SALES CLASSIFICATION PARAMETERS
  static String classificationParameter = "/classificationParameter";
  static String addClassificationParameter = "/addClassificationParameter";

  // SALES CHANNEL PARTNER CATEGORY
  static String channelPartnerCategory = "/channelPartnerCategory";

  /// << -----------------------------------------  $$$  ------------------------------------------- >>
  /// CRM

  /// PAY TRACK
  static String payTrackMaster = "/payTrack";
  static String viewPayTrackMaster = "/viewPayTrackMaster";
  static String addBankLoanDocument = "/addBankLoanDocument";
  static String addActiveBank = "/addActiveBank";
  static String addPaymentLedger = "/addPaymentLedger";
  static String viewPaymentLedger = "/viewPaymentLedger";
  static String addRefundScreen = "/addRefundScreen";
  static String addApplicantDetailsRequests = "/addApplicantDetailsRequests";
  static String swapBookedParking = "/swapBookedParking";
  static String addFlatSpecificationRemarkScreen =
      "/addFlatSpecificationRemarkScreen";
  static String modifiedRequestsMakePayment = "/modifiedRequestsMakePayment";
  static String addFlatHandoverDocuments = "/addFlatHandoverDocuments";
  static String addFiles = "/addFiles";
  static String crmDashbaord = "/crmDashboard";

  /// BROKERAGE
  static String brokerage = "/brokerage";
  static String bookingBrokerage = "/bookingBrokerage";
  static String viewBrokerage = "/viewBrokerage";
  static String addBrokerageInvoice = "/addBrokerageInvoice";
  static String addBrokeragePayment = "/addBrokeragePayment";

  // TAB ACCESS
  static String brokerageInvoice = '/invoice';
  static String brokerageMakePayment = '/makePayment';

  /// << -----------------------------------------  $$$  ------------------------------------------- >>
  /// PAYROLL MASTER

  // ASSET MASTER
  static String assetMaster = "/assetMaster";
  static String addAssetMaster = "/addAssetMaster";
  static String viewAssetMaster = "/viewAssetMaster";

  // ASSET MAPPING MASTER
  static String assetMappingMaster = "/assetMappingMaster";
  static String addAssetMappingMaster = "/addAssetMappingMaster";
  static String viewAssetMappingMaster = "/viewAssetMappingMaster";

  // BRANCH MASTER
  static String branchMaster = "/branchMaster";
  static String addBranchMaster = "/addBranchMaster";
  static String viewBranchMaster = "/viewBranchMaster";

  // BRANCH ASSOCIATION MASTER
  static String branchAssociation = "/branchAssociationsMaster";
  static String addBranchAssociation = "/addBranchAssociationsMaster";
  static String viewBranchAssociation = "/viewBranchAssociationsMaster";

  // LEAVE TYPE MASTER
  static String leaveTypeMaster = "/leaveTypeMaster";
  static String addLeaveTypeMaster = "/addLeaveTypeMaster";

  // LEAVE ENCASHMENT MASTER
  static String leaveEncashmentMaster = "/leaveEncashmentMaster";
  static String addLeaveEncashmentMaster = "/addLeaveEncashmentMaster";

  // HOLIDAY MASTER
  static String holidayMaster = "/holidayMaster";
  static String viewHolidayMaster = "/viewHolidayMaster";
  static String addHolidayMaster = "/addHolidayMaster";

  // HOLIDAY MAPPING MASTER
  static String holidayMappingMaster = "/holidayMappingMaster";
  static String viewHolidayMappingMaster = "/viewHolidayMappingMaster";
  static String addHolidayMappingMaster = "/addHolidayMappingMaster";

  // EARNING MASTER
  static String earningMaster = "/earningMaster";
  static String addEarningMaster = "/addEarningMaster";
  static String viewEarningMaster = "/viewEarningMaster";

  // DEDUCTION MASTER
  static String deductionMaster = "/deductionMaster";
  static String addDeductionMaster = "/addDeductionMaster";
  static String viewDeductionMaster = "/viewDeductionMaster";

  // SHIFT MASTER
  static String shiftMaster = "/shiftMaster";
  static String addShiftMaster = "/addShiftMaster";
  static String viewShiftMaster = "/viewShiftMaster";

  // SHIFT MAPPING MASTER
  static String shiftMappingMaster = "/shiftMappingMaster";
  static String addShiftMappingMaster = "/addShiftMappingMaster";
  static String viewShiftMappingMaster = "/viewShiftMappingMaster";

  // WEEK OFF MASTER
  static String weekOffMaster = "/weekOffMaster";
  static String addWeekOffMaster = "/addWeekOffMaster";
  static String viewWeekOffMaster = "/viewWeekOffMaster";

  // WEEK OFF MAPPING MASTER
  static String weekOffMappingMaster = "/weekOffMappingMaster";
  static String viewWeekOffMappingMaster = "/viewWeekOffMappingMaster";
  static String addWeekOffMappingMaster = "/addWeekOffMappingMaster";

  // LEAVE CREDIT CONFIGURATION MASTER
  static String leaveCreditConfigurationMaster = "/leaveCreditConfiguration";
  static String addLeaveCreditConfigurationMaster =
      "/addLeaveCreditConfigurationMaster";
  static String addLeaveBalanceType = "/addLeaveBalanceType";
  static String viewLeaveCreditConfigurationMaster =
      "/viewLeaveCreditConfigurationMaster";

  /// << -----------------------------------------  $$$  ------------------------------------------- >>

  /// REDEVELOPMENT

  // REDEVELOPMENT DASHBOARD
  static String redevelopmentDashboard = "/redevelopmentDashboard";

  // BUILDING
  static String building = "/building";
  static String addBuilding = "/addBuilding";
  static String addUpdateBuildingDoc = "/addUpdateBuildingDoc";
  static String editBuildingDetails = "/editBuildingDetails";
  static String viewBuilding = "/viewBuilding";

  // PROPOSED OFFER
  static String proposedOffer = "/proposedOffer";
  static String proposedOfferSecondaryScreen = "/proposedOfferSecondaryScreen";

  // PROPOSED PLANS
  static String proposedPlans = "/proposedPlan";

  // RENT
  static String rent = "/rent";
  static String addPayment = "/addPayment";
  static String viewSummary = "/viewSummary";

  // TENANT
  static String tenant = "/tenant";
  static String addTenant = "/addTenant";
  static String viewTenant = "/viewTenant";
  static String addUpdateTenantDoc = "/addUpdateTenantDoc";

  /// << -----------------------------------------  $$$  ------------------------------------------- >>

  /// PAYROLL

  // PAYROLL DASHBOARD
  static String payrollDashboard = "/payroll";

  // OUTDOOR
  static String outdoor = "/outdoor";
  static String addOutdoor = "/addOutdoor";
  static String viewOutdoor = "/viewOutdoor";

  // LEAVE
  static String leave = "/leave";
  static String applyLeave = "/applyLeave";
  static String viewLeave = "/viewLeave";

  // COMP OFF
  static String compOff = "/compOff";
  static String addCompOff = "/addCompOff";
  static String viewCompOff = "/viewCompOff";

  // ATTENDANCE
  static String attendance = "/attendance";

  // RESIGNATION
  static String resignation = "/resignation";
  static String addresignation = "/addresignation";

  // PAYROLL REPORT
  static String payrollReport = "/payrollReport";

  /// << -----------------------------------------  $$$  ------------------------------------------- >>

  /// PROJECT DOCUMENTS

  // --DOCUMENT
  static String category = "/category";
  static String addDocumentCategory = "/addDocumentCategory";
  static String viewDocumentCategory = "/viewDocumentCategory";
  static String document = "/document";
  static String addDocument = "/addDocument";
  static String viewDocument = "/viewDocument";

  // --RERA DOCUMENT
  static String reraCategory = "/reraCategory";
  static String addReraDocumentCategory = "/addReraDocumentCategory";
  static String viewReraDocumentCategory = "/viewReraDocumentCategory";
  static String addReraDocument = "/addReraDocument";
  static String viewReraDocument = "/viewReraDocument";

  // --APPROVAL DOCUMENT
  static String approvalCategory = "/approvalCategory";
  static String addApprovalCategory = "/addApprovalCategory";
  static String viewApprovalCategory = "/viewApprovalCategory";
  static String approvalDocument = '/approvalDocument';
  static String addApprovalDocument = "/addApprovalDocument";
  static String viewApprovalDocument = "/viewApprovalDocument";

  // RERA DOCUMENT
  static String rera = "/rera";

  /// << -----------------------------------------  $$$  ------------------------------------------- >>

  // LEGAL

  static String litigationDashboard = "/litigationDashboard";
  static String litigation = "/litigation";
  static String addLitigation = "/addLitigation";
  static String viewLitigation = "/viewLitigation";
  static String addLitigationHearing = "/addLitigationHearing";

  /// << -----------------------------------------  $$$  ------------------------------------------- >>

  // MARKETING
  static String content = "/content";
  static String contentDocument = "/contentDocument";

  /// << -----------------------------------------  $$$  ------------------------------------------- >>

  //PROJECT MANAGEMENT
  static String approvedBank = "/approvedBank";
  static String approvedBankFile = "/approvedBankFile";
  static String addBankScreen = "/addBankScreen";

  /// << -----------------------------------------  $$$  ------------------------------------------- >>

  // CALENDAR
  static String calendar = "/event";
  static String calendarDetail = "/calendarDetail";
  static String addDetailsCalendar = "/addDetailsCalendar";
  // TASK
  static String taskTransferHistory = "/taskTransferHistory";
  // INWARD - OUTWARD
  static String inwardOutward = "/inwardOutward";
  static String inwardOutwardAcknowledgement = "/inwardOutwardAcknowledgement";
  static String revertInwardOutward = "/revertInwardOutward";
  static String addInwardOutward = "/addInwardOutward";
  static String viewInwardOutward = "/viewInwardOutward";

  // TICKET
  static String ticket = "/ticket";
  static String viewTicket = "/viewTicket";
  static String assignTicket = "/assignTicket";
  static String addTicket = "/addTicket";

  /// << -----------------------------------------  $$$  ------------------------------------------- >>

  // MENU
  static String menu = "/menu";

  /// << -----------------------------------------  $$$  ------------------------------------------- >>

  // PROFILE
  static String profile = "/profile";
  static String updateUserBasicDetails = "/updateUserBasicDetails";
}
