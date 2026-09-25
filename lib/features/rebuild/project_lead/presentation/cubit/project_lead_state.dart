part of 'project_lead_cubit.dart';

class ProjectLeadState extends BaseState {
  final List<RedevelopmentModel> redevelopmentList;
  final int redevelopmentCurrentPage;
  final int redevelopmentTotalNumberOfRecord;
  final String redevelopmentSearchText;
  final String redevelopmentBuildingAddressText;
  final String redevelopmentContactPersonNameText;
  final String redevelopmentContactPersonMobileNumberText;
  final String redevelopmentPinCode;
  final String redevelopmentPlotNumberText;
  final String redevelopmentWardNumberZone;
  final String redevelopmentExistingBuildingType;
  final String redevelopmentConstructionType;
  final String redevelopmentTypeOfLandTenure;
  final DateTime? redevelopmentByFromDate;
  final DateTime? redevelopmentByToDate;
  final List<LandModel> landList;
  final int landCurrentPage;
  final int landTotalNumberOfRecord;
  final String landSearchText;
  final String landAddress;
  final String landContactPersonName;
  final String landContactPersonMobileNumber;
  final String landPinCode;
  final String landPlotNumberText;
  final String landWardNumberZone;
  final String landPlotShape;
  final String landOwnershipType;
  final DateTime? landByFromDate;
  final DateTime? landByToDate;
  const ProjectLeadState({
    super.isLoading,
    required this.redevelopmentList,
    required this.redevelopmentCurrentPage,
    required this.redevelopmentTotalNumberOfRecord,
    required this.redevelopmentSearchText,
    required this.redevelopmentBuildingAddressText,
    required this.redevelopmentContactPersonNameText,
    required this.redevelopmentContactPersonMobileNumberText,
    required this.redevelopmentPinCode,
    required this.redevelopmentPlotNumberText,
    required this.redevelopmentWardNumberZone,
    required this.redevelopmentExistingBuildingType,
    required this.redevelopmentConstructionType,
    required this.redevelopmentTypeOfLandTenure,
    required this.landList,
    required this.landCurrentPage,
    required this.landTotalNumberOfRecord,
    required this.redevelopmentByFromDate,
    required this.redevelopmentByToDate,
    required this.landSearchText,
    required this.landAddress,
    required this.landContactPersonName,
    required this.landContactPersonMobileNumber,
    required this.landPinCode,
    required this.landPlotNumberText,
    required this.landWardNumberZone,
    required this.landPlotShape,
    required this.landOwnershipType,
    required this.landByFromDate,
    required this.landByToDate,
  });
  factory ProjectLeadState.initial() => ProjectLeadState(
    isLoading: false,
    redevelopmentList: [],
    redevelopmentCurrentPage: 1,
    redevelopmentTotalNumberOfRecord: 0,
    redevelopmentSearchText: '',
    redevelopmentBuildingAddressText: '',
    redevelopmentContactPersonNameText: '',
    redevelopmentContactPersonMobileNumberText: '',
    redevelopmentPinCode: '',
    redevelopmentPlotNumberText: '',
    redevelopmentWardNumberZone: '',
    redevelopmentExistingBuildingType: '',
    redevelopmentConstructionType: '',
    redevelopmentTypeOfLandTenure: '',
    landList: [],
    landCurrentPage: 1,
    landTotalNumberOfRecord: 0,
    redevelopmentByFromDate: null,
    redevelopmentByToDate: null,
    landSearchText: '',
    landAddress: '',
    landContactPersonName: '',
    landContactPersonMobileNumber: '',
    landPinCode: '',
    landPlotNumberText: '',
    landWardNumberZone: '',
    landPlotShape: '',
    landOwnershipType: '',
    landByFromDate: null,
    landByToDate: null,
  );
  static const _noChange = Object();

