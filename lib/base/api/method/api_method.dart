import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../routes/routes.dart';
import '../../maintenance/maintenance_dialog.dart';
import '../../maintenance/maintenance_model.dart';
import '../../utils/basic_import.dart';
import '../../utils/local_storage.dart';
import '../../widgets/logger.dart';
import '../model/error_message_model.dart';

final log = logger(ApiMethod);

Map<String, String> basicHeaderInfo() {
  return {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
  };
}

Future<Map<String, String>> bearerHeaderInfo() async {
  String accessToken = LocalStorage.token;
  print('🔐 Auth Token in Request: $accessToken');

  return {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.authorizationHeader: "Bearer $accessToken",
  };
}

class ApiMethod {
  ApiMethod({required this.isBasic});

  bool isBasic;

  // Get method
  Future<Map<String, dynamic>?> get(
    String url, {
    int code = 200,
    int duration = 120,
    bool showResult = false,
    bool showErrorMessage = true,
  }) async {
    log.i(
        '|📍📍📍|----------------- [[ GET ]] method details start -----------------|📍📍📍|');
    log.i(url);
    log.i(
        '|📍📍📍|----------------- [[ GET ]] method details ended -----------------|📍📍📍|');

    Future<http.Response> doGet() async {
      return http
          .get(
            Uri.parse(url),
            headers: isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
          )
          .timeout(Duration(seconds: duration));
    }

    try {
      final response = await doGet();

      log.i(
          '|📒📒📒|-----------------[[ GET ]] method response start -----------------|📒📒📒|');

      if (showResult) {
        log.i(response.body.toString());
      }

      log.i(response.statusCode);

      log.i(
          '|📒📒📒|-----------------[[ GET ]] method response end -----------------|📒📒📒|');

      bool isMaintenance = response.statusCode == 503;

      // Check Server Error
      if (response.statusCode == 500) {
        CustomSnackBar.error(Strings.serverError);
        Get.offAllNamed(Routes.loginScreen);
      }
      if (response.statusCode == 401) {
        Get.offAllNamed(Routes.loginScreen);
        LocalStorage.clear();
      }

      _maintenanceCheck(isMaintenance, response.body);

      if (response.statusCode == code) {
        try {
          // Fix malformed JSON from backend
          String sanitizedBody = response.body
              // Fix "nul" instead of "null"
              .replaceAll(':nul,', ':null,')
              .replaceAll(':nul}', ':null}')
              .replaceAll(':nul]', ':null]')
              // Fix missing comma between quoted strings
              .replaceAll(RegExp(r'"\s*"'), '","');
          
          return jsonDecode(sanitizedBody);
        } catch (e) {
          log.e('🐞🐞🐞 JSON Decode Error 🐞🐞🐞');
          log.e('Response length: ${response.body.length}');
          log.e('Error: $e');
          if (showErrorMessage) {
            CustomSnackBar.error('Failed to process server response');
          }
          return null;
        }
      } else {
        log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');

        try {
          log.e(
              'unknown error hitted in status code${jsonDecode(response.body)}');

          ErrorResponse res = ErrorResponse.fromJson(jsonDecode(response.body));
          if (isMaintenance) {
          } else {
            if (showErrorMessage) {
              CustomSnackBar.error(res.message.error.join(''));
            }
          }
        } catch (e) {
          log.e('Failed to parse error response: $e');
        }

        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');
      if (showErrorMessage) {
        CustomSnackBar.error('Check your Internet Connection and try again!');
      }
      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');
      if (showErrorMessage) {
        CustomSnackBar.error('Something Went Wrong! Try again');
      }
      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      // Transient server/proxy resets sometimes happen mid-response.
      // Retry once to reduce flakiness for idempotent GET requests.
      if (err.toString().toLowerCase().contains('connection closed while receiving data')) {
        try {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          final retryResponse = await doGet();
          if (retryResponse.statusCode == code) {
            try {
              String sanitizedBody = retryResponse.body
                  .replaceAll(':nul,', ':null,')
                  .replaceAll(':nul}', ':null}')
                  .replaceAll(':nul]', ':null]')
                  .replaceAll(RegExp(r'"\s*"'), '","');
              return jsonDecode(sanitizedBody);
            } catch (e) {
              log.e('🐞🐞🐞 JSON Decode Error (retry) 🐞🐞🐞');
              log.e('Response length: ${retryResponse.body.length}');
              log.e('Error: $e');
              if (showErrorMessage) {
                CustomSnackBar.error('Failed to process server response');
              }
              return null;
            }
          }
        } catch (_) {
          // ignore retry errors; fall through
        }
      }

      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }

  // Post Method
  Future<Map<String, dynamic>?> post(
    String url,
    Map<String, dynamic> body, {
    int code = 201,
    int duration = 120,
    bool showResult = false,
    bool showErrorMessage = true,
  }) async {
    try {
      log.i(
          '|📍📍📍|-----------------[[ POST ]] method details start -----------------|📍📍📍|');

      log.i(url);

      log.i(body);

      log.i(
          '|📍📍📍|-----------------[[ POST ]] method details end ------------|📍📍📍|');

      final response = await http
          .post(
            Uri.parse(url),
            body: jsonEncode(body),
            headers: isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
          )
          .timeout(Duration(seconds: duration));

      log.i(
          '|📒📒📒|-----------------[[ POST ]] method response start ------------------|📒📒📒|');

      if (showResult) {
        log.i(response.body.toString());
      }

      log.i(response.statusCode);

      log.i(
          '|📒📒📒|-----------------[[ POST ]] method response end --------------------|📒📒📒|');
      bool isMaintenance = response.statusCode == 503;

      _maintenanceCheck(isMaintenance, response.body);

      // Check Unauthorized
      if (response.statusCode == 401) {
        LocalStorage.clear();
      }
      // Check Server Error
      if (response.statusCode == 500) {
        CustomSnackBar.error(Strings.serverError);
        Get.offAllNamed(Routes.loginScreen);
      }
      if (response.statusCode == 401) {
        Get.offAllNamed(Routes.loginScreen);
        LocalStorage.clear();
      }

      if (response.statusCode == code) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          log.e('🐞🐞🐞 JSON Decode Error 🐞🐞🐞');
          log.e('Response length: ${response.body.length}');
          log.e('Error: $e');
          if (showErrorMessage) {
            CustomSnackBar.error('Failed to process server response');
          }
          return null;
        }
      } else {
        log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');

        try {
          log.e(
              'unknown error hitted in status code ${jsonDecode(response.body)}');

          ErrorResponse res = ErrorResponse.fromJson(jsonDecode(response.body));

          if (isMaintenance) {
          } else {
            if (showErrorMessage) {
              CustomSnackBar.error(res.message.error.join(''));
            }
          }
        } catch (e) {
          log.e('Failed to parse error response: $e');
        }

        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');

      if (showErrorMessage) {
        CustomSnackBar.error('Check your Internet Connection and try again!');
      }

      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');

      CustomSnackBar.error('Something Went Wrong! Try again');

      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());
      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }

  // Post Method
  Future<Map<String, dynamic>?> multipart(
      String url, Map<String, String> body, String filepath, String filedName,
      {int code = 200, bool showResult = false}) async {
    try {
      log.i(
          '|📍📍📍|-----------------[[ Multipart ]] method details start -----------------|📍📍📍|');

      log.i(url);

      log.i(body);
      log.i(filepath);

      log.i(
          '|📍📍📍|-----------------[[ Multipart ]] method details end ------------|📍📍📍|');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      )
        ..fields.addAll(body)
        ..headers.addAll(
          isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
        )
        ..files.add(await http.MultipartFile.fromPath(filedName, filepath));
      var response = await request.send();
      var jsonData = await http.Response.fromStream(response);

      log.i(
          '|📒📒📒|-----------------[[ POST ]] method response start ------------------|📒📒📒|');

      log.i(jsonData.body.toString());

      log.i(response.statusCode);

      log.i(
          '|📒📒📒|-----------------[[ POST ]] method response end --------------------|📒📒📒|');
      bool isMaintenance = response.statusCode == 503;

      _maintenanceCheck(isMaintenance, jsonData);

      if (response.statusCode == code) {
        try {
          return jsonDecode(jsonData.body) as Map<String, dynamic>;
        } catch (e) {
          log.e('🐞🐞🐞 JSON Decode Error 🐞🐞🐞');
          log.e('Response length: ${jsonData.body.length}');
          log.e('Error: $e');
          CustomSnackBar.error('Failed to process server response');
          return null;
        }
      } else {
        log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');

        try {
          log.e(
              'unknown error hitted in status code ${jsonDecode(jsonData.body)}');

          ErrorResponse res = ErrorResponse.fromJson(jsonDecode(jsonData.body));

          if (!isMaintenance) CustomSnackBar.error(res.message.error.toString());
        } catch (e) {
          log.e('Failed to parse error response: $e');
        }

        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');

      CustomSnackBar.error('Check your Internet Connection and try again!');

      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');

      CustomSnackBar.error('Something Went Wrong! Try again');

      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }

  // multipart multi file Method
  Future<Map<String, dynamic>?> multipartMultiFile(
    String url,
    Map<String, String> body, {
    int code = 200,
    bool showResult = false,
    required List<String> pathList,
    required List<String> fieldList,
  }) async {
    try {
      log.i(
          '|📍📍📍|-----------------[[ Multipart ]] method details start -----------------|📍📍📍|');

      log.i(url);

      if (showResult) {
        log.i(body);
        log.i(pathList);
        log.i(fieldList);
      }

      log.i(
          '|📍📍📍|-----------------[[ Multipart ]] method details end ------------|📍📍📍|');
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      )
        ..fields.addAll(body)
        ..headers.addAll(
          isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
        );

      for (int i = 0; i < fieldList.length; i++) {
        request.files
            .add(await http.MultipartFile.fromPath(fieldList[i], pathList[i]));
      }

      var response = await request.send();
      var jsonData = await http.Response.fromStream(response);

      log.i(
          '|📒📒📒|-----------------[[ POST ]] method response start ------------------|📒📒📒|');

      log.i(jsonData.body.toString());

      log.i(response.statusCode);

      log.i(
          '|📒📒📒|-----------------[[ POST ]] method response end --------------------|📒📒📒|');
      bool isMaintenance = response.statusCode == 503;

      if (response.statusCode == 500) {
        CustomSnackBar.error(Strings.serverError);
        Get.offAllNamed(Routes.loginScreen);
      }
      if (response.statusCode == 401) {
        Get.offAllNamed(Routes.loginScreen);
        LocalStorage.clear();
      }
      _maintenanceCheck(isMaintenance, jsonData);

      if (response.statusCode == code) {
        try {
          return jsonDecode(jsonData.body) as Map<String, dynamic>;
        } catch (e) {
          log.e('🐞🐞🐞 JSON Decode Error 🐞🐞🐞');
          log.e('Response length: ${jsonData.body.length}');
          log.e('Error: $e');
          CustomSnackBar.error('Failed to process server response');
          return null;
        }
      } else {
        log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');

        try {
          log.e(
              'unknown error hitted in status code ${jsonDecode(jsonData.body)}');

          ErrorResponse res = ErrorResponse.fromJson(jsonDecode(jsonData.body));

          if (!isMaintenance) CustomSnackBar.error(res.message.error.toString());
        } catch (e) {
          log.e('Failed to parse error response: $e');
        }

        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');

      CustomSnackBar.error('Check your Internet Connection and try again!');

      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');

      CustomSnackBar.error('Something Went Wrong! Try again');

      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }

  void _maintenanceCheck(bool isMaintenance, var jsonData) {
    final controller = Get.put(SystemMaintenanceController());
    if (isMaintenance) {
      controller.maintenanceStatus.value = true;
      MaintenanceModel maintenanceModel =
          MaintenanceModel.fromJson(jsonDecode(jsonData));
      MaintenanceDialog().show(maintenanceModel: maintenanceModel);
    } else {
      controller.maintenanceStatus.value = false;
    }
  }
}
