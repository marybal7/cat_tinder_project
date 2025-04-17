import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';
import '../../core/di/setup.dart';
import '../../domain/models/cat.dart';
import '../../domain/usecases/fetch_cat_usecase.dart';
import '../providers/liked_cats_provider.dart';
import '../widgets/custom_button.dart';
import 'cat_information.dart';
import 'liked_cats_screen.dart';

class CatScreen extends StatefulWidget {
  const CatScreen({super.key});

  @override
  State<CatScreen> createState() => _CatScreenState();
}

class _CatScreenState extends State<CatScreen> {
  final CardSwiperController _controller = CardSwiperController();
  final FetchCatUseCase _fetchCatUseCase = getIt<FetchCatUseCase>();

  Cat? _currentCat;
  bool _isLoading = true;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _loadCat();
  }

  Future<void> _loadCat() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cat = await _fetchCatUseCase.execute();
      setState(() {
        _currentCat = cat;
      });
    } catch (e) {
      setState(() {});
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Network Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadCat();
                },
                child: const Text('Retry'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
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
    if (direction == CardSwiperDirection.right && _currentCat != null) {
      Provider.of<LikedCatsProvider>(
        context,
        listen: false,
      ).addCat(_currentCat!);
      setState(() {
        _counter++;
      });
    }
    _loadCat();
    return true;
  }

  void _likeCat() {
    if (_currentCat != null) {
      Provider.of<LikedCatsProvider>(
        context,
        listen: false,
      ).addCat(_currentCat!);
      setState(() {
        _counter++;
      });
      _loadCat();
    }
  }

  void _dislikeCat() {
    _loadCat();
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) {
        _counter--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 73, 225, 70),
        centerTitle: true,
        leading: const SizedBox(width: 48),
        title: const Center(
          child: Text(
            "Cat Tinder",
            style: TextStyle(
              color: Color.fromARGB(255, 19, 48, 22),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) =>
                          LikedCatsScreen(decrementCounter: _decrementCounter),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.center,
        children: [
          if (_currentCat != null)
            Center(
              child: CardSwiper(
                controller: _controller,
                cardsCount: 1,
                onSwipe: _onSwipe,
                allowedSwipeDirection: AllowedSwipeDirection.only(
                  left: true,
                  right: true,
                ),
                numberOfCardsDisplayed: 1,
                cardBuilder: (context, index, _, __) {
                  final cat = _currentCat!;
                  final image = Image.network(
                    cat.imageUrl,
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height * 0.5,
                    fit: BoxFit.cover,
                  );

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Breed: ${cat.breedInfo.name}",
                          style: const TextStyle(
                            color: Color.fromARGB(255, 19, 48, 22),
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        CatInformation(cat: cat, image: image),
                              ),
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color.fromARGB(255, 73, 225, 70),
                            ),
                            child: image,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          Positioned(
            bottom: 40,
            right: 30,
            left: 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Number of likes: $_counter",
                  style: const TextStyle(
                    color: Color.fromARGB(255, 19, 48, 22),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      onPressed: _dislikeCat,
                      text: "Dislike",
                      color: const Color.fromARGB(255, 175, 255, 153),
                      size: Size(MediaQuery.of(context).size.width * 0.4, 50),
                    ),
                    const SizedBox(width: 10),
                    CustomButton(
                      onPressed: _likeCat,
                      text: "Like",
                      color: const Color.fromARGB(255, 0, 255, 51),
                      size: Size(MediaQuery.of(context).size.width * 0.4, 50),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
