import 'breed_info.dart';

class Cat {
  final String imageUrl;
  final BreedInfo breedInfo;

  Cat({required this.imageUrl, required this.breedInfo});

  factory Cat.fromJson(Map<String, dynamic> json) {
    return Cat(
      imageUrl: json['url'],
      breedInfo: BreedInfo.fromJson(json['breeds'][0]),
    );
  }
}
