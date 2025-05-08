import 'package:cat_tinder/domain/models/cat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/liked_cats_provider.dart';
import 'cat_information.dart';
import '../widgets/date_of_like.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/di/setup.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LikedCatsScreen extends StatefulWidget {
  final VoidCallback decrementCounter;

  const LikedCatsScreen({super.key, required this.decrementCounter});

  @override
  State<LikedCatsScreen> createState() => _LikedCatsScreenState();
}

class _LikedCatsScreenState extends State<LikedCatsScreen> {
  String? _selectedBreed;
  bool _isOffline = false;
  final Map<String, Cat> _cachedCats = {};

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadCatsFromDatabase();
  }

  Future<void> _checkConnectivity() async {
    final connectivity = getIt<Connectivity>();
    final result = await connectivity.checkConnectivity();
    setState(() {
      _isOffline = result == ConnectivityResult.none;
    });
  }

  Future<void> _loadCatsFromDatabase() async {
    final likedCatsProvider = Provider.of<LikedCatsProvider>(
      context,
      listen: false,
    );
    for (var likedCat in likedCatsProvider.likedCats) {
      if (!_cachedCats.containsKey(likedCat.cat.imageUrl)) {
        final cat = await likedCatsProvider.getCatByImageUrl(
          likedCat.cat.imageUrl,
        );
        if (cat != null) {
          setState(() {
            _cachedCats[likedCat.cat.imageUrl] = cat;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final likedCatsProvider = context.watch<LikedCatsProvider>();
    final allCats = likedCatsProvider.likedCats;

    final breeds = allCats.map((e) => e.cat.breedInfo.name).toSet().toList();

    final filteredCats =
        _selectedBreed == null
            ? allCats
            : allCats
                .where((c) => c.cat.breedInfo.name == _selectedBreed)
                .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 73, 225, 70),
        centerTitle: true,
        title: const Center(
          child: Text(
            "Liked cats",
            style: TextStyle(
              color: Color.fromARGB(255, 19, 48, 22),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        actions: [const SizedBox(width: 48)],
      ),
      body: Column(
        children: [
          if (breeds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Builder(
                builder: (_) {
                  if (_selectedBreed != null &&
                      !breeds.contains(_selectedBreed)) {
                    _selectedBreed = null;
                  }

                  return DropdownButton<String>(
                    hint: const Text('Filter by breed'),
                    isExpanded: true,
                    value: _selectedBreed,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All breeds'),
                      ),
                      ...breeds.map(
                        (breed) =>
                            DropdownMenuItem(value: breed, child: Text(breed)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedBreed = value;
                      });
                    },
                  );
                },
              ),
            ),
          if (filteredCats.isEmpty)
            const Expanded(child: Center(child: Text('No liked cats yet')))
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredCats.length,
                itemBuilder: (context, index) {
                  final likedCat = filteredCats[index];
                  final cachedCat = _cachedCats[likedCat.cat.imageUrl];
                  final image =
                      cachedCat?.imageData != null
                          ? Image.memory(
                            cachedCat!.imageData!,
                            fit: BoxFit.cover,
                          )
                          : (_isOffline
                              ? const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              )
                              : CachedNetworkImage(
                                imageUrl: likedCat.cat.imageUrl,
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                errorWidget:
                                    (context, url, error) =>
                                        const Icon(Icons.error),
                              ));

                  return ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: SizedBox(width: 60, height: 60, child: image),
                    title: Text(likedCat.cat.breedInfo.name),
                    subtitle: Row(
                      children: [
                        Text(likedCat.cat.breedInfo.origin),
                        const SizedBox(width: 5),
                        DateOfLike(date: likedCat.likedAt),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        final index = likedCatsProvider.likedCats.indexOf(
                          likedCat,
                        );
                        if (index != -1) {
                          setState(() {
                            likedCatsProvider.removeCatAtIndex(index);
                            widget.decrementCounter();

                            final remainingBreedCats =
                                likedCatsProvider.likedCats
                                    .where(
                                      (c) =>
                                          c.cat.breedInfo.name ==
                                          _selectedBreed,
                                    )
                                    .toList();

                            if (_selectedBreed != null &&
                                remainingBreedCats.isEmpty) {
                              _selectedBreed = null;
                            }
                          });
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CatInformation(
                                cat: cachedCat ?? likedCat.cat,
                                image: image,
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
