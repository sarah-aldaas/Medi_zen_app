class TelecomResponseModel {
  final bool status;
  final String errNum;
  final String msg;

  TelecomResponseModel({
    required this.status,
    required this.errNum,
    required this.msg,
  });

  factory TelecomResponseModel.fromJson(Map<String, dynamic> json) {
    return TelecomResponseModel(
      status: json['status'] as bool,
      errNum: json['errNum'].toString(), // Handle both string and int (e.g., "201" or 201)
      msg: json['msg'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'errNum': errNum,
      'msg': msg,
    };
  }
}