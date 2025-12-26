// Archivo: lib/features/about_me/presentation/views/about_me_view.dart
import 'package:flutter/material.dart';
import 'package:prueba_de_riverpod/features/shared/widgets/footer.dart';

class AboutMeView extends StatelessWidget {
  const AboutMeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos SingleChildScrollView y Column para acomodar contenido + Footer
    return SingleChildScrollView(
      child: Column(
        children: [
          // Contenido principal (Con altura mínima para empujar el footer si hay poco contenido)
          Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            child: const Text(
              'Próximamente: Historia completa, biografía y trayectoria.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
          
          // --- FOOTER ---
          const Footer(),
        ],
      ),
    );
  }
}