import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Yeni eklenen import

class DatePickerWidget extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final DateTime? initialDate;

  const DatePickerWidget({
    Key? key,
    required this.onDateSelected,
    this.initialDate,
  }) : super(key: key);

  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime? _selectedDate;
  late DateFormat _dateFormat;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    initializeDateFormatting('tr_TR', null).then((_) {
      // Türkçe tarih formatını başlat
      _dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final age = DateTime.now().difference(picked).inDays ~/ 365;
      if (age < 13) {
        Get.snackbar(
          'Hata',
          '13 yaşından küçükler kayıt olamaz',
          backgroundColor: Colors.red[100],
        );
        return;
      }
      setState(() {
        _selectedDate = picked;
      });
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedDate == null ? Colors.grey[300]! : Colors.green,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate != null
                      ? _dateFormat.format(_selectedDate!)
                      : 'Doğum Tarihi Seçiniz',
                  style: TextStyle(
                    color: _selectedDate == null ? Colors.grey : Colors.black,
                    fontSize: 16,
                  ),
                ),
                Icon(
                  Icons.calendar_month,
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ),
        if (_selectedDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Seçilen Tarih: ${_dateFormat.format(_selectedDate!)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
