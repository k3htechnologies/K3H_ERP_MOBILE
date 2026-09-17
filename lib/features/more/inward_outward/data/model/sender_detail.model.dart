import 'package:k3h_erp_app/utils/functions/common_function.dart';

class SenderDetailModel {
  final String name;
  final String address;
  final String emailId;
  const SenderDetailModel({
    required this.name,
    required this.address,
    required this.emailId,
  });
  factory SenderDetailModel.fromJson(Map<String, dynamic> json) =>
      SenderDetailModel(
        name: parseValue<String>(json, "Name"),
        address: parseValue<String>(json, "Address"),
        emailId: parseValue<String>(json, "EmailId"),
      );
  Map<String, dynamic> toJson() => {
    "Name": name,
    "Address": address,
    "EmailId": emailId,
  };
}
