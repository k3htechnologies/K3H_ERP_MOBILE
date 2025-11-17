part of 'terms_and_condition_cubit.dart';

class TermsAndConditionState extends BaseState {
  final List<TermsAndConditionModel> materialRequisitionTermsAndConditionsList;
  final List<TermsAndConditionModel> bookingTermsAndConditionsList;
  final int materialRequisitionTotalNumberOfRecordTermsAndConditions;
  final int materialRequisitionCurrentPageTermsAndConditions;
  final int bookingTotalNumberOfRecordTermsAndConditions;
  final int bookingCurrentPageTermsAndConditions;
  final String searchTextBooking;
  final String currentSortColumnBooking;
  final String currentSortDirectionBooking;
  final String searchTextMaterialRequisition;
  final String currentSortColumnMaterialRequisition;
  final String currentSortDirectionMaterialRequisition;

  const TermsAndConditionState({
    super.isLoading,
    required this.materialRequisitionTermsAndConditionsList,
    required this.bookingTermsAndConditionsList,
    required this.materialRequisitionTotalNumberOfRecordTermsAndConditions,
    required this.materialRequisitionCurrentPageTermsAndConditions,
    required this.bookingTotalNumberOfRecordTermsAndConditions,
    required this.bookingCurrentPageTermsAndConditions,
    required this.searchTextBooking,
    required this.currentSortColumnBooking,
    required this.currentSortDirectionBooking,
    required this.searchTextMaterialRequisition,
    required this.currentSortColumnMaterialRequisition,
    required this.currentSortDirectionMaterialRequisition,
  });

  factory TermsAndConditionState.initial() => TermsAndConditionState(
    materialRequisitionTermsAndConditionsList: [],
    bookingTermsAndConditionsList: [],
    materialRequisitionTotalNumberOfRecordTermsAndConditions: 0,
    materialRequisitionCurrentPageTermsAndConditions: 1,
    bookingTotalNumberOfRecordTermsAndConditions: 0,
    bookingCurrentPageTermsAndConditions: 1,
    isLoading: true,
    searchTextBooking: "",
    currentSortColumnBooking: "Created Date",
    currentSortDirectionBooking: "DESC",
    searchTextMaterialRequisition: "",
    currentSortColumnMaterialRequisition: "Created Date",
    currentSortDirectionMaterialRequisition: "DESC",
  );

  TermsAndConditionState copyWith({
    bool? isLoading,
    List<TermsAndConditionModel>? materialRequisitionTermsAndConditionsList,
    List<TermsAndConditionModel>? bookingTermsAndConditionsList,
    int? materialRequisitionTotalNumberOfRecordTermsAndConditions,
    int? materialRequisitionCurrentPageTermsAndConditions,
    int? bookingTotalNumberOfRecordTermsAndConditions,
    int? bookingCurrentPageTermsAndConditions,
    String? searchTextBooking,
    String? currentSortColumnBooking,
    String? currentSortDirectionBooking,
    String? searchTextMaterialRequisition,
    String? currentSortColumnMaterialRequisition,
    String? currentSortDirectionMaterialRequisition,
  }) {
    return TermsAndConditionState(
      isLoading: isLoading ?? this.isLoading,
      materialRequisitionTermsAndConditionsList:
      materialRequisitionTermsAndConditionsList ??
          this.materialRequisitionTermsAndConditionsList,
      bookingTermsAndConditionsList:
      bookingTermsAndConditionsList ?? this.bookingTermsAndConditionsList,
      materialRequisitionTotalNumberOfRecordTermsAndConditions:
      materialRequisitionTotalNumberOfRecordTermsAndConditions ??
          this.materialRequisitionTotalNumberOfRecordTermsAndConditions,
      materialRequisitionCurrentPageTermsAndConditions:
      materialRequisitionCurrentPageTermsAndConditions ??
          this.materialRequisitionCurrentPageTermsAndConditions,
      bookingTotalNumberOfRecordTermsAndConditions:
      bookingTotalNumberOfRecordTermsAndConditions ??
          this.bookingTotalNumberOfRecordTermsAndConditions,
      bookingCurrentPageTermsAndConditions:
      bookingCurrentPageTermsAndConditions ??
          this.bookingCurrentPageTermsAndConditions,
      searchTextBooking: searchTextBooking ?? this.searchTextBooking,
      currentSortColumnBooking: currentSortColumnBooking ?? this.currentSortColumnBooking,
      currentSortDirectionBooking: currentSortDirectionBooking ?? this.currentSortDirectionBooking,
      searchTextMaterialRequisition: searchTextMaterialRequisition ?? this.searchTextMaterialRequisition,
      currentSortColumnMaterialRequisition: currentSortColumnMaterialRequisition ?? this.currentSortColumnMaterialRequisition,
      currentSortDirectionMaterialRequisition: currentSortDirectionMaterialRequisition ?? this.currentSortDirectionMaterialRequisition,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    materialRequisitionTermsAndConditionsList,
    bookingTermsAndConditionsList,
    materialRequisitionTotalNumberOfRecordTermsAndConditions,
    materialRequisitionCurrentPageTermsAndConditions,
    bookingTotalNumberOfRecordTermsAndConditions,
    bookingCurrentPageTermsAndConditions,
    searchTextBooking,
    currentSortColumnBooking,
    currentSortDirectionBooking,
    searchTextMaterialRequisition,
    currentSortColumnMaterialRequisition,
    currentSortDirectionMaterialRequisition,
  ];
}
