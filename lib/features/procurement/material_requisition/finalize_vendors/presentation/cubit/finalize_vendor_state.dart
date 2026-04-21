part of 'finalize_vendor_cubit.dart';

final class FinalizeVendorState extends BaseState {
  final List<RequisitionVendorModel> vendorSelectionForEnquiryList;
  final List<FinalizeVendorForComparisonModel> vendorFinalisationForComparison;
  final int totalNumberOfRecord;
  final String searchText;
  final List<RequisitionVendorModel> allAvailableVendorList;

  const FinalizeVendorState({
    super.isLoading,
    required this.vendorSelectionForEnquiryList,
    required this.vendorFinalisationForComparison,
    required this.totalNumberOfRecord,
    required this.searchText,
    required this.allAvailableVendorList,
  });
  factory FinalizeVendorState.initial() {
    return const FinalizeVendorState(
      isLoading: false,
      vendorSelectionForEnquiryList: [],
      vendorFinalisationForComparison: [],
      totalNumberOfRecord: 0,
      searchText: "",
      allAvailableVendorList: [],
      
    );
  }
  FinalizeVendorState copyWith({
    bool? isLoading,
    List<RequisitionVendorModel>? vendorSelectionForEnquiryList,
    List<FinalizeVendorForComparisonModel>? vendorFinalisationForComparison,
    int? totalNumberOfRecord,
    String? searchText,
    List<RequisitionVendorModel>? allAvailableVendorList,
    
  }) {
    return FinalizeVendorState(
      isLoading: isLoading ?? this.isLoading,
      vendorSelectionForEnquiryList:
          vendorSelectionForEnquiryList ?? this.vendorSelectionForEnquiryList,
      vendorFinalisationForComparison:
          vendorFinalisationForComparison ??
          this.vendorFinalisationForComparison,
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
    vendorFinalisationForComparison,
    totalNumberOfRecord,
    allAvailableVendorList,
  ];
}
