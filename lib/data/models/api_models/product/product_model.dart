class ProductModel {
  final String name;
  final double price;
  final String description;

  ProductModel({
    required this.name,
    required this.price,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "price": price,
        "description": description,
      };
}
