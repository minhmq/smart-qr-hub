String normalizeUrl(String url) {
  if (url.startsWith('www.')) {
    return 'https://$url';
  }
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    return 'https://$url';
  }
  return url;
}

