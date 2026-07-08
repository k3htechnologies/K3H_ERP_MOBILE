import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/data/model/loan_details.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track_booking_files.model.dart';

class LoanDetailsState extends BaseState {
  final BookingLoanDetailsModel? bankLoanDetails;
  final List<BookingLoanDetailsModel> bankDetailsList;
  final List<BookingLoanDetailsModel> bankDocuments;
  final List<PayTrackBookingFilesModel> bankDocumentList;
  final int currentPage;
  final int totalNumberOfRecord;
  final String searchText;
  final Map<int, List<PayTrackBookingFilesModel>> bankDocumentMap;

  const LoanDetailsState({
    super.isLoading,
    this.bankLoanDetails,
    required this.bankDetailsList,
    required this.bankDocumentList,
    required this.bankDocuments,
    required this.currentPage,
    required this.totalNumberOfRecord,
    required this.searchText,
    required this.bankDocumentMap,
  });

  factory LoanDetailsState.initial() => LoanDetailsState(
    bankLoanDetails: null,
    bankDocumentList: [],
    bankDetailsList: [],
    bankDocuments: [],
    currentPage: 1,
    totalNumberOfRecord: 0,
    searchText: "",
    isLoading: true,
    bankDocumentMap: {},
  );

  LoanDetailsState copyWith({
    bool? isLoading,
    BookingLoanDetailsModel? bankLoanDetails,
    List<BookingLoanDetailsModel>? bankDetailsList,
    List<PayTrackBookingFilesModel>? bankDocumentList,
    List<BookingLoanDetailsModel>? bankDocuments,
    int? currentPage,
    int? totalNumberOfRecord,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
    Map<int, List<PayTrackBookingFilesModel>>? bankDocumentMap,
  }) {
    return LoanDetailsState(
      bankDocumentList: bankDocumentList ?? this.bankDocumentList,
      bankDetailsList: bankDetailsList ?? this.bankDetailsList,
      bankLoanDetails: bankLoanDetails ?? this.bankLoanDetails,
      bankDocuments: bankDocuments ?? this.bankDocuments,
      currentPage: currentPage ?? this.currentPage,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      searchText: searchText ?? this.searchText,
      bankDocumentMap: bankDocumentMap ?? this.bankDocumentMap,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    bankLoanDetails,
    bankDetailsList,
    bankDocumentList,
    bankDocuments,
    currentPage,
    totalNumberOfRecord,
    bankDocumentMap,
  ];
}
