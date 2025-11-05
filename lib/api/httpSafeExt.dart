// http_safe_ext.dart
import 'package:dio/dio.dart';
import 'package:transientmobile/api/safeHttp.dart';
import 'http.dart'; // 你的 Http 单例文件

extension HttpSafe on Http {
  Future<ApiResponse<Response<T>>> safeGet<T>(
      String path, { Map<String, dynamic>? queryParameters }
      ) {
    return safeService<Response<T>>(
          () => get<T>(path, queryParameters: queryParameters),
    );
  }

  Future<ApiResponse<Response<T>>> safePost<T>(
      String path, { dynamic data }
      ) {
    return safeService<Response<T>>(
          () => post<T>(path, data: data),
    );
  }

  Future<ApiResponse<Response<T>>> safePut<T>(
      String path, { dynamic data }
      ) {
    return safeService<Response<T>>(
          () => put<T>(path, data: data),
    );
  }

  Future<ApiResponse<Response<T>>> safeDelete<T>(
      String path, { Map<String, dynamic>? queryParameters }
      ) {
    return safeService<Response<T>>(
          () => delete<T>(path, queryParameters: queryParameters),
    );
  }
}
