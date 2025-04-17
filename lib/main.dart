import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/di/setup.dart';
import 'presentation/providers/liked_cats_provider.dart';
import 'presentation/screens/cat_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  // Initialize dependency injection
  setupDependencies();

  runApp(const CatTinderApp());
}

class CatTinderApp extends StatelessWidget {
  const CatTinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<LikedCatsProvider>(),
      child: MaterialApp(
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
      ),
    );
  }
}
