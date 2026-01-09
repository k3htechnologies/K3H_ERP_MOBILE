import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';

class DocumentCategoryScreen extends StatefulWidget {
  const DocumentCategoryScreen({super.key});

  @override
  State<DocumentCategoryScreen> createState() => _DocumentCategoryScreenState();
}

class _DocumentCategoryScreenState extends State<DocumentCategoryScreen> {

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
      appBar:CustomAppBar(screenTitle: "Category", authorization: _routeAuthorizationModel),
    );
  }
}
