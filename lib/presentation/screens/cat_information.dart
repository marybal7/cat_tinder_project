import 'package:flutter/material.dart';
import '../../domain/models/cat.dart';

class CatInformation extends StatelessWidget {
  final Cat cat;
  final Widget image;

  const CatInformation({super.key, required this.cat, required this.image});

  Widget _getInfo(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        "$key: $value",
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Courier',
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final breed = cat.breedInfo;

    return Scaffold(
      appBar: AppBar(title: const Text('Back')),
      body: Container(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Opacity(opacity: 0.5, child: image),
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _getInfo("Breed", breed.name),
                      _getInfo("Country", breed.origin),
                      _getInfo("Life span", breed.lifespan),
                      _getInfo("Temperament", breed.temperament),
                      _getInfo("Description", breed.description),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
