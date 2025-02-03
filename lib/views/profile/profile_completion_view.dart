import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutoring/config/routes.dart';
import 'package:tutoring/controllers/auth_controller.dart';
import 'package:tutoring/views/widgets/city_picker.dart';
import 'package:tutoring/views/widgets/custom_button.dart';
import 'package:tutoring/views/widgets/custom_text_field.dart';
import 'package:tutoring/views/widgets/date_picker.dart';

class ProfileCompletionView extends StatefulWidget {
  const ProfileCompletionView({super.key});

  @override
  _ProfileCompletionViewState createState() => _ProfileCompletionViewState();
}

class _ProfileCompletionViewState extends State<ProfileCompletionView> {
  final _pageController = PageController();
  final _authController = Get.find<AuthController>();
  int _currentStep = 0;

  String _firstName = '';
  String _lastName = '';
  String? _selectedCity;
  DateTime? _birthDate;
  String _bio = '';

  final List<Widget> _steps = [];

  @override
  void initState() {
    super.initState();
    _steps.addAll([
      _buildNameStep('Adınız', (value) => _firstName = value),
      _buildNameStep('Soyadınız', (value) => _lastName = value),
      _buildCityStep(),
      _buildBirthDateStep(),
      _buildBioStep(),
    ]);
  }

  Widget _buildNameStep(String hint, Function(String) onSaved) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${hint.toUpperCase()} GİRİN',
            style: Get.textTheme.titleLarge?.copyWith(
              color: Colors.green,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 40),
          CustomTextField(
            hintText: hint,
            onChanged: (value) => onSaved(value),
            validator: (value) => value!.isEmpty ? 'Bu alan zorunlu' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCityStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ŞEHİR SEÇİN',
          style: Get.textTheme.titleLarge?.copyWith(
            color: Colors.green,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 30),
        CityPicker(
          onCitySelected: (city) => _selectedCity = city,
          initialCity: _selectedCity,
        ),
      ],
    );
  }

  Widget _buildBirthDateStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'DOĞUM TARİHİNİZ',
          style: Get.textTheme.titleLarge?.copyWith(
            color: Colors.green,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 30),
        DatePickerWidget(
          onDateSelected: (date) => _birthDate = date,
          initialDate: _birthDate,
        ),
      ],
    );
  }

  Widget _buildBioStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'BİYOGRAFİNİZ',
            style: Get.textTheme.titleLarge?.copyWith(
              color: Colors.green,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 30),
          CustomTextField(
            hintText: 'Kendinizden bahsedin...',
            maxLines: 5,
            onChanged: (value) => _bio = value,
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    // Adım bazlı validasyon
    switch (_currentStep) {
      case 0: // Ad
        if (_firstName.isEmpty) {
          Get.snackbar('Hata', 'Ad alanı boş bırakılamaz');
          return;
        }
        break;
      case 1: // Soyad
        if (_lastName.isEmpty) {
          Get.snackbar('Hata', 'Soyad alanı boş bırakılamaz');
          return;
        }
        break;
      case 2: // Şehir
        if (_selectedCity == null) {
          Get.snackbar('Hata', 'Lütfen bir şehir seçin');
          return;
        }
        break;
      case 3: // Doğum Tarihi
        if (_birthDate == null) {
          Get.snackbar('Hata', 'Lütfen doğum tarihinizi seçin');
          return;
        }
        // 13 yaş kontrolü
        final age = DateTime.now().difference(_birthDate!).inDays ~/ 365;
        if (age < 13) {
          Get.snackbar('Hata', '13 yaşından küçükler kayıt olamaz');
          return;
        }
        break;
      case 4: // Biyografi
        if (_bio.isEmpty) {
          Get.snackbar('Hata', 'Biyografi alanı boş bırakılamaz');
          return;
        }
        break;
    }

    // Son adımda profil tamamlama işlemi
    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      _completeProfile();
    }
  }

  Future<void> _completeProfile() async {
    final user = _authController.user?.copyWith(
      firstName: _firstName,
      lastName: _lastName,
      city: _selectedCity,
      birthDate: _birthDate,
      bio: _bio,
    );

    await _authController.updateProfile(user!);
    Get.offAllNamed(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Klavye açılınca sayfayı yukarı kaydır
      appBar: AppBar(
        title: Text('Profilini Tamamla (${_currentStep + 1}/${_steps.length})'),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context)
              .size
              .height, // Ekran yüksekliği kadar yer kapla
          child: PageView.builder(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _steps.length,
            itemBuilder: (_, index) => _steps[index],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom, // Klavye yüksekliğine göre padding
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: CustomButton(
            text: _currentStep == _steps.length - 1 ? 'TAMAMLA' : 'DEVAM ET',
            onPressed: _nextStep,
            backgroundColor: Colors.green.shade600,
            textColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
