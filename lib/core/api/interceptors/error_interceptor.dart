import 'package:dio/dio.dart';
import '../../error/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // We create a new DioException that wraps our custom exception.
    // This allows the repository layer to catch a DioException and inspect
    // the .error property to get our custom exception type.
    DioException newError;
    String errorMessage;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Timeout Error: The request took too long.';
        newError = DioException(
          requestOptions: err.requestOptions,
          error: ServerException(message: errorMessage),
        );
        break; // Use break to exit the switch

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final responseData = err.response?.data;
        // Try to get a meaningful error message from the response
        errorMessage = (responseData is Map ? responseData['message'] : null) ?? 
                       err.response?.statusMessage ?? 
                       'Received invalid status code: $statusCode';

        if (statusCode == 401) {
          newError = DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            error: UnauthorizedException(message: errorMessage),
          );
        } if (statusCode == 404) {
          newError = DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            error: NotFoundException(message: errorMessage),
          );
        } else {
          newError = DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            error: ServerException(message: errorMessage, statusCode: statusCode),
          );
        }
        break; // Use break to exit the switch

      case DioExceptionType.cancel:
        // If the request was cancelled, we don't treat it as an error.
        // We just pass it along.
        return super.onError(err, handler);

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
      // In newer Dio versions, no internet is often a 'connectionError'
      // We will map both to a NetworkException for clarity.
      default:
        newError = DioException(
          requestOptions: err.requestOptions,
          error: NetworkException(), // Use a dedicated NetworkException
        );
        break; // Use break to exit the switch
    }
    
    // Reject the promise with our new, custom error.
    return handler.reject(newError);
  }
}