part of 'terms_and_conditions_cubit.dart';

class TermsAndConditionsState extends BaseState {
  final List<TermsAndConditionsModel> materialRequisitionTermsAndConditionsList;
  final List<TermsAndConditionsModel> bookingTermsAndConditionsList;
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
  final int currentTabIndex;

  const TermsAndConditionsState({
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
    required this.currentTabIndex,
  });

  factory TermsAndConditionsState.initial() => TermsAndConditionsState(
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
    currentTabIndex: 0,
  );

  TermsAndConditionsState copyWith({
    bool? isLoading,
    List<TermsAndConditionsModel>? materialRequisitionTermsAndConditionsList,
    List<TermsAndConditionsModel>? bookingTermsAndConditionsList,
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
    int? currentTabIndex,
  }) {
    return TermsAndConditionsState(
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
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
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
    currentTabIndex,
  ];
}
