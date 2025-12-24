import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

class UserModel {
  int employeeId;
  String uniqueKey;
  String employeeCode;
  String firstName;
  String middleName;
  String lastName;
  String fullName;
  int departmentMasterId;
  String department;
  int designationMasterId;
  String designation;
  int branchMasterId;
  String branch;
  String gender;
  String maritalStatus;
  DateTime? dateOfBirth;
  DateTime? joiningDate;
  DateTime? probationDate;
  DateTime? resignationDate;
  bool isGeoFenceLocation;
  String emailId;
  String officeEmailId;
  int reportPersonId;
  String reportPersonName;
  String personalMobileNumber;
  String officeMobileNumber;
  int bankListMasterId;
  String bankName;
  String bankBranchName;
  String ifscCode;
  String accountNo;
  String employeeType;
  String emergencyMobileNumber;
  String emergencyContactPersonRelationship;
  bool isUpdateEmployee;
  String communicationAddress;
  String permanentAddress;
  String bloodGroup;
  int companyId;
  String companyName;
  DateTime? lastLogin;
  int countryMasterId;
  String countryName;
  int stateMasterId;
  String stateName;
  int districtMasterId;
  String districtName;
  int cityMasterId;
  String cityName;
  int clientRegistrationId;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  String token;
  List<ModuleModel> moduleData;
  List<ProjectModel> projectData;
  List<Map<String, dynamic>> employeeReportingCycleData;
  bool isSelected;
  // VARIABLE USED IN PROJECT MASTER FOR HANDLING THE STATE OF SELECTED EMPLOYEE

