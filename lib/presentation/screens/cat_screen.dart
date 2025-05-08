import 'package:cached_network_image/cached_network_image.dart';
import 'package:cat_tinder/data/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../core/di/setup.dart';
import '../../domain/models/cat.dart';
import '../../domain/usecases/fetch_cat_usecase.dart';
import '../providers/liked_cats_provider.dart';
import '../widgets/custom_button.dart';
import 'cat_information.dart';
import 'liked_cats_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class CatScreen extends StatefulWidget {
  const CatScreen({super.key});

  @override
  State<CatScreen> createState() => _CatScreenState();
}

class _CatScreenState extends State<CatScreen> {
  final CardSwiperController _controller = CardSwiperController();
  final FetchCatUseCase _fetchCatUseCase = getIt<FetchCatUseCase>();
  final Connectivity _connectivity = getIt<Connectivity>();

  final List<Cat> _catsQueue = [];
  final Set<String> _shownCats = {};
  Cat? _currentCat;
  bool _isLoading = true;
  int get _counter => Provider.of<LikedCatsProvider>(context).likedCats.length;
  bool _isOffline = false;
  bool _noMoreCats = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _checkNetworkAndLoadCats();
    });
  }

  Future<void> _checkNetworkAndLoadCats() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    _isOffline = connectivityResult == ConnectivityResult.none;
    if (_isOffline && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'No internet connection. Using cached data.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 9, 44, 15),
          duration: const Duration(seconds: 10),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
    await _loadCats();
  }

  Future<void> _loadCats() async {
    setState(() {
      _isLoading = true;
      _noMoreCats = false;
    });

    try {
      final cats = <Cat>[];
      if (_isOffline) {
        final cachedCats = await getIt<AppDatabase>().getAllCats();
        if (cachedCats.isEmpty) {
          throw Exception('No internet and no cached cats available');
        }
        final validCats =
            cachedCats.where((cat) {
              final hasImageData = cat.imageData != null;
              return hasImageData;
            }).toList();
        if (validCats.isEmpty) {
          throw Exception('No cached cats with images available');
        }
        final newCats =
            validCats
                .where((cat) => !_shownCats.contains(cat.imageUrl))
                .toList();
        if (newCats.isEmpty) {
          setState(() {
            _noMoreCats = true;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'No more cats to show. Please wait until the internet connection is restored.',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: const Color.fromARGB(255, 4, 41, 21),
                duration: const Duration(seconds: 5),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: _checkNetworkAndLoadCats,
                ),
              ),
            );
          }
        } else {
          cats.addAll(newCats.take(3));
        }
      } else {
        for (var i = 0; i < 3; i++) {
          try {
            final cat = await _fetchCatUseCase.execute();
            if (cat.imageData == null) {
              final response = await http.get(Uri.parse(cat.imageUrl));
              if (response.statusCode == 200) {
                final imageData = response.bodyBytes;
                final updatedCat = Cat(
                  imageUrl: cat.imageUrl,
                  imageData: imageData,
                  breedInfo: cat.breedInfo,
                );
                await getIt<AppDatabase>().insertCat(
                  updatedCat,
                  imageData: imageData,
                );
                cats.add(updatedCat);
              } else {
                cats.add(cat);
              }
            } else {
              cats.add(cat);
            }
            if (cats.length >= 3) break;
          } catch (e) {
            break;
          }
        }
      }
      setState(() {
        _catsQueue.addAll(
          cats
              .map(
                (cat) => Cat(
                  imageUrl: cat.imageUrl,
                  imageData: cat.imageData,
                  breedInfo: cat.breedInfo,
                ),
              )
              .toList(),
        );
        for (var cat in _catsQueue) {
          _shownCats.add(cat.imageUrl);
        }
        if (_currentCat == null && _catsQueue.isNotEmpty) {
          _currentCat = _catsQueue.first;
        }
      });
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
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
            title: const Text('Error'),
            content: Text(
              message.contains('No internet and no cached cats available')
                  ? 'No internet connection and no cached cats available. Please connect to the internet to load new cats.'
                  : message,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _checkNetworkAndLoadCats();
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
      final likedCatsProvider = Provider.of<LikedCatsProvider>(
        context,
        listen: false,
      );
      if (!likedCatsProvider.likedCats.any(
        (likedCat) => likedCat.cat.imageUrl == _currentCat!.imageUrl,
      )) {
        likedCatsProvider.addCat(_currentCat!);
        setState(() {});
      }
    }
    _nextCat();
    return true;
  }

  void _nextCat() {
    setState(() {
      if (_catsQueue.isNotEmpty) {
        _catsQueue.removeAt(0);
        _currentCat = _catsQueue.isNotEmpty ? _catsQueue.first : null;
      }
      if (_catsQueue.length < 2) {
        _loadCats();
      }
    });
  }

  void _likeCat() {
    if (_currentCat != null) {
      final likedCatsProvider = Provider.of<LikedCatsProvider>(
        context,
        listen: false,
      );
      if (!likedCatsProvider.likedCats.any(
        (likedCat) => likedCat.cat.imageUrl == _currentCat!.imageUrl,
      )) {
        likedCatsProvider.addCat(_currentCat!);
        setState(() {});
      }
      _nextCat();
    }
  }

  void _dislikeCat() {
    _nextCat();
  }

  void _decrementCounter() {
    setState(() {});
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
                  Widget imageWidget;
                  if (cat.imageData != null) {
                    imageWidget = Image.memory(
                      cat.imageData!,
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.5,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error,
                              color: Color.fromARGB(255, 0, 0, 0),
                              size: 50,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Image decoding failed',
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  } else if (_isOffline) {
                    imageWidget = const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 50,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Image not available offline',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    );
                  } else {
                    imageWidget = CachedNetworkImage(
                      imageUrl: cat.imageUrl,
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.5,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) {
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 50,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Image unavailable',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        );
                      },
                    );
                  }

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
                                    (_) => CatInformation(
                                      cat: cat,
                                      image: imageWidget,
                                    ),
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
                            child: imageWidget,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          if (_currentCat == null && !_isLoading && !_noMoreCats)
            const Center(
              child: Text(
                'No more cats to show. Please connect to the internet to load more.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
