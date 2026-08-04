import 'package:k3h_erp_app/utils/static/static_attribute_values.dart';

List<Map<String, dynamic>> createAttributeList(List<String> values) {
  return List.generate(
    values.length,
    (index) => {'zAttributesId': index + 1, 'DisplayName': values[index]},
    growable: false,
  );
}

final List<Map<String, dynamic>> accountTypeList = createAttributeList(
  accountTypeValues,
);

final List<Map<String, dynamic>> natureOfAccountList = createAttributeList(
  natureOfAccountValues,
);
// ENQUIRY

final List<Map<String, dynamic>> currentAccommodation = createAttributeList(
  currentAccommodationValues,
);

final List<Map<String, dynamic>> occupationType = createAttributeList(
  occupationTypeValues,
);

final List<Map<String, dynamic>> sourceTypeList = createAttributeList(
  sourceTypeValues,
);

final List<Map<String, dynamic>> residentialType = createAttributeList(
  residentialTypeValues,
);

final List<Map<String, dynamic>> floorBrand = createAttributeList(
  floorBrandValues,
);

final List<Map<String, dynamic>> budgetInCrList = createAttributeList(
  budgetInCrValues,
);

final List<Map<String, dynamic>> possessionType = createAttributeList(
  possessionTypeValues,
);

final List<Map<String, dynamic>> requirementType = createAttributeList(
  requirementTypeValues,
);

final List<Map<String, dynamic>> commercialUnitTypeList = createAttributeList(
  commercialUnitTypeValues,
);

final List<Map<String, dynamic>> commercialLeasingTypeList =
    createAttributeList(commercialLeasingTypeValues);

final List<Map<String, dynamic>> timelineTypeList = createAttributeList(
  timelineTypeValues,
);

final List<Map<String, dynamic>> fundingSourceList = createAttributeList(
  fundingSourceValues,
);

final List<Map<String, dynamic>> ethnicityList = createAttributeList(
  ethnicityValues,
);

final List<Map<String, dynamic>> stageTypeList = createAttributeList(
  stageTypeValues,
);

final List<Map<String, dynamic>> finalStageDetailsList = createAttributeList(
  finalStageDetailsValues,
);

final List<Map<String, dynamic>> channelPartnerActivityList =
    createAttributeList(channelPartnerActivityValues);

final List<Map<String, dynamic>> directWalkingSubSourceList =
    createAttributeList(directWalkingSubSourceValues);

final List<Map<String, dynamic>> subSubSourceList = createAttributeList(
  subSubSourceValues,
);

final List<Map<String, dynamic>> lostReasonList = createAttributeList(
  lostReasonValues,
);

// CHANNEL PARTNER

final List<Map<String, dynamic>> designationList = createAttributeList(
  designationValues,
);

final List<Map<String, dynamic>> specialityList = createAttributeList(
  specialityValues,
);

final List<Map<String, dynamic>> companyTypeList = createAttributeList(
  companyTypeValues,
);

final List<Map<String, dynamic>> firmTypeList = createAttributeList(
  firmTypeValues,
);

final List<Map<String, dynamic>> type = createAttributeList(
  channelPartnerTypeValues,
);
// INVENTORY
// STATIC LISTS

final List<Map<String, dynamic>> flatTypeList = createAttributeList(
  flatTypeValues,
);

// STATIC LISTS FOR FLAT CONFIGURATION

final List<Map<String, dynamic>> residentialFlatList = createAttributeList(
  residentialFlatValues,
);

final List<Map<String, dynamic>> commercialFlatList = createAttributeList(
  commercialFlatValues,
);

// STATIC LISTS FOR FLAT STATUS

final List<Map<String, dynamic>> flatStatusList = createAttributeList(
  flatStatusValues,
);

final List<Map<String, dynamic>> flatStatusListWithOtherOptions =
    createAttributeList(flatStatusWithOtherOptionsValues);

final List<Map<String, dynamic>> flatFacingList = createAttributeList(
  flatFacingValues,
);

// Legal
// Litigation

final List<Map<String, dynamic>> caseTypeList = createAttributeList(
  caseTypeValues,
);

final List<Map<String, dynamic>> courtTypeList = createAttributeList(
  courtTypeValues,
);

// Company Master

final List<Map<String, dynamic>> genderList = createAttributeList(genderValues);

final List<Map<String, dynamic>> materialRequisitionStagesList =
    createAttributeList(materialRequisitionStagesValues);

final List<Map<String, dynamic>> materialRequisitionStatusList =
    createAttributeList(materialRequisitionStatusValues);

final List<Map<String, dynamic>> projectStatusList = createAttributeList(
  projectStatusValues,
);

final List<Map<String, dynamic>> callStatus = createAttributeList(
  callStatusValues,
);

final List<Map<String, dynamic>> statusModeList = createAttributeList(
  statusModeValues,
);

final List<Map<String, dynamic>> platformTypeList = createAttributeList(
  platformTypeValues,
);

final List<Map<String, dynamic>> moduleTypeList = createAttributeList(
  moduleTypeValues,
);

final List<Map<String, dynamic>> ibmObmRangeFilter = createAttributeList(
  ibmObmRangeFilterValues,
);

final List<Map<String, dynamic>> inwardOutwardDocumentType =
    createAttributeList(inwardOutwardDocumentTypeValues);

final List<Map<String, dynamic>> inwardOutwardDeliveryMode =
    createAttributeList(inwardOutwardDeliveryModeValues);

final List<Map<String, dynamic>> inwardOutwardDeliveryStatus =
    createAttributeList(inwardOutwardDeliveryStatusValues);

final List<Map<String, dynamic>> ibmObmReportType = createAttributeList(
  ibmObmReportTypeValues,
);

final List<Map<String, dynamic>> year = createAttributeList(yearValues);

final List<Map<String, dynamic>> supportList = createAttributeList(
  supportValues,
);

final List<Map<String, dynamic>> paymentModeList = createAttributeList(
  paymentModeValues,
);

final List<Map<String, dynamic>> paymentTypeList = createAttributeList(
  paymentTypeValues,
);

final List<Map<String, dynamic>> financialYearList = createAttributeList(
  financialYearValues,
);

final List<Map<String, dynamic>> paymentReceivedFormList = createAttributeList(
  paymentReceivedFormValues,
);

final List<Map<String, dynamic>> paymentForList = createAttributeList(
  paymentForValues,
);

final List<Map<String, dynamic>> unitSqFtLumsumList = createAttributeList(
  unitSqFtLumsumValues,
);

final List<Map<String, dynamic>> propertyTypeList = createAttributeList(
  propertyTypeValues,
);

final List<Map<String, dynamic>> tenureList = createAttributeList(tenureValues);

final List<Map<String, dynamic>> tenurePaymentModeList = createAttributeList(
  tenderPaymentModeValues,
);
