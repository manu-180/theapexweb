// Archivo: lib/features/services/domain/models/plan_model.dart
import 'package:flutter/foundation.dart';

enum PlanType { web, video }

class ServicePlan {
  final String id;
  final String name;
  final int price;
  final String description;
  final List<String> features;
  final PlanType type;

  const ServicePlan({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.features,
    required this.type,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ServicePlan &&
        other.id == id &&
        other.name == name &&
        other.price == price &&
        other.description == description &&
        listEquals(other.features, features) &&
        other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        price.hashCode ^
        description.hashCode ^
        features.hashCode ^
        type.hashCode;
  }
}