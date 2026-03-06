import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';

class ClassificationParametersScreen extends StatefulWidget {
  const ClassificationParametersScreen({super.key});

  @override
  State<ClassificationParametersScreen> createState() =>
      _ClassificationParametersScreenState();
}

class _ClassificationParametersScreenState
    extends State<ClassificationParametersScreen> {
  // AUTHORIZATION MODEL
  late AuthorizationModel _routhAuthorizationModel;

  @override
  void initState() {
    super.initState();
    _routhAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.classificationParameter]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Classification Parameters",
        authorization: _routhAuthorizationModel,
      ),
    );
  }
}
