// api_response.dart
import 'package:dio/dio.dart';

/// 与 Kotlin 里的 ApiResponse 对齐
class ApiResponse<T> {
  final T? success;       // 成功结果
  final String? error;    // 错误消息（若失败）
  final ResErrorType f;   // 错误分类（默认为 request）

  const ApiResponse({
    this.success,
    this.error,
    this.f = ResErrorType.request,
  });

  bool get ok => error == null;
}

/// 错误分类（可按需精简/扩展）
enum ResErrorType {
  request,     // 业务/参数类问题、4xx等
  network,     // 网络不可达、断网
  timeout,     // 连接/发送/接收超时 or 408
  server,      // 5xx
  cancel,      // 请求被取消
  io,          // IO 层错误（很少单独区分到）
  exception,   // 其它未知异常
}

/// 安全调用（高阶函数）
Future<ApiResponse<T>> safeService<T>(Future<T> Function() apiCall) async {
  try {
    final data = await apiCall();
    return ApiResponse<T>(success: data);
  } on DioException catch (e, _) {
    final type = _mapDioError(e);
    final msg = _extractDioMessage(e) ?? e.message ?? 'Request error';
    return ApiResponse<T>(success: null, error: msg, f: type);
  } catch (e, _) {
    // 这里可以对接你自己的日志系统
    // LoggerUtil.error(e.toString(), Optional.of("Imperative Error"));
    return ApiResponse<T>(success: null, error: 'Unknown error', f: ResErrorType.exception);
  }
}

/// 将 DioException 映射成你的 ResErrorType
ResErrorType _mapDioError(DioException e) {
  // 先按 Dio 层面的错误类型兜底
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return ResErrorType.timeout;
    case DioExceptionType.badCertificate:
    case DioExceptionType.connectionError:
      return ResErrorType.network;
    case DioExceptionType.cancel:
      return ResErrorType.cancel;
    case DioExceptionType.unknown:
    case DioExceptionType.badResponse:
    // 继续看 HTTP 状态码
      break;
  }

  final status = e.response?.statusCode;
  if (status != null) {
    if (status == 408) return ResErrorType.timeout;
    if (status >= 500) return ResErrorType.server;
    if (status >= 400) return ResErrorType.request;
  }
  // 没有状态码，按网络错误或未知处理
  return e.type == DioExceptionType.connectionError
      ? ResErrorType.network
      : ResErrorType.exception;
}

/// 抽取后端返回的可读错误信息
String? _extractDioMessage(DioException e) {
  final data = e.response?.data;
  if (data == null) return null;
  // 常见后端格式适配：{ msg: "...", message: "...", error: "...", detail: "..." }
  if (data is Map) {
    for (final k in const ['msg', 'message', 'error', 'detail']) {
      final v = data[k];
      if (v is String && v.trim().isNotEmpty) return v;
    }
  }
  if (data is String && data.trim().isNotEmpty) return data;
  return null;
}
