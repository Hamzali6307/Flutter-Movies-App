import 'package:flutter/material.dart';
import 'home_view.dart';
import 'settings_view.dart';
import 'search_view.dart';
import 'favourites_view.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  String? _searchGenreId;
  String? _searchTitle;
  String? _searchType;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 1) {
        _searchGenreId = null;
        _searchTitle = null;
        _searchType = null;
      }
    });
  }

  void _navigateToSearch(String? genreId, String? title, String? type) {
    setState(() {
      _searchGenreId = genreId;
      _searchTitle = title;
      _searchType = type;
      _selectedIndex = 1;
    });
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 1: return 'Search';
      case 2: return 'Favourites';
      case 3: return 'Settings';
      default: return 'Hub Movie\'s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> views = [
      HomeView(onSeeAll: _navigateToSearch),
      SearchView(
        key: ValueKey('search_${_searchGenreId}_${_searchTitle}_$_searchType'),
        initialGenreId: _searchGenreId,
        initialTitle: _searchTitle,
        initialSearchType: _searchType,
      ),
      const FavouritesView(),
      const SettingsView(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // Redundant search icon removed from here
        elevation: 0,
        backgroundColor: const Color(0xFF1E1E1E),
        surfaceTintColor: Colors.transparent,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: views,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favourites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onItemTapped,
      ),
    );
  }
}
