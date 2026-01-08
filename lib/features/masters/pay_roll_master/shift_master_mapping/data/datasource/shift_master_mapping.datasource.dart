// import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master_mapping/data/model/shift_master_mapping.model.dart';
// import 'package:k3h_erp_app/service/base_client.dart';
// import 'package:k3h_erp_app/service/exceptions.dart';

// abstract interface class ShiftMasterMappingDatasource {
//   Future<Map<String, dynamic>> apiCallPullShiftMappedShift({
//     required int pageNumber,
//     required int pageSize,
//     Map<String, dynamic>? queryParams,
//   });
// }

// class ShiftMasterMappingDataSourceImp extends ShiftMasterMappingDatasource {
//   final BaseClient baseClient = BaseClient();
//   @override
//   Future<Map<String, dynamic>> apiCallPullShiftMappedShift({
//     required int pageNumber,
//     required int pageSize,
//     Map<String, dynamic>? queryParams,
//   }) async {
//     String pullAssetMasterMappingsUrl({
//       required int pageSize,
//       required int pageNumber,
//       Map<String, dynamic>? queryParams,
//     }) {
//       String url =
//           "ShiftManagementMasterMapping/PullShiftManagementMasterMapping?PageSize=$pageSize&PageNumber=$pageNumber";
//       queryParams?.forEach((key, value) => url += "&$key=$value");
//       return url;
//     }

//     try {
//       var networkResponse = await baseClient.getRequestWithAuthentication(
//         pullAssetMasterMappingsUrl(
//           pageSize: pageSize,
//           pageNumber: pageNumber,
//           queryParams: queryParams,
//         ),
//       );
//       return {
//         'data': List<ShiftMappingModel>.from(
//           networkResponse['data'].map((e) => ShiftMappingModel.fromJson(e)),
//         ),
//         'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
//       };
//     } catch (error) {
//       if (error is TokenExpiredException) {
//         apiCallPullShiftMappedShift(
//           pageNumber: pageNumber,
//           pageSize: pageSize,
//           queryParams: queryParams,
//         );
//       }
//       rethrow;
//     }
//   }
// }
