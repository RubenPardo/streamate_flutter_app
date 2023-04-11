class OBSStreamStatus{
  final String time;
  final bool isActive;

  OBSStreamStatus({required this.time, required this.isActive});

  factory OBSStreamStatus.initValue(){
    return OBSStreamStatus(time: '--:--:--',isActive: false);
  }
}