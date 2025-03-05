import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutoring/controllers/ads_controller.dart';
import 'package:tutoring/controllers/auth_controller.dart';
import 'package:tutoring/views/widgets/city_picker.dart';
import 'package:tutoring/views/widgets/custom_text_field.dart';
import 'package:tutoring/views/widgets/subject_picker.dart';

class PostAdView extends StatelessWidget {
  final AdsController adsController = Get.put(AdsController());
  final AuthController authController = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _budgetController = TextEditingController();

  String? _selectedSubject;
  String? _selectedCity;

  PostAdView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isTeacher = authController.isTeacher;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni İlan Oluştur',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ders Adı
              CustomTextField(
                controller: _titleController,
                hintText: 'Ders Adı',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen ders adını giriniz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              SubjectPicker(
                onSubectSelected: (subject) {
                  _selectedSubject = subject;
                  _subjectController.text = subject;
                },
                initialSubject: _selectedSubject,
              ),

              const SizedBox(height: 16.0),

              // Açıklama
              CustomTextField(
                controller: _descriptionController,
                hintText: 'Açıklama',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen açıklama giriniz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Şehir Seçme (CityPicker ile)
              CityPicker(
                onCitySelected: (city) {
                  _selectedCity = city;
                  _cityController.text = city;
                },
                initialCity: _selectedCity,
              ),
              const SizedBox(height: 16.0),

              // İlçe
              CustomTextField(
                controller: _districtController,
                hintText: 'İlçe',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen ilçe giriniz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Öğretmen veya Öğrenciye Özel Alanlar
              if (isTeacher)
                CustomTextField(
                  controller: _hourlyRateController,
                  hintText: 'Saatlik Ücret (₺)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen saatlik ücret giriniz';
                    }
                    return null;
                  },
                )
              else
                CustomTextField(
                  controller: _budgetController,
                  hintText: 'Bütçe (₺)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bütçe giriniz';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 24.0),

              // İlanı Kaydet Butonu
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final adData = {
                        'title': _titleController.text,
                        'subject': _selectedSubject,
                        'description': _descriptionController.text,
                        'city': _selectedCity,
                        'district': _districtController.text,
                        'createdAt': DateTime.now(),
                        if (isTeacher)
                          'hourlyRate': int.parse(_hourlyRateController.text),
                        if (!isTeacher)
                          'budget': int.parse(_budgetController.text),
                        if (isTeacher) 'teacherId': authController.user?.uid,
                        if (!isTeacher) 'studentId': authController.user?.uid,
                      };

                      try {
                        await adsController.addAd(adData);
                        Get.snackbar('Başarılı', 'İlan başarıyla eklendi!',
                            backgroundColor: Colors.green[100]);
                        Get.back(); // Ana sayfaya dön
                      } catch (e) {
                        Get.snackbar('Hata', 'İlan eklenirken bir hata oluştu',
                            backgroundColor: Colors.red[100]);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: const Text('İlanı Kaydet',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
