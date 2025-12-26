// Archivo: lib/features/services/domain/models/case_study_model.dart
import 'package:flutter/material.dart';

class CaseStudy {
  final String name;
  final String? logoAsset; // Ahora es opcional (puede ser null si usamos letra)
  final String? logoLetter; // NUEVO: Para mostrar una letra en vez de imagen
  final String url;
  final Color brandColor;
  final Color? logoBgColor;
  final bool isDarkLogo;

  const CaseStudy({
    required this.name,
    this.logoAsset,
    this.logoLetter,
    required this.url,
    required this.brandColor,
    this.logoBgColor,
    this.isDarkLogo = false,
  });
}