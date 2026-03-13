// Archivo: lib/features/services/data/repositories/plans_repository.dart
import 'package:flutter/material.dart';
import 'package:apex/features/services/domain/models/case_study_model.dart';
import 'package:apex/features/services/domain/models/plan_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plans_repository.g.dart';

class PlansRepository {
  // --- PLANES WEB ---
  final List<ServicePlan> webPlans = const [
    ServicePlan(
      id: 'web_basic',
      name: 'Landing Page',
      badge: 'Esencial',
      price: 300000,
      originalPrice: 420000,
      type: PlanType.web,
      description:
          'Tu mejor vendedor, disponible las 24 h. Diseñada para convertir visitas en clientes reales.',
      idealFor:
          'Coaches, abogados, psicólogos, contadores y profesionales independientes que necesitan presencia sólida en línea.',
      caseStudies: [
        CaseStudy(
          name: 'Simon Mindset',
          logoAsset: 'assets/icons/simon_logo.png',
          url: 'https://simonmindset.com',
          brandColor: Color(0xFF8B0000),
          logoBgColor: Colors.black,
        ),
        CaseStudy(
          name: 'Pérez Yeregui',
          logoLetter: 'P',
          url: 'https://perez-yeregui2.vercel.app',
          brandColor: Color(0xFF5B5663),
          logoBgColor: Color(0xFF5B5663),
        ),
        CaseStudy(
          name: 'Metal Wailers',
          logoLetter: 'M',
          url: 'https://metalwailers.com',
          brandColor: Color(0xFF263238),
          logoBgColor: Colors.black,
        ),
        CaseStudy(
          name: 'Poncho Spanish',
          logoAsset: 'assets/icons/ponchospanish_logo.png',
          url: 'https://ponchospanish.com',
          brandColor: Color(0xFFD4A84B),
          logoBgColor: Colors.black,
        ),
      ],
      features: [
        'Diseño 100% a medida (sin plantillas genéricas)',
        'Secciones de servicios, bio, testimonios y contacto',
        'Botón WhatsApp + formulario con auto-respuesta por email',
        'Carga ultrarrápida optimizada con Flutter Web',
        'SEO técnico para aparecer en Google',
        'Hosting + 3 meses de mantenimiento incluidos',
      ],
    ),
    ServicePlan(
      id: 'web_interactive',
      name: 'Web Interactiva',
      badge: 'Más elegido',
      isFeatured: true,
      price: 600000,
      originalPrice: 880000,
      type: PlanType.web,
      description:
          'Automatizá el contacto con tus clientes y agregá cualquier funcionalidad a medida.',
      idealFor:
          'Pequeñas empresas y startups que quieren automatizar procesos y capturar leads sin esfuerzo.',
      caseStudies: [
        CaseStudy(
          name: 'Assistify',
          logoAsset: 'assets/icons/logo_assistify.png',
          url: 'https://assistify.lat',
          brandColor: Color(0xFF00A8E8),
        ),
        CaseStudy(
          name: 'Botrive',
          logoAsset: 'assets/icons/logo_botlode.png',
          url: 'https://botrive.com',
          brandColor: Color(0xFFFFC000),
          logoBgColor: Colors.black,
        ),
        CaseStudy(
          name: 'Botlode',
          logoAsset: 'assets/icons/logo_botlode.png',
          url: 'https://botlode.com',
          brandColor: Color(0xFFFFC000),
          logoBgColor: Colors.black,
        ),
      ],
      features: [
        'Todo lo del plan Landing Page',
        'Base de datos conectada (Supabase)',
        'Funcionalidades complejas: control de stock, cotizadores, calculadoras, reservas y dashboards',
        'Panel de administración para gestionar contenido sin tocar código',
        'Integraciones: WhatsApp, MercadoPago, Google Calendar y más',
        'Hosting + 3 meses de mantenimiento incluidos',
      ],
    ),
    ServicePlan(
      id: 'web_premium',
      name: 'Tienda Online',
      badge: 'E-commerce',
      price: 900000,
      originalPrice: 1400000,
      type: PlanType.web,
      description:
          'Vendé productos o servicios con tu propio canal de ventas. Sin comisiones de terceros.',
      idealFor:
          'Comercios y emprendimientos que quieren vender online sin depender de Mercado Libre ni de Instagram.',
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
        'Catálogo de productos con filtros y búsqueda',
        'Carrito + checkout con MercadoPago / Stripe',
        'Panel admin para gestionar pedidos, stock y clientes',
        'Sistema de cuentas de clientes con historial de compras',
        'SEO técnico avanzado para atraer tráfico orgánico',
        'Hosting + 3 meses de mantenimiento incluidos',
      ],
    ),
  ];

  // --- PLANES DE APPS ---
  final List<ServicePlan> appPlans = const [
    ServicePlan(
      id: 'app_mvp',
      name: 'App Profesional',
      badge: 'Starter',
      price: 1200000,
      originalPrice: 1700000,
      type: PlanType.app,
      description:
          'Tu idea, convertida en app lista para las tiendas. Funcional, rápida y con buena UX.',
      idealFor:
          'Emprendedores que quieren lanzar una app funcional —de gestión, reservas, clientes o contenido— sin exceso de complejidad.',
      features: [
        'Android + iOS desde un único proyecto (Flutter)',
        'Funcionalidades core de tu negocio',
        'Autenticación segura (email, Google o Apple)',
        'Notificaciones push básicas',
        'Publicación en App Store y Play Store',
        '3 meses de mantenimiento incluidos',
      ],
    ),
    ServicePlan(
      id: 'app_pro',
      name: 'App Empresarial',
      badge: 'Empresas',
      isFeatured: true,
      price: 2700000,
      originalPrice: 3800000,
      type: PlanType.app,
      description:
          'Automatizá procesos, reducí la carga laboral y escalá tu negocio con tecnología real.',
      idealFor:
          'Empresas que buscan digitalizar operaciones, gestionar equipos y tomar decisiones con datos en tiempo real.',
      features: [
        'Todo lo del plan Starter',
        'Panel de administración web o de escritorio',
        'Roles y permisos para múltiples usuarios',
        'Pagos integrados (MercadoPago / Stripe)',
        'Reportes y métricas en tiempo real',
        '3 meses de mantenimiento incluidos',
      ],
    ),
    ServicePlan(
      id: 'app_platform',
      name: 'Plataforma Avanzada',
      badge: 'Premium',
      price: 0,
      isCustom: true,
      type: PlanType.app,
      description:
          'Arquitectura de nivel Uber o Rappi. Tecnología sin límites para startups con visión.',
      idealFor:
          'Startups con financiamiento que necesitan un socio tecnológico de largo plazo y una arquitectura lista para escalar.',
      features: [
        'Múltiples apps (cliente, operador y administrador)',
        'Geolocalización y tracking en tiempo real',
        'Arquitectura de microservicios escalable',
        'Infraestructura en la nube (AWS / GCP)',
        'Equipo técnico dedicado (modelo de partner)',
        'Mantenimiento continuo + SLA garantizado',
      ],
    ),
  ];
}

@riverpod
PlansRepository plansRepository(PlansRepositoryRef ref) {
  return PlansRepository();
}
