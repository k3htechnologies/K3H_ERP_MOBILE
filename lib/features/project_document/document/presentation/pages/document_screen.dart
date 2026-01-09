import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {

  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;


  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel = Authorization.routeAuthorizationMap[AppRoutes.document]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:CustomAppBar(screenTitle: "Document", authorization: _routeAuthorizationModel),
    );
  }
}
