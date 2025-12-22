import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:sonoul/common/config/config.dart';
import 'package:sonoul/common/res/app_strings.dart';
import 'package:sonoul/utils/sp_util.dart';
import 'package:sonoul/utils/toast_util.dart';

class DioUtils {
  static final DioUtils _instance = DioUtils._internal();

  factory DioUtils() => _instance;

  late Dio _dio;

  String? _token; // 本地缓存的 Token

  DioUtils._internal() {
    // 初始化 Dio
    BaseOptions options = BaseOptions(
      baseUrl: AppConfig.baseUrl, // 替换为你的 API 地址
      connectTimeout: const Duration(milliseconds: 10000), // 连接超时
      receiveTimeout: const Duration(milliseconds: 10000), // 响应超时
    );

    _dio = Dio(options);

    // Add Pretty Logger
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));

    // 添加请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 每次请求时自动添加 Token
        if (!options.headers.containsKey('Authorization')) {
          String token = _getToken();
          options.headers['Authorization'] = token;
        }
        // 网络连接正常，继续请求
        handler.next(options);
      },
      onResponse: (response, handler) {
        parseResponse(response);
        handler.next(response);
      },
      onError: (error, handler) {
        handler.next(error); // 必须调用，继续错误处理
      },
    ));
  }

  /// 获取本地存储的 Token，如果没有则从缓存读取
  String _getToken() {
    // 如果 token 已经缓存到内存，则直接返回
    if (_token != null) {
      return _token ?? "";
    }

    // 否则从本地存储获取
    _token = SpUtil.getString(AppStrings.spToken) ?? '';
    return _token ?? "";
  }

  /// GET 请求
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      return await _handleError(e, path);
    } finally {
    }
  }

  /// POST 请求
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      return await _handleError(e, path);
    } finally {
    }
  }

  /// 统一处理响应
  Future parseResponse<T>(Response response) async {
    try {
      // 根据 API 响应格式来判断 code
      if (response.data['statusCode'] == 200) {
        // 解析成功，返回数据
        return response.data;
      } else {
        // 如果 code 不为 1，记录错误日志并抛出异常
        String code = response.data['statusCode'] ?? '0';
        String message = response.data['message'] ?? '请求失败';
        ToastUtils.shotToast(message);
        debugPrint('API 返回错误，code: $code, message: $message'); // 输出日志
      }
    } catch (e, stackTrace) {
      // 捕获异常并输出日志
      debugPrint('解析响应失败: $e');
      debugPrint('堆栈信息: $stackTrace');
    }
  }

  /// 错误处理
  Future<Response> _handleError(
    dynamic error,
    String path,
  ) async {
    if (error is DioException) {
      // 网络相关错误处理
      if (error.type == DioExceptionType.connectionTimeout) {
        debugPrint('连接超时，请检查网络');
      } else if (error.type == DioExceptionType.sendTimeout) {
        debugPrint('请求超时，无法发送请求');
      } else if (error.type == DioExceptionType.receiveTimeout) {
        debugPrint('响应超时，请稍后重试');
      } else if (error.type == DioExceptionType.badCertificate) {
        debugPrint('证书错误，请检查 SSL 证书配置');
      } else if (error.type == DioExceptionType.cancel) {
        debugPrint('请求已被取消');
      } else if (error.type == DioExceptionType.connectionError) {
        debugPrint('连接错误，无法连接到服务器');
      } else if (error.type == DioExceptionType.unknown) {
        debugPrint('未知错误: ${error.message}');
      }

      // 服务器响应错误处理，依据 HTTP 状态码
      if (error.response != null) {
        switch (error.response?.statusCode) {
          case 400:
            debugPrint('错误请求 (400): 请求无效或参数错误');
          case 401:
            debugPrint('未授权 (401): Token 可能已过期');
          case 403:
            debugPrint('禁止访问 (403): 无权限访问该资源');
          case 404:
            debugPrint('未找到资源 (404): 请求的资源不存在');
          case 408:
            debugPrint('请求超时 (408): 请求超时');
          case 500:
            debugPrint('服务器错误 (500): 服务器内部错误，请稍后再试');
          case 502:
            debugPrint('错误网关 (502): 网关错误，请稍后重试');
          case 503:
            debugPrint('服务不可用 (503): 服务不可用，请稍后再试');
          case 504:
            debugPrint('网关超时 (504): 请求超时，请稍后再试');
          default:
            // 如果状态码不在上面列出的范围内，给出通用错误信息
            debugPrint(
                '服务器错误 (HTTP ${error.response?.statusCode}): ${error.response?.statusMessage}');
        }
      }
    } else {
      // 如果错误不是 DioException 类型，抛出一个未知异常
      debugPrint('未知异常: $error');
    }

    // 永远不会返回 null，这里为防止编译器误判返回，虽然代码中实际不会走到这一步
    throw("未知错误，无法处理");
  }
}
