import 'package:flutter/foundation.dart';
import 'package:prueba_de_riverpod/features/services/domain/models/case_study_model.dart'; // <--- IMPORTAR

enum PlanType { web, video }

class ServicePlan {
  final String id;
  final String name;
  final int price;
  final int? originalPrice;
  final String description;
  final List<String> features;
  final PlanType type;
  final List<CaseStudy>? caseStudies; // <--- NUEVO CAMPO

  const ServicePlan({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.description,
    required this.features,
    required this.type,
    this.caseStudies, // <--- Constructor
  });

  // Calculamos el porcentaje de descuento automáticamente
  int get discountPercentage {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).round();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ServicePlan &&
        other.id == id &&
        other.name == name &&
        other.price == price &&
        other.originalPrice == originalPrice && // <--- Comparación
        other.description == description &&
        listEquals(other.features, features) &&
        other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        price.hashCode ^
        originalPrice.hashCode ^ // <--- Hash
        description.hashCode ^
        features.hashCode ^
        type.hashCode;
  }
}