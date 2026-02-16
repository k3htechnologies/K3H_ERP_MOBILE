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
  final List<EnquiryFollowUpModel> enquiryFollowUpList; // ADD THIS

  const EnquiryState({
    super.isLoading,
    required this.enquiryList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    this.selectedNationality = 'Indian',
    this.channelPartnerModel,
    this.enquiryFollowUpList = const [], // ADD THIS
  });

  factory EnquiryState.initial() => const EnquiryState(
    isLoading: true,
    enquiryList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    selectedNationality: 'Indian',
    channelPartnerModel: null,
    enquiryFollowUpList: [], // ADD THIS
  );

  EnquiryState copyWith({
    bool? isLoading,
    List<EnquiryModel>? enquiryList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? selectedNationality,
    String? searchText,
    ChannelPartnerModel? channelPartnerModel,
    bool clearChannelPartner = false,
    List<EnquiryFollowUpModel>? enquiryFollowUpList, // ADD THIS
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
      enquiryFollowUpList:
          enquiryFollowUpList ?? this.enquiryFollowUpList, // ADD THIS
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
    enquiryFollowUpList, // ADD THIS
  ];
}
