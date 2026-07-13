import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ChannelPartnerAopModel {
  int channelPartnerAopId;
  int channelPartnerId;
  DateTime aopFromDate;
  DateTime aopToDate;
  String aopDocumentUrl;
  String aopStatus;
  int noOfIbm;
  int noOfObm;
  int noOfEnquiry;
  int noOfBooking;
  double brokeragePercentage;
  double brokerageAmount;
  double paidBrokerageAmount;

  ChannelPartnerAopModel({
    required this.channelPartnerAopId,
    required this.channelPartnerId,
    required this.aopFromDate,
    required this.aopToDate,
    required this.aopDocumentUrl,
    required this.aopStatus,
    required this.noOfIbm,
    required this.noOfObm,
    required this.noOfEnquiry,
    required this.noOfBooking,
    required this.brokeragePercentage,
    required this.brokerageAmount,
    required this.paidBrokerageAmount,
  });

  factory ChannelPartnerAopModel.fromJson(Map<String, dynamic> json) =>
      ChannelPartnerAopModel(
        channelPartnerAopId: parseValue<int>(json, "ChannelPartnerAOPId"),
        channelPartnerId: parseValue<int>(json, "ChannelPartnerId"),
        aopFromDate: parseValue<DateTime>(json, "AOPFromDate"),
        aopToDate: parseValue<DateTime>(json, "AOPToDate"),
        aopDocumentUrl: parseValue<String>(json, "AOPDocumentURL"),
        aopStatus: parseValue<String>(json, "AOPStatus"),
        noOfIbm: parseValue<int>(json, "NoOfIbm"),
        noOfObm: parseValue<int>(json, "NoOfObm"),
        noOfEnquiry: parseValue<int>(json, "NoOfEnquiry"),
        noOfBooking: parseValue<int>(json, "NoOfBooking"),
        brokeragePercentage: parseValue<double>(json, "BrokeragePercentage"),
        brokerageAmount: parseValue<double>(json, "BrokerageAmount"),
        paidBrokerageAmount: parseValue<double>(json, "PaidBrokerageAmount"),
      );

  Map<String, dynamic> toJson() => {
    "ChannelPartnerAOPId": channelPartnerAopId,
    "ChannelPartnerId": channelPartnerId,
    "AOPFromDate": aopFromDate.toIso8601String(),
    "AOPToDate": aopToDate.toIso8601String(),
    "AOPDocumentURL": aopDocumentUrl,
    "AOPStatus": aopStatus,
    "NoOfIbm": noOfIbm,
    "NoOfObm": noOfObm,
    "NoOfEnquiry": noOfEnquiry,
    "NoOfBooking": noOfBooking,
    "BrokeragePercentage": brokeragePercentage,
    "BrokerageAmount": brokerageAmount,
    "PaidBrokerageAmount": paidBrokerageAmount,
  };
}
