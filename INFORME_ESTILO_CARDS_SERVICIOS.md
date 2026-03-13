# Informe ultra detallado: estilo de las cards de servicios (APEX)

Este documento describe con precisión el estilo visual y de interacción de las **cards de planes/servicios** (donde se ofrecen webs y apps) en APEX, para poder replicarlo de forma consistente en el resto de la aplicación.

**Origen del estilo:**  
- Widget principal: `lib/features/services/presentation/widgets/plan_card.dart` (`PlanCard`)  
- Vista contenedora: `lib/features/services/presentation/views/services_view.dart`  
- Tema base: `lib/core/config/theme/app_theme_config.dart`  

---

## 1. Contenedor principal de la card

### 1.1 Caja (decoration)

| Propiedad | Valor | Notas |
|-----------|--------|--------|
| **Color de fondo** | `colorScheme.surface` (card normal) / `colorScheme.surfaceContainerLow` (card destacada/featured) | Depende de `plan.isFeatured`. |
| **Border radius** | `BorderRadius.circular(20)` | Es el valor único para el contenedor y para el `ClipRRect` interno. |
| **Borde** | `Border.all(...)` | Ver tabla de borde más abajo. |
| **Sombras** | Una sola `BoxShadow` que cambia en hover | Ver tabla de sombras. |

**Borde:**

| Estado | Color | Grosor |
|--------|--------|--------|
| Reposo (no featured) | `colorScheme.outline` con **alpha 0.12** | **1.0** |
| Hover o featured | `accent` (primary) con **alpha 0.28** (reposo) o **0.45** (featured) | **1.0** (reposo) / **1.5** (featured) |

**Sombras:**

| Estado | Color | blurRadius | offset | spreadRadius |
|--------|--------|------------|--------|--------------|
| Reposo | `Colors.black` con **alpha 0.04** | **14** | `Offset(0, 8)` | **-2** |
| Hover | `accent` con **alpha 0.07** | **36** | `Offset(0, 8)` | **0** |

- En hover la sombra se vuelve más difusa (blur 36), más “elevada” (spread 0) y con un tinte sutil del color de acento.

### 1.2 Animaciones del contenedor

- **Escala:** `AnimatedScale`  
  - Reposo: **1.0**  
  - Hover: **1.015**  
  - Duración: **220 ms**  
  - Curva: **Curves.easeOutCubic**  

- **Decoration (color, borde, sombra):** `AnimatedContainer`  
  - Duración: **220 ms**  
  - Curva: **Curves.easeOutCubic**  

### 1.3 Interacción

- `MouseRegion`: `onEnter` / `onExit` para activar hover.
- `GestureDetector`: `onTap` para abrir casos de éxito (si hay).
- Cursor: `SystemMouseCursors.click` si hay casos, `SystemMouseCursors.basic` si no.

---

## 2. Franja superior de acento (accent strip)

- **Altura:** **3 px** (fija).
- **Color:**  
  - Reposo: `accent.withValues(alpha: 0.35)`  
  - Hover o featured: `accent` (opaco).
- **Animación:** `AnimatedContainer`, **220 ms**, `Curves.easeOutCubic`.
- Va pegada al borde superior; el `ClipRRect` con radio 20 hace que coincida con las esquinas redondeadas.

---

## 3. Espaciado interno (padding del contenido)

- **Padding del bloque de contenido:**  
  `EdgeInsets.fromLTRB(24, 22, 24, 26)`  
  - Izquierda/derecha: **24**  
  - Arriba: **22**  
  - Abajo: **26**  

---

## 4. Badge (etiqueta del plan)

Hay dos variantes: badge normal y badge “featured” (HUD).

### 4.1 Badge normal (no featured)

| Propiedad | Valor |
|-----------|--------|
| Padding | `horizontal: 12`, `vertical: 5` |
| Fondo | `accent.withValues(alpha: 0.10)` |
| Border radius | `BorderRadius.circular(20)` |
| Borde | `Border.all(color: accent.withValues(alpha: 0.26))` (grosor por defecto 1) |
| Texto | `theme.textTheme.labelSmall` con: `color: accent`, `fontWeight: FontWeight.bold`, `letterSpacing: 0.2` |

### 4.2 Badge featured (HUD)

- **Padding:** `horizontal: 14`, `vertical: 6`.
- **Dibujo:** `CustomPaint` con `_HudBorderPainter`:
  - Fondo: `accent` con **alpha 0.10**.
  - Borde base: trazo **1.0**, `accent` con **alpha 0.28**.
  - “Destello”: trazo **1.5**, `SweepGradient` que recorre el perímetro (stops: 0.0, 0.38, 0.50, 0.62, 1.0; pico de color en 0.50).
  - Glow exterior: trazo **2.5**, `accent` con **alpha 0.18**, `MaskFilter.blur(BlurStyle.outer, 5)`.
