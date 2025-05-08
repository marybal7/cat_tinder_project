import 'dart:typed_data';
import 'breed_info.dart';

class Cat {
  final String imageUrl;
  final BreedInfo breedInfo;
  final Uint8List? imageData;

  Cat({required this.imageUrl, required this.breedInfo, this.imageData});

  factory Cat.fromJson(Map<String, dynamic> json) {
    return Cat(
      imageUrl: json['url'],
      breedInfo: BreedInfo.fromJson(json['breeds'][0]),
    );
  }
}
