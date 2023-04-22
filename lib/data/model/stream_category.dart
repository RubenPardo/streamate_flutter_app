/// clase que representa la categoria del directo
class StreamCategory{
  final String gameId;
  final String gameName;

  StreamCategory({required this.gameId, required this.gameName});

  @override
  String toString() {
    return 'StreamCategory: [gameId: $gameId, gameName: $gameName]';
  }
}