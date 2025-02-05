import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutoring/constants/cities.dart';
import 'package:tutoring/constants/subjects.dart';
import 'package:tutoring/controllers/ads_controller.dart';
import 'package:tutoring/data/models/filter_model.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final AdsController _adsController = Get.find<AdsController>();
  late FilterModel _localFilter;

  final List<String> _genders = ['Erkek', 'Kadın', 'Farketmez'];
  final List<double> _ratings = [5.0, 6.0, 7.0, 8.0, 9.0];

  // FilterScreen'de initState'ı güncelleyin
  @override
  void initState() {
    super.initState();
    _localFilter = _adsController.currentFilter.value.copyWith();
  }

// Uygula butonu işlevi
  void _applyFilters() {
    _adsController.updateFilter(_localFilter);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtreleme', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _applyFilters,
            child: const Text('Uygula',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionHeader('Konum Filtreleri'),
            _buildCityDropdown(),
            const SizedBox(height: 20),
            _buildSectionHeader('Ders Bilgileri'),
            _buildSubjectDropdown(),
            const SizedBox(height: 20),
            _buildPriceFilter(),
            const SizedBox(height: 20),
            _buildSectionHeader('Öğretmen Özellikleri'),
            _buildGenderFilter(),
            const SizedBox(height: 20),
            _buildRatingFilter(),
            const SizedBox(height: 30),
            _buildClearButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: DropdownButtonFormField<String>(
          value: _localFilter.city,
          decoration: const InputDecoration(
            labelText: 'Şehir',
            border: InputBorder.none,
          ),
          items: Cities.allCities
              .map((city) => DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _localFilter.city = value),
        ),
      ),
    );
  }

  Widget _buildSubjectDropdown() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: DropdownButtonFormField<String>(
          value: _localFilter.subject,
          decoration: const InputDecoration(
            labelText: 'Ders',
            border: InputBorder.none,
          ),
          items: Subjects.allSubjects
              .map((subject) => DropdownMenuItem(
                    value: subject,
                    child: Text(subject),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _localFilter.subject = value),
        ),
      ),
    );
  }

  Widget _buildPriceFilter() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saatlik Ücret Aralığı',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Min TL',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(
                      () => _localFilter.minPrice = int.tryParse(value),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Max TL',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(
                      () => _localFilter.maxPrice = int.tryParse(value),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderFilter() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: DropdownButtonFormField<String>(
          value: _localFilter.gender,
          decoration: const InputDecoration(
            labelText: 'Tercih Edilen Cinsiyet',
            border: InputBorder.none,
          ),
          items: _genders
              .map((gender) => DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _localFilter.gender = value),
        ),
      ),
    );
  }

  Widget _buildRatingFilter() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: DropdownButtonFormField<double>(
          value: _localFilter.minRating,
          decoration: const InputDecoration(
            labelText: 'Minimum Puan',
            border: InputBorder.none,
          ),
          items: _ratings
              .map((rating) => DropdownMenuItem(
                    value: rating,
                    child: Text('$rating ve üzeri'),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _localFilter.minRating = value),
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.filter_alt_off),
      label: const Text('Filtreleri Temizle'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade100,
        foregroundColor: Colors.green.shade800,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        setState(() => _localFilter = FilterModel());
        _adsController.updateFilter(FilterModel());
      },
    );
  }
}
