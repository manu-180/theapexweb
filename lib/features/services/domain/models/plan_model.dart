// Archivo: lib/features/services/domain/models/plan_model.dart
import 'package:flutter/foundation.dart';
import 'package:apex/features/services/domain/models/case_study_model.dart';

enum PlanType { web, app }

class ServicePlan {
  final String id;
  final String name;
  final int price;
  final int? originalPrice;
  final String description;
  final String idealFor;
  final List<String> features;
  final PlanType type;
  final List<CaseStudy>? caseStudies;
  final bool isCustom;
  final String badge;
  final bool isFeatured;

  const ServicePlan({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.description,
    required this.idealFor,
    required this.features,
    required this.type,
    this.caseStudies,
    this.isCustom = false,
    this.badge = '',
    this.isFeatured = false,
  });

  // Calculamos el porcentaje de descuento
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
        other.originalPrice == originalPrice &&
        other.description == description &&
        other.idealFor == idealFor &&
        other.isCustom == isCustom &&
        other.badge == badge &&
        other.isFeatured == isFeatured &&
        listEquals(other.features, features) &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    price,
    originalPrice,
    description,
    idealFor,
    Object.hashAll(features),
    type,
    isCustom,
    badge,
    isFeatured,
  );
}
