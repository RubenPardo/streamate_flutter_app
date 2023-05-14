/// clase que representa la categoria del directo
class StreamCategory{
  final String gameId;
  final String gameName;
  final String? boxArtUrl;

  StreamCategory({required this.gameId, required this.gameName, this.boxArtUrl});


  factory StreamCategory.fromJson(Map<String, dynamic> json){
    return StreamCategory(
      gameId: json['id'], 
      gameName: json['name'],
      boxArtUrl: json['box_art_url']
    );
  }

  @override
  String toString() {
    return 'StreamCategory: [gameId: $gameId, gameName: $gameName]';
  }
}