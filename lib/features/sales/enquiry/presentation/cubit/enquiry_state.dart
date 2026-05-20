import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry_followup.model.dart';

class EnquiryState extends BaseState {
  final List<EnquiryModel> enquiryList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;

  final List<String> options = const ['Indian', 'NRI'];
  final String selectedNationality;
  final ChannelPartnerModel? channelPartnerModel;
  final List<EnquiryFollowUpModel> enquiryFollowUpList;

  final String currentSortColumn;
  final String currentSortDirection;

  final DateTime? filterStartDate;
  final DateTime? filterEndDate;

  final String filterSystemCode;
  final String filterMobileNumber;
  final String filterBudget;
  final String filterRequirementType;
  final String filterSource;
  final String filterSubSource;
  final String filterChannelPartnerMobile;
  final String filterNationality;
  final String filterCurrentLocation;
  final String filterCustomerClassification;
  final String filterEthnicity;
  final String filterSalesAdvisor;
  final String filterSourcingManager;
  final String filterAccommodation;
  final String filterFollowUpDays;
  final String filterFinalStage;

  final EnquiryModel? currentEnquiryDetails;

  final bool isFetchingEnquiryDetails;
  final bool isFetchingChannelPartners;

  const EnquiryState({
    super.isLoading,
    required this.enquiryList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    this.selectedNationality = 'Indian',
    this.channelPartnerModel,
    this.enquiryFollowUpList = const [],
    this.currentSortColumn = "",
    this.currentSortDirection = "",
    this.filterStartDate,
    this.filterEndDate,
    this.filterSystemCode = "",
    this.filterMobileNumber = "",
    this.filterBudget = "",
    this.filterRequirementType = "",
    this.filterSource = "",
    this.filterSubSource = "",
    this.filterChannelPartnerMobile = "",
    this.filterNationality = "",
    this.filterCurrentLocation = "",
    this.filterCustomerClassification = "",
    this.filterEthnicity = "",
    this.filterSalesAdvisor = "",
    this.filterSourcingManager = "",
    this.filterAccommodation = "",
    this.filterFollowUpDays = "",
    this.filterFinalStage = "",
    this.currentEnquiryDetails,
    this.isFetchingEnquiryDetails = false,
    this.isFetchingChannelPartners = false,
  });

  factory EnquiryState.initial() => const EnquiryState(
    isLoading: true,
    enquiryList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    selectedNationality: 'Indian',
    channelPartnerModel: null,
    enquiryFollowUpList: [],
    currentSortColumn: "",
    currentSortDirection: "",
    filterStartDate: null,
    filterEndDate: null,
    filterSystemCode: "",
    filterMobileNumber: "",
    filterBudget: "",
    filterRequirementType: "",
    filterSource: "",
    filterSubSource: "",
    filterChannelPartnerMobile: "",
    filterNationality: "",
    filterCurrentLocation: "",
    filterCustomerClassification: "",
    filterEthnicity: "",
    filterSalesAdvisor: "",
    filterSourcingManager: "",
    filterAccommodation: "",
    filterFollowUpDays: "",
    filterFinalStage: "",
    currentEnquiryDetails: null,
    isFetchingEnquiryDetails: false,
    isFetchingChannelPartners: false,
  );

  static const _noChange = Object();

