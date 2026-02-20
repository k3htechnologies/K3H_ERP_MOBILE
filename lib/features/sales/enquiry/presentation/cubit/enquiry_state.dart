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
  final String filterFollowUpDays;
  final String filterRequirement;
  final String filterStage;

  // ✅ ENQUIRY DETAILS ONLY
  final EnquiryModel? currentEnquiryDetails;
  final bool isFetchingEnquiryDetails;

  const EnquiryState({
    super.isLoading,
    required this.enquiryList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    this.selectedNationality = 'Indian',
    this.channelPartnerModel,
    this.enquiryFollowUpList = const [],
    this.currentSortColumn = "Created Date",
    this.currentSortDirection = "DESC",
    this.filterStartDate,
    this.filterEndDate,
    this.filterSystemCode = "",
    this.filterMobileNumber = "",
    this.filterFollowUpDays = "",
    this.filterRequirement = "",
    this.filterStage = "",

    // ✅ ENQUIRY DETAILS DEFAULTS
    this.currentEnquiryDetails,
    this.isFetchingEnquiryDetails = false,
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
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    filterStartDate: null,
    filterEndDate: null,
    filterSystemCode: "",
    filterMobileNumber: "",
    filterFollowUpDays: "",
    filterRequirement: "",
    filterStage: "",

    // ✅ ENQUIRY DETAILS DEFAULTS
    currentEnquiryDetails: null,
    isFetchingEnquiryDetails: false,
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
    String? filterFollowUpDays,
    String? filterRequirement,
    String? filterStage,

    // ✅ ENQUIRY DETAILS IN COPYWITH
    Object? currentEnquiryDetails = _noChange,
    Object? isFetchingEnquiryDetails = _noChange,
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
      filterFollowUpDays: filterFollowUpDays ?? this.filterFollowUpDays,
      filterRequirement: filterRequirement ?? this.filterRequirement,
      filterStage: filterStage ?? this.filterStage,

      // ✅ ENQUIRY DETAILS
      currentEnquiryDetails:
          currentEnquiryDetails == _noChange
              ? this.currentEnquiryDetails
              : currentEnquiryDetails as EnquiryModel?,
      isFetchingEnquiryDetails:
          isFetchingEnquiryDetails == _noChange
              ? this.isFetchingEnquiryDetails
              : isFetchingEnquiryDetails as bool,
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
    filterFollowUpDays,
    filterRequirement,
    filterStage,

    // ✅ ENQUIRY DETAILS IN PROPS
    currentEnquiryDetails,
    isFetchingEnquiryDetails,
  ];
}
