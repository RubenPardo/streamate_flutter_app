

class OBSAudioTrack{
  final String name;
  final double volumenDB;
  final bool isMuted;
  final bool isGlobal;

  OBSAudioTrack({required this.name, required this.volumenDB, required this.isMuted, this.isGlobal = false});

  
}