part of 'channel_partner_cubit.dart';

class ChannelPartnerState extends BaseState {
  final List<ChannelPartnerModel> channelPartnerList;
  final ChannelPartnerDashboardModel? channelPartnerDashboardModel;
  final List<ChannelPartnerDashboardModel> channelPartnerDashboardModelList;
  final int totalNumberOfRecord;
  final int currentPage;
  final List<ChannelPartnerAopModel> channelPartnerAopList;
  final int totalNumberOfChannelPartnerAopRecord;
  final int currentChannelPartnerAopPage;

  final String searchText;
  final String filterByCompanyName;
  final String filterByDesignation;
  final String filterByFirmType;
  final String filterByType;
  final String filterByMobileNumber;
  final String filterByOfficeAddress;
  final String filterByGSTNumber;
  final String filterByRERANumber;
  final String filterByPANNumber;
  final String filterByAadhaarNumber;
  final String filterBySpeciality;
  final String filterByCity;
  final String filterByVillage;
  final String filterByNoOfIBM;
  final String filterByNoOfOBM;
  final String currentSortColumn;
  final String currentSortDirection;

  const ChannelPartnerState({
    super.isLoading,
    super.stateType,
    required this.channelPartnerList,
    this.channelPartnerDashboardModel,
    required this.channelPartnerDashboardModelList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.filterByCompanyName,
    required this.filterByDesignation,
    required this.filterByFirmType,
    required this.filterByType,
    required this.filterByMobileNumber,
    required this.filterByOfficeAddress,
    required this.filterByGSTNumber,
    required this.filterByRERANumber,
    required this.filterByPANNumber,
    required this.filterByAadhaarNumber,
    required this.filterBySpeciality,
    required this.filterByCity,
    required this.filterByVillage,
    required this.filterByNoOfIBM,
    required this.filterByNoOfOBM,

    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.channelPartnerAopList,
    required this.totalNumberOfChannelPartnerAopRecord,
    required this.currentChannelPartnerAopPage,
  });

  factory ChannelPartnerState.initial() => ChannelPartnerState(
    channelPartnerList: [],
    channelPartnerDashboardModelList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    filterByCompanyName: "",
    filterByDesignation: "",
    filterByFirmType: "",
    filterByType: "",
    filterByMobileNumber: "",
    filterByOfficeAddress: "",
    filterByGSTNumber: "",
    filterByRERANumber: "",
    filterByPANNumber: "",
    filterByAadhaarNumber: "",
    filterBySpeciality: "",
    filterByCity: "",
    filterByVillage: "",
    filterByNoOfIBM: "",
    filterByNoOfOBM: "",
    isLoading: true,
    currentSortColumn: "",
    currentSortDirection: "",
    channelPartnerAopList: [],
    totalNumberOfChannelPartnerAopRecord: 0,
    currentChannelPartnerAopPage: 1,
  );

  ChannelPartnerState copyWith({
    bool? isLoading,
    StateType? stateType,
    List<ChannelPartnerModel>? channelPartnerList,
    ChannelPartnerDashboardModel? channelPartnerDashboardModel,
    List<ChannelPartnerDashboardModel>? channelPartnerDashboardModelList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,

    String? filterByCompanyName,
    String? filterByDesignation,
    String? filterByFirmType,
    String? filterByType,
    String? filterByMobileNumber,
    String? filterByOfficeAddress,
    String? filterByGSTNumber,
    String? filterByRERANumber,
    String? filterByPANNumber,
    String? filterByAadhaarNumber,
    String? filterBySpeciality,
    String? filterByCity,
    String? filterByVillage,
    String? filterByNoOfIBM,
    String? filterByNoOfOBM,

    String? currentSortColumn,
    String? currentSortDirection,

    List<ChannelPartnerAopModel>? channelPartnerAopList,
    int? totalNumberOfChannelPartnerAopRecord,
    int? currentChannelPartnerAopPage,
  }) {
    return ChannelPartnerState(
      isLoading: isLoading ?? this.isLoading,
      stateType: stateType ?? this.stateType,
      channelPartnerList: channelPartnerList ?? this.channelPartnerList,
      channelPartnerDashboardModel:
          channelPartnerDashboardModel ?? this.channelPartnerDashboardModel,
      channelPartnerDashboardModelList:
          channelPartnerDashboardModelList ??
          this.channelPartnerDashboardModelList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,

      filterByCompanyName: filterByCompanyName ?? this.filterByCompanyName,
      filterByDesignation: filterByDesignation ?? this.filterByDesignation,
      filterByFirmType: filterByFirmType ?? this.filterByFirmType,
      filterByType: filterByType ?? this.filterByType,
      filterByMobileNumber: filterByMobileNumber ?? this.filterByMobileNumber,
      filterByOfficeAddress:
          filterByOfficeAddress ?? this.filterByOfficeAddress,
      filterByGSTNumber: filterByGSTNumber ?? this.filterByGSTNumber,
      filterByRERANumber: filterByRERANumber ?? this.filterByRERANumber,
      filterByPANNumber: filterByPANNumber ?? this.filterByPANNumber,
      filterByAadhaarNumber:
          filterByAadhaarNumber ?? this.filterByAadhaarNumber,
      filterBySpeciality: filterBySpeciality ?? this.filterBySpeciality,
      filterByCity: filterByCity ?? this.filterByCity,
      filterByVillage: filterByVillage ?? this.filterByVillage,

      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      filterByNoOfIBM: filterByNoOfIBM ?? this.filterByNoOfIBM,
      filterByNoOfOBM: filterByNoOfOBM ?? this.filterByNoOfOBM,
      channelPartnerAopList:
          channelPartnerAopList ?? this.channelPartnerAopList,
      totalNumberOfChannelPartnerAopRecord:
          totalNumberOfChannelPartnerAopRecord ??
          this.totalNumberOfChannelPartnerAopRecord,
      currentChannelPartnerAopPage:
          currentChannelPartnerAopPage ?? this.currentChannelPartnerAopPage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    stateType,
    channelPartnerList,
    channelPartnerDashboardModel,
    channelPartnerDashboardModelList,
    totalNumberOfRecord,
    currentPage,
    searchText,

    filterByCompanyName,
    filterByDesignation,
    filterByFirmType,
    filterByType,
    filterByMobileNumber,
    filterByOfficeAddress,
    filterByGSTNumber,
    filterByRERANumber,
    filterByPANNumber,
    filterByAadhaarNumber,
    filterBySpeciality,
    filterByCity,
    filterByVillage,
    filterByNoOfIBM,
    filterByNoOfOBM,

    currentSortColumn,
    currentSortDirection,
    channelPartnerAopList,
    currentChannelPartnerAopPage,
    totalNumberOfChannelPartnerAopRecord,
  ];
}
