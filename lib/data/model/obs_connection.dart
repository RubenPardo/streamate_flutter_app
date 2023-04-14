import 'dart:convert';
import 'dart:developer';

class OBSConnection{
  final String address;
  final int port;
  final String? password;

  OBSConnection({required this.address,this.port = 4455,this.password});

  @override
  String toString(){
    return 'ws://$address:$port';
  }

   factory OBSConnection.fromJson(Map<String, Object?> value) {
    log(value.toString());
    return OBSConnection(
      address: value['ip'] != null ? value['ip'] as String: '',
      password: value['password'] != null ? value['password'] as String: null,
      port: int.parse(value['port'] != null ? value['port'] as String : '4455')
    );
   }

  static Map<String, dynamic> toMap(OBSConnection model) => 
    <String, dynamic> {
      'ip': model.address,
      'port': model.port.toString(),
      'password': model.password,
    };

  String serialize() =>
    json.encode(OBSConnection.toMap(this));

  static OBSConnection deserialize(String json) =>
    OBSConnection.fromJson(jsonDecode(json));


}