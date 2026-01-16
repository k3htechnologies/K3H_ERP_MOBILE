part of 'proposed_offer_cubit.dart';

class ProposedOfferState extends BaseState {
  final List<RedevelopmentBuildingModel> buildingList;
  final ExtraCarpetAreaModel? extraCarpetArea;
  final CorpusDetailsModel? corpusDetails;
  final SecurityDepositModel? securityDepositDetails;
  final ShiftingDetailsModel? shiftingDetails;
  final LienToSocietyDetailsModel? lienToSocietyDetails;
  final ParkingAllotmentModel? parkingAllotment;
  final GstOnExistingPlusFreeAreaModel? gstOnExistingPlusFreeArea;
  final ProjectCompletionModel? projectCompletion;
  final List<RentDetailsModel> rentDetails;
  final int totalNumberOfRecordRent;

  const ProposedOfferState({
    super.isLoading,
    required this.buildingList,
    required this.extraCarpetArea,
    required this.corpusDetails,
    required this.securityDepositDetails,
    required this.shiftingDetails,
    required this.lienToSocietyDetails,
    required this.parkingAllotment,
    required this.gstOnExistingPlusFreeArea,
    required this.projectCompletion,
    required this.rentDetails,
    required this.totalNumberOfRecordRent,
  });

  factory ProposedOfferState.initial() => ProposedOfferState(
    buildingList: [],
    isLoading: true,
    extraCarpetArea: null,
    corpusDetails: null,
    securityDepositDetails: null,
    shiftingDetails: null,
    lienToSocietyDetails: null,
    parkingAllotment: null,
    gstOnExistingPlusFreeArea: null,
    projectCompletion: null,
    rentDetails: [],
    totalNumberOfRecordRent: 0,
  );

  ProposedOfferState copyWith({
    bool? isLoading,
    List<RedevelopmentBuildingModel>? buildingList,
    ExtraCarpetAreaModel? extraCarpetArea,
    bool clearExtraCarpet = false,
    CorpusDetailsModel? corpusDetails,
    bool clearCorpus = false,
    SecurityDepositModel? securityDepositDetails,
    bool clearSecurityDeposit = false,
    ShiftingDetailsModel? shiftingDetails,
    bool clearShifting = false,
    LienToSocietyDetailsModel? lienToSocietyDetails,
    bool clearLienToSociety = false,
    ParkingAllotmentModel? parkingAllotment,
    bool clearParkingAllotment = false,
    GstOnExistingPlusFreeAreaModel? gstOnExistingPlusFreeArea,
    bool clearGST = false,
    ProjectCompletionModel? projectCompletion,
    bool clearProjectCompletion = false,
    List<RentDetailsModel>? rentDetails,
    int? totalNumberOfRecordRent,
  }) {
    return ProposedOfferState(
      isLoading: isLoading ?? this.isLoading,
      buildingList: buildingList ?? this.buildingList,
      extraCarpetArea:
          clearExtraCarpet ? null : extraCarpetArea ?? this.extraCarpetArea,
      corpusDetails: clearCorpus ? null : corpusDetails ?? this.corpusDetails,
      securityDepositDetails:
          clearSecurityDeposit
              ? null
              : securityDepositDetails ?? this.securityDepositDetails,
      shiftingDetails:
          clearShifting ? null : shiftingDetails ?? this.shiftingDetails,
      lienToSocietyDetails:
          clearLienToSociety
              ? null
              : lienToSocietyDetails ?? this.lienToSocietyDetails,
      parkingAllotment:
          clearParkingAllotment
              ? null
              : parkingAllotment ?? this.parkingAllotment,
      gstOnExistingPlusFreeArea:
          clearGST
              ? null
              : gstOnExistingPlusFreeArea ?? this.gstOnExistingPlusFreeArea,
      projectCompletion:
          clearProjectCompletion
              ? null
              : projectCompletion ?? this.projectCompletion,
      rentDetails: rentDetails ?? this.rentDetails,
      totalNumberOfRecordRent:
          totalNumberOfRecordRent ?? this.totalNumberOfRecordRent,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    buildingList,
    extraCarpetArea,
    corpusDetails,
    securityDepositDetails,
    shiftingDetails,
    lienToSocietyDetails,
    parkingAllotment,
    gstOnExistingPlusFreeArea,
    projectCompletion,
    rentDetails,
    totalNumberOfRecordRent,
  ];
}
