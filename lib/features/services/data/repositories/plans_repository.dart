// Archivo: lib/features/services/data/repositories/plans_repository.dart
import 'package:flutter/material.dart';
import 'package:prueba_de_riverpod/features/services/domain/models/case_study_model.dart';
import 'package:prueba_de_riverpod/features/services/domain/models/plan_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plans_repository.g.dart';

class PlansRepository {
  // --- PLANES WEB ---
  final List<ServicePlan> webPlans = const [
    ServicePlan(
      id: 'web_basic',
      name: 'Presencia Digital',
      price: 300000,
      originalPrice: 400000,
      type: PlanType.web,
      description: 'Tu carta de presentación al mundo. Ideal para profesionales que necesitan validar su marca.',
      idealFor: 'Profesionales independientes (Abogados, Contadores, Psicólogos) que necesitan validar su autoridad y ser encontrados en Google.',
      caseStudies: [
        CaseStudy(
          name: 'Simon Mindset',
          logoAsset: 'assets/icons/simon_logo.png', // Mantiene imagen
          url: 'https://simonmindset.com',
          brandColor: Color(0xFF8B0000),
          logoBgColor: Colors.black, 
        ),
        CaseStudy(
          name: 'Pérez Yeregui',
          // SIN logoAsset
          logoLetter: 'P', // <--- NUEVO: Letra P
          url: 'https://perez-yeregui2.vercel.app',
          brandColor: Color(0xFF5B5663),
          logoBgColor: Color(0xFF5B5663), // Fondo Gris
        ),
        CaseStudy(
          name: 'Metal Wailers',
          // SIN logoAsset
          logoLetter: 'M', // <--- NUEVO: Letra M
          url: 'https://metalwailers.com',
          brandColor: Color(0xFF263238), 
          logoBgColor: Colors.black, // Fondo Negro
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
      idealFor: 'Pequeñas empresas o Startups que buscan automatizar la atención al cliente, agendar citas y capturar leads.',
      caseStudies: [
        CaseStudy(
          name: 'Assistify',
          logoAsset: 'assets/icons/logo_assistify.png',
          url: 'https://assistify.lat',
          brandColor: Color(0xFF00A8E8),
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
      idealFor: 'Negocios en expansión que requieren control operativo total: gestión de stock, usuarios y métricas.',
      caseStudies: [
        CaseStudy(
          name: 'Pulpiprint',
          logoAsset: 'assets/icons/pulpiprint_logo.png',
          url: 'https://pulpiprint.com',
          brandColor: Color(0xFF7E57C2),
        ),
        CaseStudy(
          name: 'MNL Tecno',
          logoAsset: 'assets/icons/mnl_logo.png',
          url: 'https://mnltecno.com',
          brandColor: Color(0xFF0277BD),
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

  // --- PLANES DE APPS ---
  final List<ServicePlan> appPlans = const [
    ServicePlan(
      id: 'app_mvp',
      name: 'App MVP (Lanzamiento)',
      price: 1200000,
      originalPrice: 1600000, 
      type: PlanType.app,
      description: 'Producto Mínimo Viable: Lo esencial para salir al mercado y validar tu negocio rápido.',
      idealFor: 'Emprendedores que necesitan lanzar ya mismo para buscar inversores o primeros usuarios.',
      features: [
        'Desarrollo Híbrido (Android & iOS)',
        'Funcionalidades Core (Lo vital)',
        'Autenticación Segura',
        'Publicación en Tiendas',
        'Pago Único (Sin mensualidades)'
      ],
    ),
    ServicePlan(
      id: 'app_pro',
      name: 'App Corporativa Full',
      price: 2700000,
      originalPrice: 3600000, 
      type: PlanType.app,
      description: 'Solución robusta llave en mano. Desarrollo completo estimado en 90 días.',
      idealFor: 'Empresas que quieren digitalizar operaciones complejas o crear un canal de ventas propio.',
      features: [
        'Todo lo del plan MVP',
        'Panel Admin (Web o Escritorio)', 
        'Notificaciones Push & Pagos',
        'Soporte Post-Lanzamiento (3 meses)',
        'Financiación: 3 cuotas de \$900.000'
      ],
    ),
    ServicePlan(
      id: 'app_platform',
      name: 'Plataforma a Medida',
      price: 0, 
      isCustom: true,
      type: PlanType.app,
      description: 'Arquitectura compleja tipo Uber/Rappi. Modelo de Partner Tecnológico.',
      idealFor: 'Startups financiadas que requieren un equipo técnico dedicado y mantenimiento continuo.',
      features: [
        'Geolocalización en Tiempo Real',
        'Arquitectura de Microservicios',
        'Múltiples Apps (Cliente/Chofer/Admin)',
        'Infraestructura Escalable (AWS)',
        'Modelo de Retainer Mensual'
      ],
    ),
  ];
}

@riverpod
PlansRepository plansRepository(PlansRepositoryRef ref) {
  return PlansRepository();
}