  UserModel({
    required this.employeeId,
    required this.uniqueKey,
    required this.employeeCode,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.fullName,
    required this.departmentMasterId,
    required this.department,
    required this.designationMasterId,
    required this.designation,
    required this.branchMasterId,
    required this.branch,
    required this.gender,
    required this.maritalStatus,
    required this.dateOfBirth,
    required this.joiningDate,
    required this.probationDate,
    required this.resignationDate,
    required this.isGeoFenceLocation,
    required this.emailId,
    required this.officeEmailId,
    required this.reportPersonId,
    required this.reportPersonName,
    required this.personalMobileNumber,
    required this.officeMobileNumber,
    required this.bankListMasterId,
    required this.bankName,
    required this.bankBranchName,
    required this.ifscCode,
    required this.accountNo,
    required this.employeeType,
    required this.emergencyMobileNumber,
    required this.emergencyContactPersonRelationship,
    required this.isUpdateEmployee,
    required this.communicationAddress,
    required this.permanentAddress,
    required this.bloodGroup,
    required this.companyId,
    required this.companyName,
    required this.lastLogin,
    required this.countryMasterId,
    required this.countryName,
    required this.stateMasterId,
    required this.stateName,
    required this.districtMasterId,
    required this.districtName,
    required this.cityMasterId,
    required this.cityName,
    required this.clientRegistrationId,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.token,
    required this.moduleData,
    required this.projectData,
    required this.employeeReportingCycleData,
    this.isSelected = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
      employeeId: parseValue<int>(json, "EmployeeId"),
      uniqueKey: parseValue<String>(json, "UniqueKey"),
      employeeCode: parseValue<String>(json, "EmployeeCode"),
      firstName: parseValue<String>(json, "FirstName"),
      middleName: parseValue<String>(json, "MiddleName"),
      lastName: parseValue<String>(json, "LastName"),
      fullName: parseValue<String>(json, "FullName"),
      departmentMasterId: parseValue<int>(json, "DepartmentMasterId"),
      department: parseValue<String>(json, "Department"),
      designationMasterId: parseValue<int>(json, "DesignationMasterId"),
      designation: parseValue<String>(json, "Designation"),
      branchMasterId: parseValue<int>(json, "BranchMasterId"),
      branch: parseValue<String>(json, "Branch"),
      gender: parseValue<String>(json, "Gender"),
      maritalStatus: parseValue<String>(json, "MaritalStatus"),
      dateOfBirth:
      json["DateOfBirth"] == null
          ? null
          : parseValue<DateTime>(json, "DateOfBirth"),
      joiningDate:
      json["JoiningDate"] == null
          ? null
          : parseValue<DateTime>(json, "JoiningDate"),
      probationDate:
      json["ProbationDate"] == null
          ? null
          : parseValue<DateTime>(json, "ProbationDate"),
      resignationDate:
      json["ResignationDate"] == null
          ? null
          : DateTime.parse(json["ResignationDate"]),
      isGeoFenceLocation: parseValue<bool>(json, "IsGeoFenceLocation"),
      emailId: parseValue<String>(json, "EmailId"),
      officeEmailId: parseValue<String>(json, "OfficeEmailId"),
      reportPersonId: parseValue<int>(json, "ReportPersonId"),
      reportPersonName: parseValue<String>(json, "ReportPersonName"),
      personalMobileNumber: parseValue<String>(json, "PersonalMobileNumber"),
      officeMobileNumber: parseValue<String>(json, "OfficeMobileNumber"),
      bankListMasterId: parseValue<int>(json, "BankListMasterId"),
      bankName: parseValue<String>(json, "BankName"),
      bankBranchName: parseValue<String>(json, "BankBranchName"),
      ifscCode: parseValue<String>(json, "IFSCCode"),
      accountNo: parseValue<String>(json, "AccountNo"),
      employeeType: parseValue<String>(json, "EmployeeType"),
      emergencyMobileNumber: parseValue<String>(json, "EmergencyMobileNumber"),
      emergencyContactPersonRelationship: parseValue<String>(
        json,
        "EmergencyContactPersonRelationship",
      ),
      isUpdateEmployee: parseValue<bool>(json, "IsUpdateEmployee"),
      communicationAddress: parseValue<String>(json, "CommunicationAddress"),
      permanentAddress: parseValue<String>(json, "PermanentAddress"),
      bloodGroup: parseValue<String>(json, "BloodGroup"),
      companyId: parseValue<int>(json, "CompanyId"),
      companyName: parseValue<String>(json, "CompanyName"),
      lastLogin:
      json["LastLogin"] == null
          ? null
          : parseValue<DateTime>(json, "LastLogin"),
      countryMasterId: parseValue<int>(json, "CountryMasterId"),
      countryName: parseValue<String>(json, "CountryName"),
      stateMasterId: parseValue<int>(json, "StateMasterId"),
      stateName: parseValue<String>(json, "StateName"),
      districtMasterId: parseValue<int>(json, "DistrictMasterId"),
      districtName: parseValue<String>(json, "DistrictName"),
      cityMasterId: parseValue<int>(json, "CityMasterId"),
      cityName: parseValue<String>(json, "CityName"),
      clientRegistrationId: parseValue<int>(json, "ClientRegistrationId"),
      createdById: parseValue<int>(json, "CreatedById"),
      createdBy: parseValue<String>(json, "CreatedBy"),
      createdDate: parseValue<DateTime>(json, "CreatedDate"),
      modifiedById: parseValue<int>(json, "ModifiedById"),
      modifiedBy: parseValue<String>(json, "ModifiedBy"),
      modifiedDate:
      json["ModifiedDate"] == null
          ? null
          : parseValue<DateTime>(json, "ModifiedDate"),
      token: parseValue<String>(json, "Token"),
      moduleData: List<ModuleModel>.from(
        json["ModuleData"].map((x) => ModuleModel.fromJson(x)),
      ),
      projectData: List<ProjectModel>.from(
        json["ProjectData"].map((x) => ProjectModel.fromJson(x)),
      ),
      employeeReportingCycleData: json["EmployeeReportingCycleData"] != null
          ? List<Map<String, dynamic>>.from(
              json["EmployeeReportingCycleData"].map(
                (x) => Map<String, dynamic>.from(x as Map),
              ),
            )
          : [],
      isSelected: false
  );

  Map<String, dynamic> toJson() => {
    "EmployeeId": employeeId,
    "UniqueKey": uniqueKey,
    "EmployeeCode": employeeCode,
    "FirstName": firstName,
    "MiddleName": middleName,
    "LastName": lastName,
    "FullName": fullName,
    "DepartmentMasterId": departmentMasterId,
    "Department": department,
    "DesignationMasterId": designationMasterId,
    "Designation": designation,
    "BranchMasterId": branchMasterId,
    "Branch": branch,
    "Gender": gender,
    "MaritalStatus": maritalStatus,
    "DateOfBirth": dateOfBirth?.toIso8601String(),
    "JoiningDate": joiningDate?.toIso8601String(),
    "ProbationDate": probationDate?.toIso8601String(),
    "ResignationDate": resignationDate?.toIso8601String(),
    "IsGeoFenceLocation": isGeoFenceLocation,
    "EmailId": emailId,
    "OfficeEmailId": officeEmailId,
    "ReportPersonId": reportPersonId,
    "ReportPersonName": reportPersonName,
    "PersonalMobileNumber": personalMobileNumber,
    "OfficeMobileNumber": officeMobileNumber,
    "BankListMasterId": bankListMasterId,
    "BankName": bankName,
    "BankBranchName": bankBranchName,
    "IFSCCode": ifscCode,
    "AccountNo": accountNo,
    "EmployeeType": employeeType,
    "EmergencyMobileNumber": emergencyMobileNumber,
    "EmergencyContactPersonRelationship": emergencyContactPersonRelationship,
    "IsUpdateEmployee": isUpdateEmployee,
    "CommunicationAddress": communicationAddress,
    "PermanentAddress": permanentAddress,
    "BloodGroup": bloodGroup,
    "CompanyId": companyId,
    "CompanyName": companyName,
    "LastLogin": lastLogin?.toIso8601String(),
    "CountryMasterId": countryMasterId,
    "CountryName": countryName,
    "StateMasterId": stateMasterId,
    "StateName": stateName,
    "DistrictMasterId": districtMasterId,
    "DistrictName": districtName,
    "CityMasterId": cityMasterId,
    "CityName": cityName,
    "ClientRegistrationId": clientRegistrationId,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
    "Token": token,
    "ModuleData": List<dynamic>.from(moduleData.map((x) => x.toJson())),
    "ProjectData": List<dynamic>.from(projectData.map((x) => x.toJson())),
    "EmployeeReportingCycleData": employeeReportingCycleData,
  };
}