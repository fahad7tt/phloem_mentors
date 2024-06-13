String? getYouTubeVideoIdFromUrl(String url) {
  final Uri uri = Uri.parse(url);
  if (uri.host == 'youtu.be') {
    return uri.pathSegments.last;
  } else {
    final queryParams = uri.queryParameters;
    if (queryParams.isNotEmpty) {
      return queryParams['v'];
    } else {
      return uri.pathSegments.last;
    }
  }
}