import 'package:k3h_erp_app/utils/common_function.dart';

class PayTrackBookingFilesModel {
  int payTrackBookingFilesId;
  String uniquekey;
  int bookingId;
  int projectId;
  String fileName;
  String fileType;
  int isMaster;
  String payTrackBookingFilesUrl;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  PayTrackBookingFilesModel({
    required this.payTrackBookingFilesId,
    required this.uniquekey,
    required this.bookingId,
    required this.projectId,
    required this.fileName,
    required this.fileType,
    required this.isMaster,
    required this.payTrackBookingFilesUrl,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory PayTrackBookingFilesModel.fromJson(Map<String, dynamic> json) =>
      PayTrackBookingFilesModel(
        payTrackBookingFilesId: parseValue<int>(json, "PayTrackBookingFilesId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        bookingId: parseValue<int>(json, "BookingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        fileName: parseValue<String>(json, "FileName"),
        fileType: parseValue<String>(json, "FileType"),
        isMaster: parseValue<int>(json, "IsMaster"),
        payTrackBookingFilesUrl: parseValue<String>(
          json,
          "PayTrackBookingFilesUrl",
        ),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: parseValue<DateTime>(json, "CreatedDate"),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] == null
                ? null
                : DateTime.parse(json["ModifiedDate"]),
      );

  Map<String, dynamic> toJson() => {
    "PayTrackBookingFilesId": payTrackBookingFilesId,
    "Uniquekey": uniquekey,
    "BookingId": bookingId,
    "ProjectId": projectId,
    "FileName": fileName,
    "FileType": fileType,
    "IsMaster": isMaster,
    "PayTrackBookingFilesUrl": payTrackBookingFilesUrl,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
