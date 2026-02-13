import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/movie_model.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';
import '../main.dart';
import 'movie_detail_page.dart';
import '../services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  late Future<List<Movie>> _moviesFuture;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Все';
  String _activeTab = 'Афиша';
  int _bottomIndex = 0;

  @override
  void initState() {
    super.initState();
    _moviesFuture = _apiService.getPopularMovies();
  }

  void _onSearch() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _moviesFuture = _apiService.getPopularMovies();
      } else {
        _moviesFuture = _apiService.searchMovies(_searchController.text);
      }
    });
  }

  void _onBottomTap(int index) {
    setState(() {
      _bottomIndex = index;
      _activeTab = ['Афиша', 'Кинотеатры', 'Настройки'][index];
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.movie_filter, color: colorScheme.onPrimary, size: 24),
            ),
            const SizedBox(width: 8),
            const Text('KinoBox'),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined, color: colorScheme.onSurface, size: 24),
                onPressed: () => _showCart(context),
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${cart.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        onTap: _onBottomTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Афиша'),
          BottomNavigationBarItem(icon: Icon(Icons.location_city), label: 'Кинотеатры'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Настройки'),
        ],
      ),
      body: _buildBody(isWide),
    );
  }

  Widget _buildBody(bool isWide) {
    if (_activeTab == 'Афиша') return _buildHomeContent(isWide);
    if (_activeTab == 'Кинотеатры') return _buildCinemasContent(isWide);
    return _buildSettingsContent(isWide);
  }

  Widget _buildHomeContent(bool isWide) {
    final horizontal = isWide ? 24.0 : 16.0;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Сейчас в кино',
              style: TextStyle(
                fontSize: isWide ? 32 : 24,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Выберите фильм и время для просмотра',
              style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            _buildFiltersAndSearch(isWide),
            const SizedBox(height: 16),
            _buildMoviesGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersAndSearch(bool isWide) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('Все'),
                const SizedBox(width: 8),
                _filterChip('Сегодня'),
                const SizedBox(width: 8),
                _filterChip('Завтра'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: (_) => _onSearch(),
            decoration: InputDecoration(
              hintText: 'Поиск по названию...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        _filterChip('Все'),
        const SizedBox(width: 12),
        _filterChip('Сегодня'),
        const SizedBox(width: 12),
        _filterChip('Завтра'),
        const Spacer(),
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => _onSearch(),
            decoration: const InputDecoration(
              hintText: 'Поиск по названию...',
              prefixIcon: Icon(Icons.search, color: Colors.black38),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoviesGrid() {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1000
        ? 4
        : (width > 700 ? 3 : 2);
    final aspectRatio = width < 400 ? 0.6 : 0.55;

    return FutureBuilder<List<Movie>>(
      future: _moviesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Фильмы не найдены'));
        }

        final movies = snapshot.data!;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 24,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) => GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MovieDetailPage(movieId: movies[index].id),
              ),
            ),
            child: MovieCard(movie: movies[index]),
          ),
        );
      },
    );
  }

  Widget _buildCinemasContent(bool isWide) {
    final horizontal = isWide ? 24.0 : 16.0;
    final cinemas = [
      {'name': 'Sary Arka Cinema', 'address': 'пр. Строителей, 6'},
      {'name': 'Kinoplexx Karaganda', 'address': 'пр. Бухар-Жырау, 59/2 (ЦУМ)'},
      {'name': 'Cinemax (City Mall)', 'address': 'пр. Бухар-Жырау, 59/2'},
      {'name': 'Eurasia Cinema', 'address': 'ул. Сакена Сейфуллина, 1'},
      {'name': 'Ленина', 'address': 'пр. Бухар-Жырау, 32'},
    ];

    return Padding(
      padding: EdgeInsets.all(horizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Кинотеатры Караганды',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: cinemas.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 28),
                    title: Text(
                      cinemas[index]['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(cinemas[index]['address']!),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent(bool isWide) {
    final horizontal = isWide ? 24.0 : 16.0;

    return Padding(
      padding: EdgeInsets.all(horizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Настройки темы',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 24),
          const Text('Режим приложения', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _themeModeChip('Светлая', ThemeMode.light),
              const SizedBox(width: 12),
              _themeModeChip('Темная', ThemeMode.dark),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Цветовая схема', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _colorSeed(const Color(0xFF1E56E1)),
              _colorSeed(Colors.deepPurple),
              _colorSeed(Colors.teal),
              _colorSeed(Colors.orange),
              _colorSeed(Colors.pink),
              _colorSeed(Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _themeModeChip(String label, ThemeMode mode) {
    bool active = currentThemeMode == mode;
    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => KinoshkaApp.of(context)?.updateTheme(mode),
    );
  }

  Widget _colorSeed(Color color) {
    bool active = customSeedColor == color;
    return GestureDetector(
      onTap: () => KinoshkaApp.of(context)?.updateTheme(currentThemeMode, color),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: active ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3) : null,
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    bool active = _selectedFilter == label;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? colorScheme.primaryContainer : colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Корзина',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (cart.isEmpty)
                  const Expanded(child: Center(child: Text('Корзина пуста')))
                else
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: cart.length,
                      itemBuilder: (context, index) {
                        final item = cart[index];
                        return Card(
                          child: ListTile(
                            title: Text(item.movieTitle),
                            subtitle: Text('Билетов: ${item.count} • Сеанс: ${item.time}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${item.totalPrice} ₸',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () {
                                    setState(() => cart.removeAt(index));
                                    setModalState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (cart.isNotEmpty) ...[
                  const Divider(),
                  ListTile(
                    title: const Text('Итого', style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                      '${cart.fold(0, (sum, item) => sum + item.totalPrice)} ₸',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => cart.clear());
                        NotificationService.cancelCartReminder();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: const Text('Оплатить'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
