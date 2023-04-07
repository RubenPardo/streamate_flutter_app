class OBSConnection{
  final String address;
  final int port;
  final String? password;

  OBSConnection({required this.address,this.port = 4455,this.password});

  @override
  String toString(){
    return 'ws://$address:$port';
  }
}