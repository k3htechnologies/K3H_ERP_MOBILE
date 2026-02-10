import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';

class EnquiryScreen extends StatefulWidget {
  const EnquiryScreen({super.key});

  @override
  State<EnquiryScreen> createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends State<EnquiryScreen> {
  // CUBIT
  late EnquiryCubit _enquiryCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  @override
  void initState() {
    super.initState();
    _enquiryCubit = context.read<EnquiryCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.enquiry]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Enquiry",
        authorization: _routeAuthorizationModel,
      ),
    );
  }
}
