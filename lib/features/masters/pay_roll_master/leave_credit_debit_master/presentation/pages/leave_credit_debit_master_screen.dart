import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';

class LeaveCreditDebitMasterScreen extends StatefulWidget {
  const LeaveCreditDebitMasterScreen({super.key});

  @override
  State<LeaveCreditDebitMasterScreen> createState() =>
      _LeaveCreditDebitMasterScreenState();
}

class _LeaveCreditDebitMasterScreenState
    extends State<LeaveCreditDebitMasterScreen> {
  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // TEXT EDITING CONTROLLER
  late TextEditingController _searchC;

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.leaveCreditDebitMaster]!;
    _initializeTextEditingController();
  }

  // INITIALIZING TEXT EDITING CONTROLLER
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Leave Credit Debit Management",
        authorization: _routeAuthorizationModel,
        textController: _searchC,
        onSearchSubmit: (value){

        },
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addLeaveCreditDebitMaster);
        },
      ),
    );
  }
}
