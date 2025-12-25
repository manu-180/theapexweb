// Archivo: lib/features/services/domain/models/case_study_model.dart
import 'package:flutter/material.dart';

class CaseStudy {
  final String name;
  final String logoAsset;
  final String url;
  final Color brandColor; // El color principal de la marca para el degradado
  final bool isDarkLogo; // Por si el logo es negro y el fondo es oscuro

  const CaseStudy({
    required this.name,
    required this.logoAsset,
    required this.url,
    required this.brandColor,
    this.isDarkLogo = false,
  });
}