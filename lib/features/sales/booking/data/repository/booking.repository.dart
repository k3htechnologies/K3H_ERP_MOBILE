import 'package:k3h_erp_app/features/sales/booking/data/datasource/booking.datasource.dart';

abstract interface class BookingRepository {}

class BookingRepositoryImpl extends BookingRepository {
  BookingDatasource bookingDatasource;

  BookingRepositoryImpl({required this.bookingDatasource});
}
