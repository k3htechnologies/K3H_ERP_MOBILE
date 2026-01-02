import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/data/model/holiday_mapping_master.model.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';

class AddHolidayMappingMasterScreen extends StatefulWidget {
  final HolidayMappingModel? holidayMapping;
  final int? index;
  const AddHolidayMappingMasterScreen({super.key, this.holidayMapping, this.index=0});

  @override
  State<AddHolidayMappingMasterScreen> createState() =>
      _AddHolidayMappingMasterScreenState();
}

class _AddHolidayMappingMasterScreenState
    extends State<AddHolidayMappingMasterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Holiday Mapping",
        authorization: AuthorizationModel(),
      ),
    );
  }
}
