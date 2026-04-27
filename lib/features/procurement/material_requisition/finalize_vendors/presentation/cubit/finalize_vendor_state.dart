part of 'finalize_vendor_cubit.dart';

enum FinalizeVendorViewType { getQuotation, finalizedList, editVendor }

final class FinalizeVendorState extends BaseState {
  final FinalizeVendorViewType viewType;
  final List<RequisitionVendorModel> selctedVendorList;
  final List<RequisitionVendorModel> vendorSelectionForEnquiryList;
  final List<FinalizeVendorForComparisonModel> vendorFinalisationForComparison;
  final int totalNumberOfRecord;
  final String searchText;
  final List<RequisitionVendorModel> allAvailableVendorList;

  const FinalizeVendorState({
    super.isLoading,
    required this.viewType,
    required this.selctedVendorList,
    required this.vendorSelectionForEnquiryList,
    required this.vendorFinalisationForComparison,
    required this.totalNumberOfRecord,
    required this.searchText,
    required this.allAvailableVendorList,
  });
  factory FinalizeVendorState.initial() {
    return const FinalizeVendorState(
      isLoading: false,
      viewType: FinalizeVendorViewType.finalizedList,
      selctedVendorList: [],
      vendorSelectionForEnquiryList: [],
      vendorFinalisationForComparison: [],
      totalNumberOfRecord: 0,
      searchText: "",
      allAvailableVendorList: [],
    );
  }
  FinalizeVendorState copyWith({
    bool? isLoading,
    FinalizeVendorViewType? viewType,
    List<RequisitionVendorModel>? selctedVendorList,
    List<RequisitionVendorModel>? vendorSelectionForEnquiryList,
    List<FinalizeVendorForComparisonModel>? vendorFinalisationForComparison,
    int? totalNumberOfRecord,
    String? searchText,
    List<RequisitionVendorModel>? allAvailableVendorList,
  }) {
    return FinalizeVendorState(
      isLoading: isLoading ?? this.isLoading,
      viewType: viewType ?? this.viewType,
      selctedVendorList: selctedVendorList ?? this.selctedVendorList,
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
    viewType,
    selctedVendorList,
    vendorSelectionForEnquiryList,
    vendorFinalisationForComparison,
    totalNumberOfRecord,
    allAvailableVendorList,
  ];
}
