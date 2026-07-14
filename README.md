# buildscan_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

# buildscan_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Backend y servicios
El proyecto utiliza Supabase como backend principal para autenticación, base de datos,
storage y realtime. La base de datos contiene perfiles por rol, ferreterías, materiales,
proyectos, proformas, solicitudes de cotización, detalle de cotización y valoraciones.

### Ejecutar el proyecto
Asegúrate de tener tu archivo `.env` configurado en la raíz del proyecto.
```bash
flutter run
```

### Flujo backend principal
1. El usuario se registra como constructora o ferretería.
2. La constructora crea un proyecto y una proforma.
3. La proforma se envía a ferreterías cercanas.
4. La ferretería responde con una cotización.
5. La constructora acepta o rechaza la cotización.