- **Contenido:** punto pulsante (círculo que anima con `sin`) + texto en **MAYÚSCULAS**.
- **Texto:** `fontSize: 10.5`, `fontWeight: FontWeight.w800`, `letterSpacing: 1.4`, `color: accent`.
- **Animación:** `AnimationController` **2800 ms** en repeat para el barrido y el pulso.

---

## 5. Botón / enlace “Ejemplos”

- **Padding:** `horizontal: 10`, `vertical: 5`.
- **Border radius:** `BorderRadius.circular(8)`.
- **Borde:** `Border.all(color: colorScheme.outline.withValues(alpha: 0.16))`.
- **Icono:** `Icons.visibility_outlined`, **size 12**, `color: colorScheme.onSurfaceVariant`.
- **Texto:** `theme.textTheme.labelSmall` con `color: colorScheme.onSurfaceVariant`.
- **Espacio entre icono y texto:** **5** px.

---

## 6. Tipografía y jerarquía del contenido

### 6.1 Nombre del plan

- **Estilo base:** `theme.textTheme.headlineSmall`.
- **Override:** `fontWeight: FontWeight.w900`, `color: colorScheme.onSurface`, `letterSpacing: -0.4`, `height: 1.1`.

### 6.2 Tagline / descripción

- **Estilo:** `theme.textTheme.bodyMedium`.
- **Override:** `color: colorScheme.onSurfaceVariant`, `height: 1.45`.

### 6.3 Bloque de precio (planes con precio fijo)

- **Label “ARS”:** `theme.textTheme.labelMedium`, `color: colorScheme.onSurfaceVariant`, `fontWeight: FontWeight.bold`. Espacio a la cifra: **5** px.
- **Cifra de precio:** `theme.textTheme.displaySmall`, `fontWeight: FontWeight.w900`, `color: colorScheme.onSurface`, `letterSpacing: -1.5`, `height: 1`.
- **Precio tachado (antes):** `theme.textTheme.bodySmall`, `color: colorScheme.onSurfaceVariant`, `decoration: TextDecoration.lineThrough`. Espacio al badge de descuento: **8** px.
- **Badge de descuento (ej. “-X%”):**  
  - Fondo: `Color(0xFF22C55E).withValues(alpha: 0.14)`.  
  - Border radius: **20**.  
  - Padding: `horizontal: 8`, `vertical: 3`.  
  - Texto: `theme.textTheme.labelSmall`, `color: Color(0xFF22C55E)`, `fontWeight: FontWeight.bold`.  

### 6.4 Plan “a medida” (sin precio fijo)

- **Título:** `theme.textTheme.headlineMedium`, `fontWeight: FontWeight.w900`, `color: colorScheme.onSurface`, `letterSpacing: -0.5`, `height: 1`.
- **Subtítulo:** `theme.textTheme.bodySmall`, `color: colorScheme.onSurfaceVariant`. Espacio superior: **4** px.

### 6.5 Espaciado vertical entre bloques

- Tras badge/ejemplos: **18** px.
- Tras nombre del plan: **8** px.
- Tras tagline: **20** px.
- Entre precio y cuotas: **14** px.
- Tras cuotas: **18** px.
- Tras CTA: **24** px.

---

## 7. Línea de cuotas sin interés

- **Icono:** `Icons.credit_score_rounded`, **size 16**, `color: accent.withValues(alpha: 0.85)`.
- **Espacio icono–texto:** **8** px.
- **Texto:** `theme.textTheme.bodySmall`, `color: colorScheme.onSurfaceVariant`, `fontWeight: FontWeight.w600`.

---

## 8. Botón CTA principal (“Quiero un boceto gratis”)

- **Widget:** `OutlinedButton` con `SizedBox(width: double.infinity)`.
- **Estilo:**  
  - `foregroundColor: accent`.  
  - `side: BorderSide(color: accent.withValues(alpha: 0.5), width: 1.5)`.  
  - `padding: EdgeInsets.symmetric(vertical: 15)`.  
  - `shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))`.  
- **Contenido:** icono + texto en fila, centrados.
  - **Icono:** `Icons.draw_outlined`, **size 17**, `color: accent`.  
  - **Espacio icono–texto:** **8** px.  
  - **Texto:** `theme.textTheme.labelLarge`, `fontWeight: FontWeight.bold`, `color: accent`.  

---

## 9. Divisor “INCLUYE”

- **Líneas:** `Divider(color: colorScheme.outline.withValues(alpha: 0.12))`, con `Expanded` a cada lado.
- **Texto central:** `"INCLUYE"`, `theme.textTheme.labelSmall`, `color: colorScheme.onSurfaceVariant`, `letterSpacing: 1.4`, `fontSize: 10`.
- **Padding horizontal del texto:** **12** px a cada lado.
- **Espacio superior al bloque de features:** **16** px.

