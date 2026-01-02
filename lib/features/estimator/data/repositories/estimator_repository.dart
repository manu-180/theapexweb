// Archivo: lib/features/estimator/data/repositories/estimator_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:apex/features/estimator/domain/models/estimator_item_model.dart';

part 'estimator_repository.g.dart';

class EstimatorRepository {
  
  // --- OPCIONES WEB ---
  final List<EstimatorItem> webItems = const [
    EstimatorItem(
      id: 'web_landing',
      label: 'Identidad Digital (Landing)',
      description: 'Página principal de alto impacto, SEO y contacto.',
      price: 300000, 
      originalPrice: 400000, 
      type: ServiceType.web,
      isCore: true, 
    ),
    EstimatorItem(
      id: 'web_auth',
      label: 'Cuentas de Usuario',
      description: 'Registro, Login seguro, Recuperar contraseña y Perfiles.',
      price: 200000,
      originalPrice: 300000,
      type: ServiceType.web,
    ),
    EstimatorItem(
      id: 'web_db',
      label: 'Base de Datos Dinámica',
      description: 'Guardado de información compleja (Turnos, Pedidos, Historial).',
      price: 250000,
      originalPrice: 350000,
      type: ServiceType.web,
    ),
    EstimatorItem(
      id: 'web_cms',
      label: 'Gestión de Contenidos (CMS)',
      description: 'Panel para que edites textos, blog e imágenes sin programar.',
      price: 200000,
      originalPrice: 300000,
      type: ServiceType.web,
    ),
    EstimatorItem(
      id: 'web_payments',
      label: 'Pasarela de Pagos',
      description: 'Cobra tus servicios online (MercadoPago / Stripe).',
      price: 300000,
      originalPrice: 450000,
      type: ServiceType.web,
    ),
    EstimatorItem(
      id: 'web_chat',
      label: 'Chat o Soporte en Vivo',
      description: 'Integración de WhatsApp flotante o Chatbot básico.',
      price: 100000,
      originalPrice: 150000,
      type: ServiceType.web,
    ),
    EstimatorItem(
      id: 'web_admin',
      label: 'Panel de Administración Full',
      description: 'Dashboard privado con métricas y control total del negocio.',
      price: 400000,
      originalPrice: 600000,
      type: ServiceType.web,
    ),
  ];

  // --- OPCIONES APP ---
  final List<EstimatorItem> appItems = const [
    EstimatorItem(
      id: 'app_core',
      label: 'App Híbrida (iOS + Android)',
      description: 'Desarrollo base en Flutter, publicación en tiendas y pantallas principales.',
      price: 1200000,
      originalPrice: 1600000,
      type: ServiceType.app,
      isCore: true,
    ),
    EstimatorItem(
      id: 'app_auth',
      label: 'Autenticación Biométrica',
      description: 'Login con Email, Google, Apple y Huella/FaceID.',
      price: 350000, 
      originalPrice: 500000,
      type: ServiceType.app,
    ),
    EstimatorItem(
      id: 'app_push',
      label: 'Sistema de Notificaciones',
      description: 'Alertas push segmentadas para retener usuarios.',
      price: 300000, 
      originalPrice: 450000,
      type: ServiceType.app,
    ),
    EstimatorItem(
      id: 'app_maps',
      label: 'Geolocalización Avanzada',
      description: 'Mapas en tiempo real, rutas y rastreo GPS (Tipo Uber/Rappi).',
      price: 600000, 
      originalPrice: 900000,
      type: ServiceType.app,
    ),
    EstimatorItem(
      id: 'app_admin',
      label: 'Panel Admin Web',
      description: 'Obligatorio para gestionar usuarios y datos de la App desde PC.',
      price: 700000, 
      originalPrice: 1000000,
      type: ServiceType.app,
    ),
    EstimatorItem(
      id: 'app_payments',
      label: 'Cobros In-App & Wallet',
      description: 'Billetera virtual, historial y pasarelas de pago nativas.',
      price: 500000,
      originalPrice: 750000,
      type: ServiceType.app,
    ),
    EstimatorItem(
      id: 'app_offline',
      label: 'Modo Offline (Sync)',
      description: 'Base de datos local que sincroniza cuando vuelve internet.',
      price: 450000,
      originalPrice: 650000,
      type: ServiceType.app,
    ),
    // ELIMINADO 'app_support' de aquí porque ahora es implícito
  ];

  List<EstimatorItem> getItems(ServiceType type) {
    return type == ServiceType.web ? webItems : appItems;
  }
}

@riverpod
EstimatorRepository estimatorRepository(EstimatorRepositoryRef ref) {
  return EstimatorRepository();
}