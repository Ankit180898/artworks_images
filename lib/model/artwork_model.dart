// artwork_model.dart

class Artwork {
  final int id;
  final String title;
  final String artistDisplay;
  final String imageId;
  final String dateDisplay;
  final String mediumDisplay;
  final String placeOfOrigin;

  // Constructor for initializing the Artwork object
  Artwork({
    required this.id,
    required this.title,
    required this.artistDisplay,
    required this.imageId,
    required this.dateDisplay,
    required this.mediumDisplay,
    required this.placeOfOrigin,
  });

  // Factory method to parse the JSON data and create an Artwork object
  factory Artwork.fromJson(Map<String, dynamic> json) {
    return Artwork(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Untitled',
      artistDisplay: json['artist_display'] ?? 'Unknown Artist',
      imageId: json['image_id'] ?? '',
      dateDisplay: json['date_display'] ?? 'Unknown Date',
      mediumDisplay: json['medium_display'] ?? 'Unknown Medium',
      placeOfOrigin: json['place_of_origin'] ?? 'Unknown Origin',
    );
  }

  // Convert Artwork object to JSON map for serialization (optional)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist_display': artistDisplay,
      'image_id': imageId,
      'date_display': dateDisplay,
      'medium_display': mediumDisplay,
      'place_of_origin': placeOfOrigin,
    };
  }
}
