import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/theme_toggle.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  runApp(const FlutterAIMVPApp());
}

class FlutterAIMVPApp extends StatelessWidget {
  const FlutterAIMVPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider()..initializeTheme(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Flutter AI MVP',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const MainScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const RecipesScreen(),
    const TrainerScreen(),
    const NotesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
      ),
    );
  }
}

// Placeholder screens - these will be implemented in later tasks
class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recipe Generator'),
      ),
      body: const Center(
        child: Text(
          'Recipe Generator\nComing Soon',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class TrainerScreen extends StatelessWidget {
  const TrainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Personal Trainer'),
      ),
      body: const Center(
        child: Text(
          'Pose Detection Trainer\nComing Soon',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Note Summarizer'),
      ),
      body: const Center(
        child: Text(
          'Note Summarizer\nComing Soon',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ThemeSelector(),
            SizedBox(height: 32),
            Center(
              child: Text(
                'More settings\nComing Soon',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}