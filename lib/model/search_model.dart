class SearchResult {
  final int? id;
  final String? title;
  final String? artistTitle;
  final String? imageId;
  final String? dateDisplay;

  SearchResult({
    this.id,
    this.title,
    this.artistTitle,
    this.imageId,
    this.dateDisplay,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'],
      title: json['title'],
      artistTitle: json['artist_title'],
      imageId: json['image_id'],
      dateDisplay: json['date_display'],
    );
  }
}