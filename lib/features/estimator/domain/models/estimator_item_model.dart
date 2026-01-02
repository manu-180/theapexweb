// Archivo: lib/features/estimator/domain/models/estimator_item_model.dart

enum ServiceType { web, app }

class EstimatorItem {
  final String id;
  final String label;
  final String description;
  final double price;          // El precio real (más bajo)
  final double? originalPrice; // El precio "de lista" (tachado)
  final ServiceType type;
  final bool isCore; 

  const EstimatorItem({
    required this.id,
    required this.label,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.type,
    this.isCore = false,
  });
}