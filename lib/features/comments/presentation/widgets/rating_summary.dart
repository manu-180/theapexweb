// Archivo: lib/features/comments/presentation/widgets/rating_summary.dart
import 'package:flutter/material.dart';
import 'package:apex/features/comments/presentation/providers/comments_provider.dart';

class RatingSummary extends StatelessWidget {
  final List<Comment> comments;

  const RatingSummary({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    // 1. Filtrar solo comentarios con rating (Excluir respuestas y nulos)
    final ratings = comments
        .where((c) => c.rating != null && c.rating! > 0)
        .map((c) => c.rating!)
        .toList();

    if (ratings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(Icons.star_outline_rounded, size: 40, color: Colors.amber.withOpacity(0.5)),
            const SizedBox(height: 8),
            Text(
              "Sé el primero en calificar",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Tu opinión ayuda a otros a tomar mejores decisiones.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // 2. Cálculos Estadísticos
    final double average = ratings.reduce((a, b) => a + b) / ratings.length;
    final int total = ratings.length;

    // Conteo por estrella (5, 4, 3, 2, 1)
    final Map<int, int> counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var r in ratings) {
      counts[r] = (counts[r] ?? 0) + 1;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // COLUMNA IZQUIERDA: Promedio Grande
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  average.toStringAsFixed(1),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                _StarRow(rating: average, size: 20),
                const SizedBox(height: 8),
                Text(
                  "$total calificaciones",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 24),

          // COLUMNA DERECHA: Barras de Progreso
          Expanded(
            flex: 3,
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final count = counts[star] ?? 0;
                final percentage = total == 0 ? 0.0 : count / total;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        "$star", 
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.star_rounded, size: 12, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage,
                            minHeight: 6,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber), // Color fijo MercadoLibre
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 20,
                        child: Text(
                          "$count",
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper para dibujar estrellitas estáticas (o medias estrellas)
class _StarRow extends StatelessWidget {
  final double rating;
  final double size;

  const _StarRow({required this.rating, required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        if (starIndex <= rating) {
          return Icon(Icons.star_rounded, color: Colors.amber, size: size);
        } else if (starIndex - 0.5 <= rating) {
          return Icon(Icons.star_half_rounded, color: Colors.amber, size: size);
        } else {
          return Icon(Icons.star_outline_rounded, color: Colors.amber.withOpacity(0.3), size: size);
        }
      }),
    );
  }
}