import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/other_charges/presentation/cubit/other_charges_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';

class OtherChargesScreen extends StatefulWidget {
  const OtherChargesScreen({super.key});

  @override
  State<OtherChargesScreen> createState() => _OtherChargesScreenState();
}

class _OtherChargesScreenState extends State<OtherChargesScreen> {
  // CUBIT
  late OtherChargesCubit _otherChargesCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  @override
  void initState() {
    super.initState();
    _searchC = TextEditingController();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.otherCharges]!;
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Other Charges",
        authorization: _routeAuthorizationModel,
        onExportCallback: (value) {},
        textController: _searchC,
        onSearchSubmit: (value) {},
      ),
    );
  }
}
