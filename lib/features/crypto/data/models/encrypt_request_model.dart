class EncryptRequestModel {
  final String text;

  const EncryptRequestModel({required this.text});

  Map<String, dynamic> toJson() => {'text': text};
}
