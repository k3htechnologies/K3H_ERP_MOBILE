import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/data/model/loan_details.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track_booking_files.model.dart';

class LoanDetailsState extends BaseState {
  final BookingLoanDetailsModel? bankLoanDetails;
  final List<PayTrackBookingFilesModel> bankDocumentList;
  final int currentPage;
  final int totalNumberOfRecord;
  final String searchText;

  const LoanDetailsState({
    super.isLoading,
    this.bankLoanDetails,
    required this.bankDocumentList,
    required this.currentPage,
    required this.totalNumberOfRecord,
    required this.searchText,
  });

  factory LoanDetailsState.initial() => LoanDetailsState(
    bankLoanDetails: null,
    bankDocumentList: [],
    currentPage: 1,
    totalNumberOfRecord: 0,
    searchText: "",
    isLoading: true,
  );

  LoanDetailsState copyWith({
    bool? isLoading,
    BookingLoanDetailsModel? bankLoanDetails,
    List<PayTrackBookingFilesModel>? bankDocumentList,
    int? currentPage,
    int? totalNumberOfRecord,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return LoanDetailsState(
      bankDocumentList: bankDocumentList ?? this.bankDocumentList,
      bankLoanDetails: bankLoanDetails ?? this.bankLoanDetails,
      currentPage: currentPage ?? this.currentPage,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    bankLoanDetails,
    bankDocumentList,
    currentPage,
    totalNumberOfRecord,
  ];
}
