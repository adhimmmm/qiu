class LaundryService {
  final String id;
  final String name;
  final String subtitle;
  final String price;
  final String? discount;

  /// Penanda apakah data dari API (true) atau Supabase (false)
  final bool fromApi;

  LaundryService({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    this.discount,
    this.fromApi = false, // default false (dari Supabase)
  });

  factory LaundryService.fromJson(
    Map<String, dynamic> json, {
    bool fromApi = false,
  }) {
    return LaundryService(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      subtitle: json['subtitle'] ?? '',
      price: json['price']?.toString() ?? '',
      discount: json['discount']?.toString(),
      fromApi: fromApi,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'price': price,
      'discount': discount,
      'fromApi': fromApi,
    };
  }

  LaundryService copyWith({
    String? id,
    String? name,
    String? subtitle,
    String? price,
    String? discount,
    bool? fromApi,
  }) {
    return LaundryService(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      fromApi: fromApi ?? this.fromApi,
    );
  }
}
