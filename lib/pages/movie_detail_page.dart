import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie_model.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';
import '../main.dart'; // For global cart

class MovieDetailPage extends StatefulWidget {
  final int movieId;
  const MovieDetailPage({super.key, required this.movieId});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final ApiService _apiService = ApiService();
  int _ticketCount = 1;
  final int _pricePerTicket = 2500;
  String? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('О фильме', style: TextStyle(fontWeight: FontWeight.w800)), centerTitle: true),
      body: FutureBuilder<MovieDetail>(
        future: _apiService.getMovieDetails(widget.movieId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          final detail = snapshot.data!;
          final times = generateRandomTimes(widget.movieId);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CachedNetworkImage(imageUrl: detail.backdropPath ?? detail.posterPath ?? '', height: 400, width: double.infinity, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(detail),
                      const SizedBox(height: 32),
                      const Text('Выберите время сеанса', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: times.map((time) => _timeChip(time)).toList(),
                      ),
                      const SizedBox(height: 32),
                      _buildPurchaseSection(detail),
                      const SizedBox(height: 40),
                      const Text('О чем фильм', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 16),
                      Text(detail.overview, style: const TextStyle(fontSize: 18, height: 1.6)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _timeChip(String time) {
    bool active = _selectedTime == time;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => setState(() => _selectedTime = time),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: active ? colorScheme.primary : colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: active ? null : Border.all(color: colorScheme.outlineVariant),
        ),
        child: Text(
          time,
          style: TextStyle(
            color: active ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(MovieDetail detail) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(detail.title, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('${detail.genres.join(', ')} • ${detail.runtime} мин', style: const TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(detail.voteAverage.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseSection(MovieDetail detail) {
    final colorScheme = Theme.of(context).colorScheme;
    bool canBuy = _selectedTime != null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3), 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: colorScheme.outlineVariant)
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Цена билета', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  Text('$_pricePerTicket ₸', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                ],
              ),
              Row(
                children: [
                  _quantityButton(Icons.remove, () {
                    if (_ticketCount > 1) setState(() => _ticketCount--);
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('$_ticketCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  ),
                  _quantityButton(Icons.add, () => setState(() => _ticketCount++)),
                ],
              ),
            ],
          ),
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Итого', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  Text('${_pricePerTicket * _ticketCount} ₸', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: colorScheme.primary)),
                ],
              ),
              ElevatedButton(
                onPressed: canBuy ? () {
                  setState(() {
                    cart.add(CartItem(
                      id: DateTime.now().toString(),
                      movieTitle: detail.title,
                      count: _ticketCount,
                      totalPrice: _pricePerTicket * _ticketCount,
                      time: _selectedTime!,
                    ));
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Добавлено в корзину: ${_selectedTime}'), 
                    duration: const Duration(seconds: 1)
                  ));
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: Colors.grey.withOpacity(0.2),
                ),
                child: Text(
                  canBuy ? 'В корзину' : 'Выберите время', 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
