import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/data/model/channel_partner_sourcing.model.dart';

enum AchievementDrillDownType { enquiry, booking, channelPartner }

class AchievementDrillDownReportModel {
  final Object data;
  final AchievementDrillDownType type;

  const AchievementDrillDownReportModel({
    required this.data,
    required this.type,
  });

  factory AchievementDrillDownReportModel.fromJson({
    required Map<String, dynamic> json,
    required AchievementDrillDownType type,
  }) {
    switch (type) {
      case AchievementDrillDownType.enquiry:
        return AchievementDrillDownReportModel(
          data: EnquiryModel.fromJson(json),
          type: type,
        );

      case AchievementDrillDownType.booking:
        return AchievementDrillDownReportModel(
          data: BookingModel.fromJson(json),
          type: type,
        );

      case AchievementDrillDownType.channelPartner:
        return AchievementDrillDownReportModel(
          data: ChannelPartnerSourcingModel.fromJson(json),
          type: type,
        );
    }
  }

  Map<String, dynamic> toJson() {
    switch (type) {
      case AchievementDrillDownType.enquiry:
        return (data as EnquiryModel).toJson();

      case AchievementDrillDownType.booking:
        return (data as BookingModel).toJson();

      case AchievementDrillDownType.channelPartner:
        return (data as ChannelPartnerSourcingModel).toJson();
    }
  }

  EnquiryModel? get enquiry =>
      data is EnquiryModel ? data as EnquiryModel : null;

  BookingModel? get booking =>
      data is BookingModel ? data as BookingModel : null;

  ChannelPartnerSourcingModel? get channelPartner =>
      data is ChannelPartnerSourcingModel
          ? data as ChannelPartnerSourcingModel
          : null;
}
