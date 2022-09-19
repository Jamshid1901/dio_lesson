import 'dart:developer';
import 'dart:io';


import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';


abstract class ApiClient {
  static Dio? _dio;
  static late String _apiBaseUrl;

  static void _initDio() {
    _dio = Dio();
    _apiBaseUrl = 'https://reqres.in/api';
  }

  static Future<dynamic> _dioRequest({
    String endPointSuffix = '',
    String? method = 'POST',
    Map<String, String>? header,
    Map<String, dynamic>? requestBody,
    FormData? requestFormData,
  }) async {
    final httpHeaders = await _httpHeaders(header, requestFormData != null);
    if (_dio == null) _initDio();

    try {
      method = method ?? 'POST';
      print('*******REQUEST*******');
      print('URL ${_apiBaseUrl + endPointSuffix}');
      print('Body: $requestBody');
      print('Header: $httpHeaders');
      final response = await _dio!.request<dynamic>(
        _apiBaseUrl + endPointSuffix,
        data: requestFormData ?? requestBody,
        options: Options(
          method: method,
          contentType: httpHeaders['content-type'],
          headers: httpHeaders,
        ),
      );
      print('*********RESPONSE********');
      inspect(response.data);
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        log('*********RESPONSE WITH ERROR********');
      }
      return e;
    } catch (e, stacktrace) {
      print(e.toString());
      print(stacktrace.toString());
      rethrow;
    }
  }

  ///returns [Map<String, String>] with http headers for each request
  static Future<Map<String, String>> _httpHeaders(
      Map<String, String>? header, [
        bool hasFormData = false,
      ]) async {
    Map<String, String> httpHeaders = header ?? <String, String>{};

    if (hasFormData) {
      httpHeaders.addAll({'content-type': 'multipart/form-data'});
    } else {
      httpHeaders.addAll({'content-type': 'application/json'});
    }

    const accessToken = "token";

    if (accessToken.isNotEmpty) {
      httpHeaders.addAll({'Authorization': accessToken});
    }

    return httpHeaders;
  }

  static Future<dynamic> restRequest<T>({
    required String apiEndPoint,
    required T Function(Response<dynamic>) onSuccess,
    required dynamic Function(dynamic response) onError,
    String? method,
    String? formName,
    File? formData,
    Map<String, dynamic>? body,
    Map<String, String>? header,
  }) async {
    final requestBody = body != null ? _requestBody(variables: body) : null;
    FormData? requestFormData;
    if (formData != null) {
      requestFormData = await _formData(

        data: formData,
      );
    }

    try {
      final dynamic result = await _dioRequest(
        endPointSuffix: apiEndPoint,
        method: method,
        header: header,
        requestBody: requestBody,
        requestFormData: requestFormData,
      );

      if (result is DioError) {
        print(result);
        if (result.response?.data is Map<String, dynamic>) {
          if ((result.response?.data as Map<String, dynamic>)
              .containsKey('error_message')) {
            return onError(result.response?.data);
          }
        }
        return onError('Connection ${result.response?.data}');
      }

      return onSuccess(result);
    } catch (e) {
      return e.toString();
    }
  }

  ///returns [Map<String, String>] with request body
  static Map<String, dynamic> _requestBody({
    String? query,
    required Map<String, dynamic> variables,
  }) {
    Map<String, dynamic> requestBody = <String, dynamic>{};

    if (query != null) {
      requestBody.addAll(<String, dynamic>{
        'query': query.replaceAll('\n', ' '),
      });
    }

    if (query == null) {
      requestBody.addAll(variables);
    } else {
      requestBody.addAll(<String, dynamic>{'variables': variables});
    }

    return requestBody;
  }

  static Future<FormData> _formData({
    required File data,
  }) async {
    String fileName = data.path.split('/').last;
    String fileType = fileName.split('.')[fileName.split('.').length - 1];
    log(fileName);
    log(data.path);
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        data.path,
        filename: fileName,
        contentType: MediaType('image', fileType),
      ),
    });

    return formData;
  }
}