---

## 10. Lista de features (incluye)

- **Por ítem:**  
  - Padding inferior: **11** px.  
  - Fila: icono en círculo + espacio + texto.  
- **Círculo de check:**  
  - Tamaño: **18×18**.  
  - Fondo: `accent.withValues(alpha: 0.12)`.  
  - `shape: BoxShape.circle`.  
  - Icono: `Icons.check_rounded`, **size 11**, `color: accent`.  
  - Margen superior del contenedor: **1** px (alineación óptica).  
- **Espacio círculo–texto:** **10** px.  
- **Texto:** `theme.textTheme.bodySmall`, `height: 1.45`, `color: colorScheme.onSurface`.  

---

## 11. Bloque “Ideal para”

- **Contenedor:**  
  - `padding: EdgeInsets.all(13)`.  
  - `color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45)`.  
  - `borderRadius: BorderRadius.circular(11)`.  
  - `border: Border.all(color: colorScheme.outline.withValues(alpha: 0.08))`.  
- **Contenido:** icono + texto.
  - **Icono:** `Icons.person_outline_rounded`, **size 14**, `color: accent`.  
  - **Espacio icono–texto:** **8** px.  
  - **Texto:** `theme.textTheme.bodySmall`, `color: colorScheme.onSurfaceVariant`, `height: 1.5`.  
- **Espacio superior respecto a la última feature:** **6** px.

---

## 12. Contexto de tema (ColorScheme y superficie)

Los colores usados provienen de `Theme.of(context).colorScheme` y del tema definido en `app_theme_config.dart`:

- **Superficies (ejemplos):**  
  - `surface` → card normal.  
  - `surfaceContainerLow` → card featured.  
  - `surfaceContainerHighest` → bloques secundarios (ej. “Ideal para”) con alpha.  
- **Texto:**  
  - `onSurface` → títulos y cuerpo principal.  
  - `onSurfaceVariant` → descripciones, labels, secundarios.  
- **Acento:** `colorScheme.primary` (accent) usado en franja, badges, iconos, CTA, checks.  
- **Outline:** siempre con alpha baja (0.08, 0.12, 0.16, 0.2) para bordes y divisores suaves.  

**Tipografía global:** familia **Oxanium** (`_fontFamily = 'Oxanium'` en `app_theme_config.dart`).  
**Material:** `useMaterial3: true`.

---

## 13. Grid y layout de las cards (services_view)

- **Ancho máximo del contenido:** **1200** px, centrado.
- **Padding del bloque de servicios:** `horizontal: 24`, `vertical: 48`.
- **Separación entre cards:** **18** px (horizontal en desktop, vertical en móvil).
- **Desktop (≥860 px):** `Row` con cada card en `Expanded` (mismo ancho flexible).
- **Móvil/tablet:** `Column` con cada card dentro de `ConstrainedBox(maxWidth: 480)` centrado.
- Cada card va envuelta en `RepaintBoundary` para aislar repintados.

---

## 14. Resumen de constantes numéricas (referencia rápida)

| Elemento | Valor |
|----------|--------|
| Border radius card | 20 |
| Border radius CTA | 12 |
| Border radius badge | 20 |
| Border radius “Ejemplos” | 8 |
| Border radius “Ideal para” | 11 |
| Border radius descuento % | 20 |
| Altura franja acento | 3 |
| Padding contenido card | 24, 22, 24, 26 |
| Duración animaciones | 220 ms (150 ms en TrustCard) |
| Curva animaciones | Curves.easeOutCubic |
| Scale hover | 1.015 |
| Alpha borde reposo | 0.12 (outline) |
| Alpha borde hover/featured | 0.28 / 0.45 (accent) |
| Alpha sombra reposo | 0.04 (black) |
| Alpha sombra hover | 0.07 (accent) |
| Blur sombra reposo / hover | 14 / 36 |
| Offset sombra | (0, 8) |
| Spread sombra reposo | -2 |

---

## 15. Estilo “en una frase”

Cards con **esquinas 20**, **franja superior de 3 px** en color acento, **borde fino** (outline suave o accent en hover), **sombra suave** que se acentúa en hover junto con un **scale 1.015**, **padding 24/22/24/26**, tipografía **Oxanium** con pesos altos en títulos (w900) y uso sistemático de **colorScheme** (surface, onSurface, onSurfaceVariant, primary) y **alpha bajos** en bordes y fondos secundarios. Los elementos de acento (badges, checks, CTA) usan el **primary** con distintas transparencias (0.10, 0.12, 0.26, 0.28, 0.35, 0.5, 0.85) para mantener coherencia sin saturar.

---

*Documento generado a partir del análisis de `plan_card.dart`, `services_view.dart` y `app_theme_config.dart` para uso como guía de estilo en el resto de APEX.*
