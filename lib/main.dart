import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const CatTinderApp());
}

class CatTinderApp extends StatelessWidget {
  const CatTinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cat Tinder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(230, 44, 239, 0),
        ),
      ),
      home: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/paws_background.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            CatScreen(),
          ],
        ),
      ),
    );
  }
}

class CatScreen extends StatefulWidget {
  const CatScreen({super.key});

  @override
  State<CatScreen> createState() => _CatScreenState();
}

class _CatScreenState extends State<CatScreen> {
  int _counter = 0;
  String? _catImageUrl;
  String _breed = "";
  Container? _cards;
  Image? _image;

  @override
  void initState() {
    super.initState();
    fetchCatImage();
  }

  Future<void> fetchCatImage() async {
    final url = Uri.parse(
      "https://api.thecatapi.com/v1/images/search?has_breeds=1&api_key=live_0oOZtuN0kXT6kVD79yoccKZkoAXtVJNSSxXEFl5iuG1Orknk2u4LEbkd6JSxPBJm",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _catImageUrl = data[0]["url"];
        _breed = "Breed: ${data[0]["breeds"][0]["name"]}";
        Map<String, String> information = {
          "country": data[0]["breeds"][0]["origin"],
          "temperament": data[0]["breeds"][0]["temperament"],
          "description": data[0]["breeds"][0]["description"],
          "lifespan": data[0]["breeds"][0]["life_span"],
        };

        _image = Image.network(
          _catImageUrl!,
          width: 320,
          height: 550,
          fit: BoxFit.cover,
        );
        _cards = Container(
          alignment: Alignment.center,
          width: 400,
          height: 600,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Color.fromARGB(255, 73, 225, 70),
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CatInformation(information, _image!),
                ),
              );
            },
            child: _image,
          ),
        );
      });
    }
  }

  final CardSwiperController controller = CardSwiperController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 73, 225, 70),
        title: const Center(
          child: Text(
            "Cat Tinder",
            style: TextStyle(
              color: Color.fromARGB(255, 19, 48, 22),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: CardSwiper(
              controller: controller,
              cardsCount: 1,
              onSwipe: _onSwipe,
              allowedSwipeDirection: AllowedSwipeDirection.only(
                left: true,
                right: true,
              ),
              numberOfCardsDisplayed: 1,
              cardBuilder: (
                context,
                index,
                horizontalThresholdPercentage,
                verticalThresholdPercentage,
              ) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _breed,
                      style: TextStyle(
                        color: Color.fromARGB(255, 19, 48, 22),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(child: _cards),
                  ],
                );
              },
            ),
          ),
          Align(
            alignment: FractionalOffset(0.8, 0.95),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Number of likes: $_counter",
                  style: TextStyle(
                    color: Color.fromARGB(255, 19, 48, 22),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      onPressed: _dislikeCat,
                      text: "Dislike",
                      color: Color.fromARGB(255, 175, 255, 153),
                      size: Size(100, 20),
                    ),
                    const SizedBox(width: 10),
                    CustomButton(
                      onPressed: _likeCat,
                      text: "Like",
                      color: Color.fromARGB(255, 0, 255, 51),
                      size: Size(100, 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    _breed = "";
    _image = null;
    _cards = null;
    if (direction == CardSwiperDirection.right) {
      _counter++;
    }
    fetchCatImage();
    return true;
  }

  void _likeCat() {
    setState(() {
      _counter++;
    });
    fetchCatImage();
  }

  void _dislikeCat() {
    fetchCatImage();
  }
}

Widget _getInfo(String key, String value) {
  return Text(
    "$key: $value",
    textAlign: TextAlign.center,
    style: TextStyle(
      fontFamily: 'Courier',
      color: Color.fromARGB(255, 0, 0, 0),
      fontSize: 18,
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.visible,
    ),
  );
}

class CatInformation extends StatelessWidget {
  final Map<String, String> information;
  final Image image;

  const CatInformation(this.information, this.image, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Back')),
      body: Container(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: SizedBox(
            width: 400,
            height: 700,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Opacity(opacity: 0.5, child: image),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    if (information['country'] != null)
                      _getInfo("Country", information['country']!),
                    if (information['lifespan'] != null)
                      _getInfo("Life span", information['lifespan']!),
                    if (information['temperament'] != null)
                      _getInfo("Temperament", information['temperament']!),
                    if (information['description'] != null)
                      _getInfo("Description", information['description']!),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color color;
  final Size size;
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.color,
    required this.size,
  });
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(color),
        fixedSize: WidgetStateProperty.all<Size>(size),
      ),
      onPressed: onPressed,
      child: Center(child: Text(text)),
    );
  }
}