  ProjectLeadState copyWith({
    bool? isLoading,
    List<RedevelopmentModel>? redevelopmentList,
    int? redevelopmentCurrentPage,
    int? redevelopmentTotalNumberOfRecord,
    String? redevelopmentSearchText,
    String? redevelopmentBuildingAddressText,
    String? redevelopmentContactPersonNameText,
    String? redevelopmentContactPersonMobileNumberText,
    String? redevelopmentPinCode,
    String? redevelopmentPlotNumberText,
    String? redevelopmentWardNumberZone,
    String? redevelopmentExistingBuildingType,
    String? redevelopmentConstructionType,
    String? redevelopmentTypeOfLandTenure,
    Object? redevelopmentByFromDate = _noChange,
    Object? redevelopmentByToDate = _noChange,
    List<LandModel>? landList,
    int? landCurrentPage,
    int? landTotalNumberOfRecord,
    String? landSearchText,
    String? landAddress,
    String? landContactPersonName,
    String? landContactPersonMobileNumber,
    String? landPinCode,
    String? landPlotNumberText,
    String? landWardNumberZone,
    String? landPlotShape,
    String? landOwnershipType,
    Object? landByFromDate = _noChange,
    Object? landByToDate = _noChange,
  }) {
    return ProjectLeadState(
      isLoading: isLoading ?? this.isLoading,
      redevelopmentList: redevelopmentList ?? this.redevelopmentList,
      redevelopmentCurrentPage:
          redevelopmentCurrentPage ?? this.redevelopmentCurrentPage,
      redevelopmentTotalNumberOfRecord:
          redevelopmentTotalNumberOfRecord ??
          this.redevelopmentTotalNumberOfRecord,
      redevelopmentSearchText:
          redevelopmentSearchText ?? this.redevelopmentSearchText,
      redevelopmentBuildingAddressText:
          redevelopmentBuildingAddressText ??
          this.redevelopmentBuildingAddressText,
      redevelopmentContactPersonNameText:
          redevelopmentContactPersonNameText ??
          this.redevelopmentContactPersonNameText,
      redevelopmentContactPersonMobileNumberText:
          redevelopmentContactPersonMobileNumberText ??
          this.redevelopmentContactPersonMobileNumberText,
      redevelopmentPinCode: redevelopmentPinCode ?? this.redevelopmentPinCode,
      redevelopmentPlotNumberText:
          redevelopmentPlotNumberText ?? this.redevelopmentPlotNumberText,
      redevelopmentWardNumberZone:
          redevelopmentWardNumberZone ?? this.redevelopmentWardNumberZone,
      redevelopmentExistingBuildingType:
          redevelopmentExistingBuildingType ??
          this.redevelopmentExistingBuildingType,
      redevelopmentConstructionType:
          redevelopmentConstructionType ?? this.redevelopmentConstructionType,
      redevelopmentTypeOfLandTenure:
          redevelopmentTypeOfLandTenure ?? this.redevelopmentTypeOfLandTenure,
      redevelopmentByFromDate:
          redevelopmentByFromDate == _noChange
              ? this.redevelopmentByFromDate
              : redevelopmentByFromDate as DateTime?,

      redevelopmentByToDate:
          redevelopmentByToDate == _noChange
              ? this.redevelopmentByToDate
              : redevelopmentByToDate as DateTime?,
      landList: landList ?? this.landList,
      landCurrentPage: landCurrentPage ?? this.landCurrentPage,
      landTotalNumberOfRecord:
          landTotalNumberOfRecord ?? this.landTotalNumberOfRecord,
      landSearchText: landSearchText ?? this.landSearchText,
      landAddress: landAddress ?? this.landAddress,
      landContactPersonName:
          landContactPersonName ?? this.landContactPersonName,
      landContactPersonMobileNumber:
          landContactPersonMobileNumber ?? this.landContactPersonMobileNumber,
      landPinCode: landPinCode ?? this.landPinCode,
      landPlotNumberText: landPlotNumberText ?? this.landPlotNumberText,
      landWardNumberZone: landWardNumberZone ?? this.landWardNumberZone,
      landPlotShape: landPlotShape ?? this.landPlotShape,
      landOwnershipType: landOwnershipType ?? this.landOwnershipType,
      landByFromDate:
          landByFromDate == _noChange
              ? this.landByFromDate
              : landByFromDate as DateTime?,

      landByToDate:
          landByToDate == _noChange
              ? this.landByToDate
              : landByToDate as DateTime?,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    redevelopmentList,
    redevelopmentCurrentPage,
    redevelopmentTotalNumberOfRecord,
    redevelopmentSearchText,
    redevelopmentBuildingAddressText,
    redevelopmentContactPersonNameText,
    redevelopmentContactPersonMobileNumberText,
    redevelopmentPinCode,
    redevelopmentPlotNumberText,
    redevelopmentWardNumberZone,
    redevelopmentExistingBuildingType,
    redevelopmentConstructionType,
    redevelopmentTypeOfLandTenure,
    redevelopmentByFromDate,
    redevelopmentByToDate,
    landList,
    landCurrentPage,
    landTotalNumberOfRecord,
    landSearchText,
    landAddress,
    landContactPersonName,
    landContactPersonMobileNumber,
    landPinCode,
    landPlotNumberText,
    landWardNumberZone,
    landPlotShape,
    landOwnershipType,
    landByFromDate,
    landByToDate,
  ];
}
