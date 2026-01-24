import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheManager {
  static const key = 'customImageCache';

  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: DioFileService(),
    ),
  );
}

class DioFileService extends FileService {
  late final Dio _dio;

  DioFileService({Dio? dio}) {
    _dio = dio ??
        Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
          ),
        );
    
    // Add retry interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, ErrorInterceptorHandler handler) async {
        // Retry logic for timeout or connection errors
        if (_shouldRetry(e)) {
          // Simple retry mechanism could be added here or use a retry package
          // For now, we rely on longer timeouts. 
          // If we want to implement retry:
          // We need to keep track of retries, which is hard in interceptor without extra state.
        }
        handler.next(e);
      },
    ));
  }

  bool _shouldRetry(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
           e.type == DioExceptionType.receiveTimeout ||
           e.type == DioExceptionType.sendTimeout ||
           e.type == DioExceptionType.connectionError;
  }

  @override
  Future<FileServiceResponse> get(String url, {Map<String, String>? headers}) async {
    // Simple retry loop
    int retries = 3;
    Duration delay = const Duration(seconds: 1);

    for (int i = 0; i < retries; i++) {
      try {
        final response = await _dio.get<ResponseBody>(
          url,
          options: Options(
            headers: headers,
            responseType: ResponseType.stream,
          ),
        );
        return DioFileServiceResponse(response);
      } catch (e) {
        if (i == retries - 1) rethrow;
        if (e is DioException && _shouldRetry(e)) {
          await Future.delayed(delay * (i + 1));
          continue;
        }
        rethrow;
      }
    }
    throw Exception('Failed to load image after retries');
  }
}

class DioFileServiceResponse implements FileServiceResponse {
  final Response<ResponseBody> _response;

  DioFileServiceResponse(this._response);

  @override
  Stream<List<int>> get content => _response.data!.stream;

  @override
  int get contentLength {
    final length = _response.headers.value('content-length');
    return length != null ? int.parse(length) : -1;
  }

  @override
  String get fileExtension {
    final contentType = _response.headers.value('content-type');
    if (contentType != null) {
      if (contentType.contains('jpeg') || contentType.contains('jpg')) return '.jpg';
      if (contentType.contains('png')) return '.png';
      if (contentType.contains('gif')) return '.gif';
      if (contentType.contains('webp')) return '.webp';
      if (contentType.contains('bmp')) return '.bmp';
    }
    return '.jpg'; // Default fallback
  }

  @override
  int get statusCode => _response.statusCode ?? 200;

  @override
  DateTime get validTill {
    // Try to parse Cache-Control header
    final cacheControl = _response.headers.value('cache-control');
    if (cacheControl != null) {
      final directives = cacheControl.split(',');
      for (final directive in directives) {
        final parts = directive.trim().split('=');
        if (parts.length == 2 && parts[0] == 'max-age') {
          final maxAge = int.tryParse(parts[1]);
          if (maxAge != null) {
            return DateTime.now().add(Duration(seconds: maxAge));
          }
        }
      }
    }
    // Default 7 days
    return DateTime.now().add(const Duration(days: 7));
  }
  
  @override
  String? get eTag => _response.headers.value('etag');
}

