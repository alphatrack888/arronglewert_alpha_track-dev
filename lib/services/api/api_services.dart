import 'dart:async';
import 'dart:io';

import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/services/api/api.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_log/error_log.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class ApiServices {
  ///////////////
  ApiServices._privateConstructor();

  static final ApiServices _instance = ApiServices._privateConstructor();

  static ApiServices get instance => _instance;

  //////////  object
  final api = AppApi();
  var storageServices = StorageServices.instance;

  Future<dynamic> apiPutServices({
    required String url,
    dynamic body,
    int statusCode = 200,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await api.sendRequest.put(
        url,
        data: body,
        queryParameters: query,
      );
      if (response.statusCode == statusCode) {
        return response.data;
      } else {
        return null;
      }
    } on SocketException catch (e) {
      errorLog('api socket exception', e);
      AppSnackBar.error("Check Your Internet Connection");
      return null;
    } on TimeoutException catch (e) {
      errorLog('api time out exception', e);
      return null;
    } on DioException catch (e) {
      if (e.response.runtimeType != Null) {
        if (e.response?.statusCode == 401) {
          await storageServices.storageClear();
          Get.offAllNamed(AppRoute.onboardingScreen);
        }

        if (e.response?.data["message"].runtimeType != Null) {
          AppSnackBar.error("${e.response?.data["message"]}");
        }

        return null;
      }
      errorLog('api dio exception', e);
      return null;
    } catch (e) {
      errorLog('api exception', e);
      return null;
    }
  }

  Future<dynamic> apiPostServices({
    required String url,
    dynamic body,
    int statusCodeStart = 200,
    int statusCodeEnd = 299,
    Map<String, dynamic>? query,
    dynamic header,
    Options? options,
  }) async {
    try {
      Options requestOptions;
      if (options != null) {
        requestOptions = options;
        if (header != null) {
          requestOptions.headers = {...?requestOptions.headers, ...header};
        }
      } else if (header != null) {
        requestOptions = Options(headers: header);
      } else {
        requestOptions = Options();
      }

      final dynamic response = await AppApi().sendRequest.post(
        url,
        data: body,
        options: requestOptions,
      );
      if (response.statusCode >= statusCodeStart &&
          response.statusCode <= statusCodeEnd) {
        return response.data;
      } else {
        appLog('API Error - Status Code: ${response.statusCode}');
        appLog('API Error - Response: ${response.data}');
        appLog('API Error - Response Type: ${response.data.runtimeType}');
        if (response.data is Map) {
          final errorData = response.data as Map;
          appLog('API Error - Message: ${errorData['message'] ?? 'No message'}');
          appLog('API Error - Error: ${errorData['error'] ?? 'No error field'}');
          appLog('API Error - Details: ${errorData['details'] ?? 'No details'}');
        }
        return null;
      }
    } on SocketException catch (e) {
      errorLog('api socket exception', e);
      AppSnackBar.error("Check Your Internet Connection");
      return null;
    } on TimeoutException catch (e) {
      errorLog('api time out exception', e);
      return null;
    } on DioException catch (e) {
      if (e.response.runtimeType != Null) {
        if (e.response?.statusCode == 401) {
          await storageServices.storageClear();
          Get.offAllNamed(AppRoute.onboardingScreen);
        }

        if (e.response?.data["message"].runtimeType != Null) {
          AppSnackBar.error("${e.response?.data["message"]}");
        }

        return null;
      }
      errorLog('api dio exception', e);
      return null;
    } catch (e) {
      errorLog('api exception', e);
      return null;
    }
  }

  //! This method is for getting the
  Future<dynamic> apiPostServicesWithOtp({
  required String url,
  dynamic body,
  int statusCodeStart = 200,
  int statusCodeEnd = 299,
  int otpStatusCode = 407, // Specific status code for OTP response
  Map<String, dynamic>? query,
  dynamic header,
  Options? options,
}) async {
  try {
    Options requestOptions;
    if (options != null) {
      requestOptions = options;
      if (header != null) {
        requestOptions.headers = {...?requestOptions.headers, ...header};
      }
    } else if (header != null) {
      requestOptions = Options(headers: header);
    } else {
      requestOptions = Options();
    }

    final dynamic response = await AppApi().sendRequest.post(
      url,
      data: body,
      options: requestOptions,
    );

    // Handle success cases including OTP response
    if (response.statusCode >= statusCodeStart &&
        response.statusCode <= statusCodeEnd ||
        response.statusCode == otpStatusCode) {
      // Check if it's an OTP response
      if (response.statusCode == otpStatusCode &&
          response.data['success'] == true) {
        return response.data; // Return OTP response data
      }
      return response.data; // Return regular success response data
    } else {
      return null;
    }
  } on SocketException catch (e) {
    errorLog('api socket exception', e);
    AppSnackBar.error("Check Your Internet Connection");
    return null;
  } on TimeoutException catch (e) {
    errorLog('api time out exception', e);
    return null;
  } on DioException catch (e) {
    if (e.response != null) {
      if (e.response?.statusCode == 401) {
        await storageServices.storageClear();
        Get.offAllNamed(AppRoute.onboardingScreen);
      }

      if (e.response?.data["message"] != null) {
        AppSnackBar.error("${e.response?.data["message"]}");
      }

      return null;
    }
    errorLog('api dio exception', e);
    return null;
  } catch (e) {
    errorLog('api exception', e);
    return null;
  }
}

  Future<dynamic> apiGetServices(
    String url, {
    int statusCode = 200,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers, // Add headers parameter
    dynamic body,
  }) async {
    try {
      final response = await api.sendRequest.get(
        url,
        queryParameters: queryParameters,
        data: body,
        options: Options(headers: headers), // Pass headers to the request
      );
      if (response.statusCode == statusCode) {
        return response.data;
      } else {
        return null;
      }
    } on SocketException catch (e) {
      errorLog('api socket exception', e);
      AppSnackBar.error("Check Your Internet Connection");
      return null;
    } on TimeoutException catch (e) {
      errorLog('api time out exception', e);
      return null;
    } on DioException catch (e) {
      if (e.response.runtimeType != Null) {
        if (e.response?.statusCode == 401) {
          await storageServices.storageClear();
          Get.offAllNamed(AppRoute.onboardingScreen);
        }

        if (e.response?.data["message"].runtimeType != Null) {
          AppSnackBar.error("${e.response?.data["message"]}");
        }

        return null;
      }
      errorLog('api dio exception', e);
      return null;
    } catch (e) {
      errorLog('api exception', e);
      return null;
    }
  }

  Future<dynamic> apiPatchServices({
    required String url,
    Object? body,
    int statusCode = 200,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    try {
      final response = await api.sendRequest.patch(
        url,
        data: body,
        queryParameters: query,
        options: options,
      );

      if (response.statusCode == statusCode) {
        return response.data;
      } else {
        AppSnackBar.error(
          "Unexpected response: ${response.statusCode} ${response.statusMessage}",
        );
        return null;
      }
    } on SocketException catch (e) {
      errorLog('api socket exception', e);
      AppSnackBar.error("Check Your Internet Connection");
      return null;
    } on TimeoutException catch (e) {
      errorLog('api time out exception', e);
      return null;
    } on DioException catch (e) {
      // Fixed null checking
      if (e.response != null) {
        if (e.response?.statusCode == 401) {
          await storageServices.storageClear();
          Get.offAllNamed(AppRoute.onboardingScreen);
        }

        // Fixed null checking for message
        if (e.response?.data != null && e.response?.data["message"] != null) {
          AppSnackBar.error("${e.response?.data["message"]}");
        }
        return null;
      }
      errorLog('api dio exception', e);
      return null;
    } catch (e) {
      errorLog('api exception', e);
      return null;
    }
  }

  Future<dynamic> apiDeleteServices({
    required String url,
    Object? body,
    int statusCode = 200,
    Map<String, dynamic>? query,
    Options? options,
    String? token,
  }) async {
    try {
      // Create headers with Authorization token if provided
      Options requestOptions = options ?? Options();
      requestOptions.headers = {
        ...?requestOptions.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await api.sendRequest.delete(
        url,
        data: body,
        queryParameters: query,
        options: requestOptions,
      );

      if (response.statusCode == statusCode) {
        return response.data;
      } else {
        AppSnackBar.error(
          "Unexpected response: ${response.statusCode} ${response.statusMessage}",
        );
        return null;
      }
    } on SocketException catch (e) {
      errorLog('api socket exception', e);
      AppSnackBar.error("Check Your Internet Connection");
      return null;
    } on TimeoutException catch (e) {
      errorLog('api time out exception', e);
      return null;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        if (e.response?.statusCode == 401) {
          await storageServices.storageClear();
          Get.offAllNamed(AppRoute.onboardingScreen);
        }

        if (e.response?.data["message"] != null) {
          AppSnackBar.error("${e.response?.data["message"]}");
        }

        return null;
      }
      errorLog('api dio exception', e);
      return null;
    } catch (e) {
      errorLog('api exception', e);
      return null;
    }
  }
}