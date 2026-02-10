part of 'enquiry_cubit.dart';

class EnquiryState extends BaseState {
  final List<EnquiryModel> enquiryList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;

  const EnquiryState({
    super.isLoading,
    required this.enquiryList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
  });

  factory EnquiryState.initial() => EnquiryState(
    isLoading: true,
    enquiryList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
  );

  EnquiryState copyWith({
    bool? isLoading,
    List<EnquiryModel>? enquiryList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
  }) {
    return EnquiryState(
      isLoading: isLoading ?? this.isLoading,
      enquiryList: enquiryList ?? this.enquiryList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    enquiryList,
    totalNumberOfRecord,
    currentPage,
    searchText,
  ];
}

