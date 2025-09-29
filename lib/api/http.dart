import 'package:dio/dio.dart';

class Http {
  static final Http _instance = Http._internal();
  factory Http() => _instance;

  late Dio dio;

  Http._internal() {
    dio = Dio(BaseOptions(
      baseUrl: "http://transient.online/client", // 统一配置baseUrl
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
      },
    ));

    // 请求拦截器
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 例如：加 token
        options.headers["Authorization"] = "Bearer your_token";
        print("➡️ 请求: ${options.method} ${options.uri}");
        handler.next(options);
      },
      onResponse: (response, handler) {
        print("✅ 响应: ${response.statusCode} ${response.data}");
        handler.next(response);
      },
      onError: (DioException e, handler) {
        print("❌ 错误: ${e.message}");
        handler.next(e);
      },
    ));
  }

  /// GET 请求
  Future<Response<T>> get<T>(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  /// POST 请求
  Future<Response<T>> post<T>(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  /// PUT 请求
  Future<Response<T>> put<T>(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  /// DELETE 请求
  Future<Response<T>> delete<T>(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return await dio.delete(path, queryParameters: queryParameters);
  }
}
