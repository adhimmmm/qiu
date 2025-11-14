class LaundryService {
  final String id;
  final String name;
  final String subtitle;
  final String price;
  final String? discount;

  LaundryService({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    this.discount,
  });

  factory LaundryService.fromJson(Map<String, dynamic> json) {
    return LaundryService(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      subtitle: json['subtitle'] ?? '',
      price: json['price'] ?? '',
      discount: json['discount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'price': price,
      'discount': discount,
    };
  }
}