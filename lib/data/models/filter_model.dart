class FilterModel {
  String? city;
  String? district;
  String? subject;
  int? minPrice;
  int? maxPrice;
  String? gender;
  int? minRating; // Artık int olarak kullanıyoruz

  FilterModel({
    this.city,
    this.district,
    this.subject,
    this.minPrice,
    this.maxPrice,
    this.gender,
    this.minRating,
  });

  FilterModel copyWith({
    String? city,
    String? district,
    String? subject,
    int? minPrice,
    int? maxPrice,
    String? gender,
    int? minRating,
  }) {
    return FilterModel(
      city: city ?? this.city,
      district: district ?? this.district,
      subject: subject ?? this.subject,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      gender: gender ?? this.gender,
      minRating: minRating ?? this.minRating,
    );
  }
}
