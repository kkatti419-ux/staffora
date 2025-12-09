class NetworkUtils {
  static bool success(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }
}
