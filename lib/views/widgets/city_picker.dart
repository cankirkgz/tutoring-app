// widgets/city_picker.dart
import 'package:flutter/material.dart';
import 'package:tutoring/constants/cities.dart';

class CityPicker extends StatefulWidget {
  final Function(String) onCitySelected;
  final String? initialCity;

  const CityPicker({
    super.key,
    required this.onCitySelected,
    this.initialCity,
  });

  @override
  _CityPickerState createState() => _CityPickerState();
}

class _CityPickerState extends State<CityPicker> {
  final List<String> cities = Cities.allCities;

  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.initialCity;
  }

  void _showCityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Şehir Seçin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: cities.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(cities[index]),
                      onTap: () {
                        setState(() {
                          _selectedCity = cities[index];
                        });
                        widget.onCitySelected(cities[index]);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showCityPicker(context),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCity ?? 'Şehir Seçiniz',
                  style: TextStyle(
                    color: _selectedCity == null ? Colors.grey : Colors.black,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
