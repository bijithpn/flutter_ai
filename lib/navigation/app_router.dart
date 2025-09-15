import 'package:flutter/material.dart';
import '../screens/recipes_screen.dart';
import '../screens/trainer_screen.dart';
import '../screens/notes_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/recipe_detail_screen.dart';
import '../screens/onboarding_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String recipes = '/recipes';
  static const String trainer = '/trainer';
  static const String notes = '/notes';
  static const String settings = '/settings';
  static const String recipeDetail = '/recipe-detail';
  static const String onboarding = '/onboarding';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _createRoute(const MainNavigationScreen());
      case '/recipes':
        return _createRoute(const RecipesScreen());
      case '/trainer':
        return _createRoute(const TrainerScreen());
      case '/notes':
        return _createRoute(const NotesScreen());
      case '/settings':
        return _createRoute(const SettingsScreen());
      case '/recipe-detail':
        final args = settings.arguments as Map<String, dynamic>?;
        return _createRoute(
          RecipeDetailScreen(
            recipe: args?['recipe'],
            recipeId: args?['recipeId'],
          ),
        );
      case '/onboarding':
        return _createRoute(const OnboardingScreen());
      default:
        return _createRoute(
          const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }

  static PageRouteBuilder<dynamic> _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRouteBuilder<dynamic> createHeroRoute(
    Widget page,
    String heroTag,
  ) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;

  final List<Widget> _screens = [
    const RecipesScreen(),
    const TrainerScreen(),
    const NotesScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
      _animationController.forward().then((_) {
        _animationController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabSelected,
            animationDuration: const Duration(milliseconds: 300),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.restaurant_menu_outlined),
                selectedIcon: Icon(Icons.restaurant_menu),
                label: 'Recipes',
              ),
              NavigationDestination(
                icon: Icon(Icons.fitness_center_outlined),
                selectedIcon: Icon(Icons.fitness_center),
                label: 'Trainer',
              ),
              NavigationDestination(
                icon: Icon(Icons.note_outlined),
                selectedIcon: Icon(Icons.note),
                label: 'Notes',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          );
        },
      ),
    );
  }
}
