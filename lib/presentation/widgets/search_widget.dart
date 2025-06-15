import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchWidget extends StatefulWidget {
  final MapController mapController;

  const SearchWidget({super.key, required this.mapController});

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final _searchController = TextEditingController();
  bool _isLoading = false;

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      _showMessage('Введите адрес для поиска');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1',
        ),
        headers: {'User-Agent': 'FlutterUserPanel/1.0'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          widget.mapController.move(LatLng(lat, lon), 15.0);
          _showMessage('Местоположение найдено', isError: false);
        } else {
          _showMessage('По вашему запросу ничего не найдено. Уточните адрес');
        }
      } else if (response.statusCode == 429) {
        _showMessage('Превышен лимит запросов. Попробуйте позже');
      } else {
        _showMessage('Не удалось выполнить поиск. Попробуйте позже');
      }
    } catch (e) {
      if (mounted) {
        _showMessage(
          'Не удалось подключиться к серверу. Проверьте подключение к интернету',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Введите адрес для поиска',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                prefixIcon: const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF447BBA),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 14),
              onSubmitted: _searchLocation,
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child:
                _isLoading
                    ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF447BBA),
                        ),
                      ),
                    )
                    : IconButton(
                      icon: const Icon(Icons.search, color: Color(0xFF447BBA)),
                      onPressed: () => _searchLocation(_searchController.text),
                      splashRadius: 24,
                      tooltip: 'Поиск',
                    ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
