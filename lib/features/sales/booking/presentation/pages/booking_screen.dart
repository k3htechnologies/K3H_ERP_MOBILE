import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/cubit/booking_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {

  // CUBIT
  late BookingCubit _bookingCubit;

  // AUTHORIZATION
  late AuthorizationModel _routhAuthorizationModel;

  @override
  void initState() {
    super.initState();
    _bookingCubit = context.read<BookingCubit>();
    _routhAuthorizationModel = Authorization.routeAuthorizationMap[AppRoutes.booking]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(screenTitle: "Booking", authorization: _routhAuthorizationModel),
    );
  }
}
