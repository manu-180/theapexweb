// Archivo: lib/features/services/data/repositories/plans_repository.dart
import 'package:prueba_de_riverpod/features/services/domain/models/plan_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plans_repository.g.dart';

/// Un repositorio que contiene los datos estáticos de los planes de servicio.
class PlansRepository {
  /// Lista de planes de desarrollo web
  final List<ServicePlan> webPlans = const [
    ServicePlan(
      id: 'web_basic',
      name: 'Sitio de Presentación',
      price: 300000,
      type: PlanType.web,
      description: 'Una landing page profesional para establecer tu presencia en línea.',
      features: [
        'Diseño 100% responsive (adaptable)',
        'Formulario de Contacto',
        'Botón de WhatsApp',
        'Hosting Básico (1 año)',
      ],
    ),
    ServicePlan(
      id: 'web_ecommerce',
      name: 'E-Commerce Integrado',
      price: 600000,
      type: PlanType.web,
      description: 'Una tienda virtual completa con sistema de ventas y gestión.',
      features: [
        'Todo en el plan Básico',
        'Catálogo de productos',
        'Carrito de compras',
        'Integración con Mercado Pago',
        'Panel de gestión de pedidos',
      ],
    ),
    ServicePlan(
      id: 'web_premium',
      name: 'Sistema a Medida + App de Gestión',
      price: 900000,
      type: PlanType.web,
      description: 'Solución web completa más una app de escritorio para gestión interna.',
      features: [
        'Todo en el plan E-Commerce',
        'App de escritorio (Windows/Mac) para gestionar la web',
        'Funcionalidades a medida',
        'Base de datos dedicada',
      ],
    ),
  ];

  /// Lista de planes de creación de videos con IA
  final List<ServicePlan> videoPlans = const [
    ServicePlan(
      id: 'video_1',
      name: 'Starter Pack',
      price: 10000,
      type: PlanType.video,
      description: '1 Video con IA',
      features: ['1 Video', 'Guion y Voz IA', 'Formato vertical (Reels/TikTok)'],
    ),
    ServicePlan(
      id: 'video_2',
      name: 'Creator Duo',
      price: 16000,
      type: PlanType.video,
      description: '2 Videos con IA',
      features: ['2 Videos', 'Guion y Voz IA', 'Formato vertical (Reels/TikTok)'],
    ),
    ServicePlan(
      id: 'video_4',
      name: 'Social Pack',
      price: 24000,
      type: PlanType.video,
      description: '4 Videos con IA',
      features: ['4 Videos', 'Guion y Voz IA', 'Formato vertical (Reels/TikTok)'],
    ),
     ServicePlan(
      id: 'video_6',
      name: 'Business Pack',
      price: 36000,
      type: PlanType.video,
      description: '6 Videos con IA',
      features: ['6 Videos', 'Guion y Voz IA', 'Formato vertical (Reels/TikTok)'],
    ),
     ServicePlan(
      id: 'video_8',
      name: 'Growth Pack',
      price: 44000,
      type: PlanType.video,
      description: '8 Videos con IA',
      features: ['8 Videos', 'Guion y Voz IA', 'Formato vertical (Reels/TikTok)'],
    ),
     ServicePlan(
      id: 'video_10',
      name: 'Agency Pack',
      price: 50000,
      type: PlanType.video,
      description: '10 Videos con IA',
      features: ['10 Videos', 'Guion y Voz IA', 'Formato vertical (Reels/TikTok)'],
    ),
  ];
}

/// Provider para el repositorio de planes
@riverpod
PlansRepository plansRepository(PlansRepositoryRef ref) {
  return PlansRepository();
}