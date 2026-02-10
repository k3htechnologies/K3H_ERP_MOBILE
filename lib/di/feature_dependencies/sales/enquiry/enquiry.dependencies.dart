import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/datasource/enquiry.datasource.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/repository/enquiry.repository.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_cubit.dart';

void registerEnquiryDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<EnquiryDatasource>(EnquiryDatasourceImpl());
  serviceLocator.registerSingleton<EnquiryRepository>(
    EnquiryRepositoryImpl(
      enquiryDatasource: serviceLocator<EnquiryDatasource>(),
    ),
  );

  //<---- CUBIT ---->
  serviceLocator.registerSingleton<EnquiryCubit>(EnquiryCubit());
}
