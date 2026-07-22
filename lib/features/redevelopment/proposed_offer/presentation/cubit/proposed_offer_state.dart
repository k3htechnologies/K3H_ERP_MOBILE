part of 'proposed_offer_cubit.dart';

class ProposedOfferState extends BaseState {
  final List<RedevelopmentBuildingModel> buildingList;
  final int buildingTotalCount;
  final ExtraCarpetAreaModel? extraCarpetArea;
  final CorpusDetailsModel? corpusDetails;
  final SecurityDepositModel? securityDepositDetails;
  final ShiftingDetailsModel? shiftingDetails;
  final LienToSocietyDetailsModel? lienToSocietyDetails;
  final ParkingAllotmentModel? parkingAllotment;
  final GstOnExistingPlusFreeAreaModel? gstOnExistingPlusFreeArea;
  final ProjectCompletionModel? projectCompletion;
  final List<TemporaryAccommodationAlternativeDetailsModel>
  temporaryAccommodationAlternativeDetails;
  final int totalNumberOfRecordTemporaryAccommodationAlternative;
  final List<ReadyReckonerRateDetailsModel> readyReckonerRateDetails;
  final BuildingDetailsModel? carpetPlotDetails;
  final AdditionalInformationDetailsModel? additionalInformationDetails;
  final BankGuaranteeDetailsModel? bankGuaranteeDetails;

  const ProposedOfferState({
    super.isLoading,
    required this.buildingList,
    required this.buildingTotalCount,
    required this.extraCarpetArea,
    required this.corpusDetails,
    required this.securityDepositDetails,
    required this.shiftingDetails,
    required this.lienToSocietyDetails,
    required this.parkingAllotment,
    required this.gstOnExistingPlusFreeArea,
    required this.projectCompletion,
    required this.temporaryAccommodationAlternativeDetails,
    required this.totalNumberOfRecordTemporaryAccommodationAlternative,
    required this.readyReckonerRateDetails,
    required this.carpetPlotDetails,
    required this.additionalInformationDetails,
    required this.bankGuaranteeDetails,
  });

  factory ProposedOfferState.initial() => ProposedOfferState(
    buildingList: [],
    buildingTotalCount: 0,
    isLoading: true,
    extraCarpetArea: null,
    corpusDetails: null,
    securityDepositDetails: null,
    shiftingDetails: null,
    lienToSocietyDetails: null,
    parkingAllotment: null,
    gstOnExistingPlusFreeArea: null,
    projectCompletion: null,
    temporaryAccommodationAlternativeDetails: [],
    totalNumberOfRecordTemporaryAccommodationAlternative: 0,
    readyReckonerRateDetails: [],
    carpetPlotDetails: null,
    additionalInformationDetails: null,
    bankGuaranteeDetails: null,
  );

  ProposedOfferState copyWith({
    bool? isLoading,
    List<RedevelopmentBuildingModel>? buildingList,
    int? buildingTotalCount,
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
    List<TemporaryAccommodationAlternativeDetailsModel>?
    temporaryAccommodationAlternativeDetails,
    int? totalNumberOfRecordTemporaryAccommodationAlternative,
    List<ReadyReckonerRateDetailsModel>? readyReckonerRateDetails,

    BuildingDetailsModel? carpetPlotDetails,
    bool clearCarpetPlotDetails = false,

    AdditionalInformationDetailsModel? additionalInformationDetails,
    bool clearAdditionalInformationDetails = false,
    BankGuaranteeDetailsModel? bankGuaranteeDetails,
    bool clearBankGuaranteeDetails = false,
  }) {
    return ProposedOfferState(
      isLoading: isLoading ?? this.isLoading,
      buildingList: buildingList ?? this.buildingList,
      buildingTotalCount: buildingTotalCount ?? this.buildingTotalCount,
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
      temporaryAccommodationAlternativeDetails:
          temporaryAccommodationAlternativeDetails ??
          this.temporaryAccommodationAlternativeDetails,
      totalNumberOfRecordTemporaryAccommodationAlternative:
          totalNumberOfRecordTemporaryAccommodationAlternative ??
          this.totalNumberOfRecordTemporaryAccommodationAlternative,
      readyReckonerRateDetails:
          readyReckonerRateDetails ?? this.readyReckonerRateDetails,

      carpetPlotDetails:
          clearCarpetPlotDetails
              ? null
              : carpetPlotDetails ?? this.carpetPlotDetails,

      additionalInformationDetails:
          clearAdditionalInformationDetails
              ? null
              : additionalInformationDetails ??
                  this.additionalInformationDetails,
      bankGuaranteeDetails:
          clearBankGuaranteeDetails
              ? null
              : bankGuaranteeDetails ?? this.bankGuaranteeDetails,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    buildingList,
    buildingTotalCount,
    extraCarpetArea,
    corpusDetails,
    securityDepositDetails,
    shiftingDetails,
    lienToSocietyDetails,
    parkingAllotment,
    gstOnExistingPlusFreeArea,
    projectCompletion,
    temporaryAccommodationAlternativeDetails,
    totalNumberOfRecordTemporaryAccommodationAlternative,
    readyReckonerRateDetails,
    carpetPlotDetails,
    additionalInformationDetails,
    bankGuaranteeDetails,
  ];
}
