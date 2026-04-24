class DecryptRequestModel {
  final String bytes;

  const DecryptRequestModel({required this.bytes});

  Map<String, dynamic> toJson() => {'bytes': bytes};
}
