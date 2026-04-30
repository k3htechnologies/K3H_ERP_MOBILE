part of 'finalize_vendor_cubit.dart';

enum FinalizeVendorViewType { getQuotation, finalizedList, editVendor }

final class FinalizeVendorState extends BaseState {
  final FinalizeVendorViewType viewType;
  final Set<int>? selectedVendorIndex;
  final FinalizeVendorForComparisonModel? selectedVendor;
  final List<RequisitionVendorModel> selctedVendorList;
  final List<RequisitionVendorModel> vendorSelectionForEnquiryList;
  final List<FinalizeVendorForComparisonModel> vendorFinalisationForComparison;
  final int totalNumberOfRecord;
  final String searchText;
  final List<RequisitionVendorModel> allAvailableVendorList;
  final List<MaterialRequisitionDetailModel>? materials;

  const FinalizeVendorState({
    super.isLoading,
    required this.viewType,
    this.selectedVendor,
    required this.selctedVendorList,
    required this.vendorSelectionForEnquiryList,
    required this.vendorFinalisationForComparison,
    required this.totalNumberOfRecord,
    required this.searchText,
    required this.allAvailableVendorList,
    this.materials,
    this.selectedVendorIndex,
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
      materials: [],
    );
  }
  FinalizeVendorState copyWith({
    bool? isLoading,
    FinalizeVendorViewType? viewType,
    FinalizeVendorForComparisonModel? selectedVendor,
    List<RequisitionVendorModel>? selctedVendorList,
    List<RequisitionVendorModel>? vendorSelectionForEnquiryList,
    List<FinalizeVendorForComparisonModel>? vendorFinalisationForComparison,
    int? totalNumberOfRecord,
    String? searchText,
    List<RequisitionVendorModel>? allAvailableVendorList,
    List<MaterialRequisitionDetailModel>? materials,
    Set<int>? selectedVendorIndex,
  }) {
    return FinalizeVendorState(
      isLoading: isLoading ?? this.isLoading,
      viewType: viewType ?? this.viewType,
      selectedVendor: selectedVendor ?? this.selectedVendor,
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
      materials: materials ?? this.materials,
      selectedVendorIndex: selectedVendorIndex ?? this.selectedVendorIndex,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    viewType,
    selectedVendor,
    selctedVendorList,
    vendorSelectionForEnquiryList,
    vendorFinalisationForComparison,
    totalNumberOfRecord,
    allAvailableVendorList,
    materials,
    selectedVendorIndex,
  ];
}