  EnquiryState copyWith({
    bool? isLoading,
    List<EnquiryModel>? enquiryList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? selectedNationality,
    String? searchText,
    ChannelPartnerModel? channelPartnerModel,
    bool clearChannelPartner = false,
    List<EnquiryFollowUpModel>? enquiryFollowUpList,
    String? currentSortColumn,
    String? currentSortDirection,
    Object? filterStartDate = _noChange,
    Object? filterEndDate = _noChange,
    String? filterSystemCode,
    String? filterMobileNumber,
    String? filterBudget,
    String? filterRequirementType,
    String? filterSource,
    String? filterSubSource,
    String? filterChannelPartnerMobile,
    String? filterNationality,
    String? filterCurrentLocation,
    String? filterCustomerClassification,
    String? filterEthnicity,
    String? filterSalesAdvisor,
    String? filterSourcingManager,
    String? filterAccommodation,
    String? filterFollowUpDays,
    String? filterFinalStage,
    Object? currentEnquiryDetails = _noChange,
    Object? isFetchingEnquiryDetails = _noChange,
    Object? isFetchingChannelPartners = _noChange,
  }) {
    return EnquiryState(
      isLoading: isLoading ?? this.isLoading,
      enquiryList: enquiryList ?? this.enquiryList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      selectedNationality: selectedNationality ?? this.selectedNationality,
      searchText: searchText ?? this.searchText,

      channelPartnerModel:
          clearChannelPartner
              ? null
              : (channelPartnerModel ?? this.channelPartnerModel),

      enquiryFollowUpList: enquiryFollowUpList ?? this.enquiryFollowUpList,

      currentSortColumn: currentSortColumn ?? this.currentSortColumn,

      currentSortDirection: currentSortDirection ?? this.currentSortDirection,

      filterStartDate:
          filterStartDate == _noChange
              ? this.filterStartDate
              : filterStartDate as DateTime?,

      filterEndDate:
          filterEndDate == _noChange
              ? this.filterEndDate
              : filterEndDate as DateTime?,

      filterSystemCode: filterSystemCode ?? this.filterSystemCode,

      filterMobileNumber: filterMobileNumber ?? this.filterMobileNumber,

      filterBudget: filterBudget ?? this.filterBudget,

      filterRequirementType:
          filterRequirementType ?? this.filterRequirementType,

      filterSource: filterSource ?? this.filterSource,

      filterChannelPartnerMobile:
          filterChannelPartnerMobile ?? this.filterChannelPartnerMobile,

      filterNationality: filterNationality ?? this.filterNationality,

      filterCurrentLocation:
          filterCurrentLocation ?? this.filterCurrentLocation,

      filterCustomerClassification:
          filterCustomerClassification ?? this.filterCustomerClassification,

      filterEthnicity: filterEthnicity ?? this.filterEthnicity,

      filterSalesAdvisor: filterSalesAdvisor ?? this.filterSalesAdvisor,

      filterSourcingManager:
          filterSourcingManager ?? this.filterSourcingManager,

      filterAccommodation: filterAccommodation ?? this.filterAccommodation,

      filterFollowUpDays: filterFollowUpDays ?? this.filterFollowUpDays,

      filterFinalStage: filterFinalStage ?? this.filterFinalStage,
      filterSubSource: filterSubSource ?? this.filterSubSource,

      currentEnquiryDetails:
          currentEnquiryDetails == _noChange
              ? this.currentEnquiryDetails
              : currentEnquiryDetails as EnquiryModel?,

      isFetchingEnquiryDetails:
          isFetchingEnquiryDetails == _noChange
              ? this.isFetchingEnquiryDetails
              : isFetchingEnquiryDetails as bool,

      isFetchingChannelPartners:
          isFetchingChannelPartners == _noChange
              ? this.isFetchingChannelPartners
              : isFetchingChannelPartners as bool,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    enquiryList,
    totalNumberOfRecord,
    selectedNationality,
    currentPage,
    searchText,
    channelPartnerModel,
    enquiryFollowUpList,
    currentSortColumn,
    currentSortDirection,
    filterStartDate,
    filterEndDate,
    filterSystemCode,
    filterMobileNumber,
    filterBudget,
    filterRequirementType,
    filterSource,
    filterSubSource,
    filterChannelPartnerMobile,
    filterNationality,
    filterCurrentLocation,
    filterCustomerClassification,
    filterEthnicity,
    filterSalesAdvisor,
    filterSourcingManager,
    filterAccommodation,
    filterFollowUpDays,
    filterFinalStage,
    currentEnquiryDetails,
    isFetchingEnquiryDetails,
    isFetchingChannelPartners,
  ];
}
