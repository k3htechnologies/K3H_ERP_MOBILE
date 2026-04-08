part of 'finalize_vendor_cubit.dart';

final class FinalizeVendorState extends BaseState {
  final List<RequisitionVendorModel> vendorSelectionForEnquiryList;
  final int totalNumberOfRecord;
  final String searchText;
  final List<RequisitionVendorModel> allAvailableVendorList;
  const FinalizeVendorState({
    super.isLoading,
    required this.vendorSelectionForEnquiryList,
    required this.totalNumberOfRecord,
    required this.searchText,
    required this.allAvailableVendorList,
  });
  factory FinalizeVendorState.initial() {
    return const FinalizeVendorState(
      isLoading: false,
      vendorSelectionForEnquiryList: [],
      totalNumberOfRecord: 0,
      searchText: "",
      allAvailableVendorList: [],
    );
  }
  FinalizeVendorState copyWith({
    bool? isLoading,
    List<RequisitionVendorModel>? vendorSelectionForEnquiryList,
    int? totalNumberOfRecord,
    String? searchText,
    List<RequisitionVendorModel>? allAvailableVendorList,
  }) {
    return FinalizeVendorState(
      isLoading: isLoading ?? this.isLoading,
      vendorSelectionForEnquiryList:
          vendorSelectionForEnquiryList ?? this.vendorSelectionForEnquiryList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      searchText: searchText ?? this.searchText,
      allAvailableVendorList:
          allAvailableVendorList ?? this.allAvailableVendorList,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    vendorSelectionForEnquiryList,
    totalNumberOfRecord,
    allAvailableVendorList,
  ];
}
