import 'package:flutter/material.dart';
import 'package:test_app/l10n/app_localizations.dart';
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

  String _getAppBarTitle(AppLocalizations l10n) {
    switch (_selectedIndex) {
      case 1:
        return l10n.search;
      case 2:
        return l10n.favourites;
      case 3:
        return l10n.settings;
      default:
        return l10n.appTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _getAppBarTitle(l10n),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: views,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.home),
          BottomNavigationBarItem(icon: const Icon(Icons.search), label: l10n.search),
          BottomNavigationBarItem(icon: const Icon(Icons.favorite), label: l10n.favourites),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: l10n.settings),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
