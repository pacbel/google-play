// API response: {"text": "Carlos"}
class DecryptResponseModel {
  final String text;

  const DecryptResponseModel({required this.text});

  factory DecryptResponseModel.fromJson(Map<String, dynamic> json) {
    return DecryptResponseModel(text: json['text'] as String);
  }

  Map<String, dynamic> toJson() => {'text': text};
}
