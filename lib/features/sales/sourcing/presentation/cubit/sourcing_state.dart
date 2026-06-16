part of 'sourcing_cubit.dart';

class SourcingState extends BaseState {
  final List<ChannelPartnerModel> channelPartnerList;
  final int totalNumberOfRecordCP;
  final int currentPageCp;
  final List<SourcingModel> sourcingList;
  final String searchText;
  final int currentTabIndex;
  final String selectedFilter;
  final String filterByCompanyName;
  final String filterByDesignation;
  final String filterByFirmType;
  final String filterByType;
  final String filterCPCode;
  final String filterByCPName;
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

  const SourcingState({
    super.isLoading,
    required this.channelPartnerList,
    required this.totalNumberOfRecordCP,
    required this.currentPageCp,
    required this.sourcingList,
    required this.searchText,
    required this.currentTabIndex,
    required this.selectedFilter,
    required this.filterByCompanyName,
    required this.filterByDesignation,
    required this.filterByFirmType,
    required this.filterByType,
    required this.filterCPCode,
    required this.filterByCPName,
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
  });

  factory SourcingState.initial() => SourcingState(
    channelPartnerList: [],
    totalNumberOfRecordCP: 0,
    currentPageCp: 1,
    sourcingList: [],
    searchText: "",
    isLoading: true,
    currentTabIndex: 0,
    selectedFilter: "ALL",
    currentSortColumn: "",
    currentSortDirection: "",
    filterCPCode: "",
    filterByCompanyName: "",
    filterByDesignation: "",
    filterByFirmType: "",
    filterByType: "",
    filterByCPName: "",
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
  );

  SourcingState copyWith({
    bool? isLoading,
    List<ChannelPartnerModel>? channelPartnerList,
    int? totalNumberOfRecordCP,
    int? currentPageCp,
    List<SourcingModel>? sourcingList,
    String? searchText,
    int? currentTabIndex,
    String? selectedFilter,
    String? currentSortColumn,
    String? currentSortDirection,
    String? filterByCompanyName,
    String? filterByDesignation,
    String? filterByFirmType,
    String? filterByType,
    String? filterCPCode,
    String? filterByCPName,
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
  }) {
    return SourcingState(
      isLoading: isLoading ?? this.isLoading,
      channelPartnerList: channelPartnerList ?? this.channelPartnerList,
      totalNumberOfRecordCP:
          totalNumberOfRecordCP ?? this.totalNumberOfRecordCP,
      currentPageCp: currentPageCp ?? this.currentPageCp,
      sourcingList: sourcingList ?? this.sourcingList,
      searchText: searchText ?? this.searchText,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,

      filterByCompanyName: filterByCompanyName ?? this.filterByCompanyName,
      filterByDesignation: filterByDesignation ?? this.filterByDesignation,
      filterByFirmType: filterByFirmType ?? this.filterByFirmType,
      filterByType: filterByType ?? this.filterByType,
      filterCPCode: filterCPCode ?? this.filterCPCode,
      filterByCPName: filterByCPName ?? this.filterByCPName,
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
      filterByNoOfIBM: filterByNoOfIBM ?? this.filterByNoOfIBM,
      filterByNoOfOBM: filterByNoOfOBM ?? this.filterByNoOfOBM,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    channelPartnerList,
    totalNumberOfRecordCP,
    currentPageCp,
    sourcingList,
    searchText,
    currentTabIndex,
    selectedFilter,

    filterByCompanyName,
    filterByDesignation,
    filterByFirmType,
    filterByType,
    filterCPCode,
    filterByCPName,
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
  ];
}
