import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/movie_model.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';
import '../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  late Future<List<Movie>> _moviesFuture;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Все';
  String _activeTab = 'Афиша';

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.movie_filter, color: colorScheme.onPrimary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'KinoBox',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  _navItem('Афиша'),
                  _navItem('Кинотеатры'),
                  _navItem('Настройки'),
                  const Spacer(),
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.shopping_cart_outlined, color: colorScheme.onSurface, size: 28),
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
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_activeTab == 'Афиша') return _buildHomeContent();
    if (_activeTab == 'Кинотеатры') return _buildCinemasContent();
    return _buildSettingsContent();
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Сейчас в кино',
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              const Text(
                'Выберите фильм и время для просмотра',
                style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  _filterChip('Все'),
                  const SizedBox(width: 12),
                  _filterChip('Сегодня'),
                  const SizedBox(width: 12),
                  _filterChip('Завтра'),
                  const Spacer(),
                  Container(
                    width: 300,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(30)),
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
              ),
              const SizedBox(height: 48),
              FutureBuilder<List<Movie>>(
                future: _moviesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.all(100), child: CircularProgressIndicator()));
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
                      crossAxisCount: MediaQuery.of(context).size.width > 1000 ? 4 : (MediaQuery.of(context).size.width > 700 ? 3 : 2),
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 32,
                      mainAxisSpacing: 48,
                    ),
                    itemCount: movies.length,
                    itemBuilder: (context, index) => MovieCard(movie: movies[index]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCinemasContent() {
    final cinemas = [
      {'name': 'Sary Arka Cinema', 'address': 'пр. Строителей, 6'},
      {'name': 'Kinoplexx Karaganda', 'address': 'пр. Бухар-Жырау, 59/2 (ЦУМ)'},
      {'name': 'Cinemax (City Mall)', 'address': 'пр. Бухар-Жырау, 59/2'},
      {'name': 'Eurasia Cinema', 'address': 'ул. Сакена Сейфуллина, 1'},
      {'name': 'Ленина', 'address': 'пр. Бухар-Жырау, 32'},
    ];

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Кинотеатры Караганды', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: cinemas.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 32),
                      title: Text(cinemas[index]['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text(cinemas[index]['address']!),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsContent() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Настройки тем', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
            const SizedBox(height: 32),
            const Text('Режим приложения', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                _themeModeChip('Светлая', ThemeMode.light),
                const SizedBox(width: 12),
                _themeModeChip('Темная', ThemeMode.dark),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Цветовая схема', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
      ),
    );
  }

  Widget _themeModeChip(String label, ThemeMode mode) {
    bool active = currentThemeMode == mode;
    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => KinoshkaApp.of(context).updateTheme(mode),
    );
  }

  Widget _colorSeed(Color color) {
    bool active = customSeedColor == color;
    return GestureDetector(
      onTap: () => KinoshkaApp.of(context).updateTheme(currentThemeMode, color),
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

  Widget _navItem(String label) {
    bool active = _activeTab == label;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = label),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: active ? colorScheme.primary : colorScheme.onSurface)),
            if (active) Container(margin: const EdgeInsets.only(top: 4), height: 3, width: 32, decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(2))),
          ],
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
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(color: active ? colorScheme.primaryContainer : colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(25)),
        child: Text(label, style: TextStyle(color: active ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant, fontWeight: FontWeight.w800, fontSize: 15)),
      ),
    );
  }

  void _showCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Корзина', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (cart.isEmpty) const Text('Корзина пуста'),
              ...cart.map((item) => ListTile(
                title: Text(item.movieTitle),
                subtitle: Text('Билетов: ${item.count} • Сеанс: ${item.time}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${item.totalPrice} ₸', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        setState(() => cart.removeWhere((i) => i.id == item.id));
                        setModalState(() {});
                      },
                    ),
                  ],
                ),
              )),
              if (cart.isNotEmpty) ...[
                const Divider(),
                ListTile(
                  title: const Text('Итого', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text('${cart.fold(0, (sum, item) => sum + item.totalPrice)} ₸', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.primary)),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => cart.clear());
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
                    child: const Text('Оплатить'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
