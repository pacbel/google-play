// API response: {"bytes": "tsbZ4eHU"}
class EncryptResponseModel {
  final String bytes;

  const EncryptResponseModel({required this.bytes});

  factory EncryptResponseModel.fromJson(Map<String, dynamic> json) {
    return EncryptResponseModel(bytes: json['bytes'] as String);
  }

  Map<String, dynamic> toJson() => {'bytes': bytes};
}
