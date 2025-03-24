class ErrorService {
  static String handleError(dynamic error) {
    if (error is Exception) {
      return 'Bir hata oluştu: ${error.toString()}';
    }
    return 'Beklenmeyen bir hata oluştu';
  }

  static String handleNetworkError() {
    return 'İnternet bağlantınızı kontrol edin';
  }

  static String handleTimeoutError() {
    return 'İstek zaman aşımına uğradı';
  }

  static String handleValidationError(String message) {
    return 'Doğrulama hatası: $message';
  }
}
