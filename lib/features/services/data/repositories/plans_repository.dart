// Archivo: lib/features/services/data/repositories/plans_repository.dart
import 'package:flutter/material.dart';
import 'package:prueba_de_riverpod/features/services/domain/models/case_study_model.dart';
import 'package:prueba_de_riverpod/features/services/domain/models/plan_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plans_repository.g.dart';

class PlansRepository {
  final List<ServicePlan> webPlans = const [
    ServicePlan(
      id: 'web_basic',
      name: 'Presencia Digital Profesional',
      price: 300000,
      originalPrice: 400000,
      type: PlanType.web,
      description: 'Tu carta de presentación al mundo. Ideal para profesionales que necesitan validar su marca.',
      // --- CASOS DE ÉXITO (Plan 300k) ---
      caseStudies: [
        CaseStudy(
          name: 'Simon Mindset',
          logoAsset: 'assets/icons/simon_logo.png', 
          url: 'https://simonmindset.com',
          brandColor: Color(0xFF8B0000), // Rojo oscuro elegante
        ),
        CaseStudy(
          name: 'Pérez Yeregui',
          logoAsset: 'assets/icons/perez_logo.png',
          url: 'https://perez-yeregui2.vercel.app',
          // CAMBIO: Gris pizarra (extraído de la imagen de la web)
          brandColor: Color(0xFF5B5663), 
        ),
      ],
      features: [
        'Diseño a Medida (Sin plantillas)',
        'Información optimizada para vender',
        'Carga ultrarrápida (Flutter Web)',
        'Hosting incluido', 
      ],
    ),
    ServicePlan(
      id: 'web_interactive',
      name: 'Web Interactiva + Backend',
      price: 600000,
      originalPrice: 860000,
      type: PlanType.web,
      description: 'Pasa al siguiente nivel. Automatiza el contacto con tus clientes y muestra contenido dinámico.',
      // --- CASOS DE ÉXITO (Plan 600k) ---
      caseStudies: [
        CaseStudy(
          name: 'Assistify',
          logoAsset: 'assets/icons/logo_assistify.png',
          url: 'https://assistify.lat',
          brandColor: Color(0xFF00A8E8), // Cyan de la marca
        ),
      ],
      features: [
        'Todo lo del plan Presencia',
        'Backend conectado (Supabase)',
        'Formularios con auto-respuesta (Email)',
        'Galería Multimedia / Videos',
      ],
    ),
    ServicePlan(
      id: 'web_premium',
      name: 'Sistema de Gestión Integral',
      price: 900000,
      originalPrice: 1500000,
      type: PlanType.web,
      description: 'Profesionaliza tu gestión. Una web para tus clientes y una App privada para controlar el negocio.',
      // --- CASOS DE ÉXITO (Plan 900k) ---
      caseStudies: [
        CaseStudy(
          name: 'Pulpiprint',
          logoAsset: 'assets/icons/pulpiprint_logo.png',
          url: 'https://pulpiprint.com',
          brandColor: Color(0xFF7E57C2), // Lila fuerte
        ),
        CaseStudy(
          name: 'MNL Tecno',
          logoAsset: 'assets/icons/mnl_logo.png',
          url: 'https://mnltecno.com',
          brandColor: Color(0xFF0277BD), // Azul técnico
        ),
      ],
      features: [
        'Web de Ventas Completa',
        'App de Escritorio (Admin Dashboard)',
        'Panel de Métricas y Reportes', 
        'Gestión de Stock y Usuarios (Roles)', 
        'Soporte prioritario',
      ],
    ),
  ];

  final List<ServicePlan> videoPlans = const [
    ServicePlan(
      id: 'video_1',
      name: 'Prueba Piloto',
      price: 10000,
      type: PlanType.video,
      description: 'Ideal para probar el impacto de la IA en tu marca.',
      features: ['1 Video Vertical', 'Guion estratégico', 'Voz Neural Realista'],
    ),
    ServicePlan(
      id: 'video_4',
      name: 'Pack Semanal',
      price: 35000,
      originalPrice: 40000, 
      type: PlanType.video,
      description: 'Cubrimos tu presencia en redes durante un mes.',
      features: ['4 Videos Verticales', 'Edición dinámica', 'Música en tendencia'],
    ),
    ServicePlan(
      id: 'video_10',
      name: 'Estrategia Viral',
      price: 80000,
      originalPrice: 100000, 
      type: PlanType.video,
      description: 'Contenido masivo para inundar las redes.',
      features: ['10 Videos de alto impacto', 'Adaptación a tendencias', 'Entrega prioritaria'],
    ),
  ];
}

@riverpod
PlansRepository plansRepository(PlansRepositoryRef ref) {
  return PlansRepository();
}