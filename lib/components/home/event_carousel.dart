import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:photo_view/photo_view.dart';

class EventCarousel extends StatelessWidget {
  final List<dynamic> events;

  EventCarousel({required this.events});

  void showEventDetails(BuildContext context, dynamic event) {
    initializeDateFormatting('pt_BR', null).then((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final startDate =
              DateFormat('dd-MM-yyyy', 'pt_BR').parse(event['start_date']);
          final endDate =
              DateFormat('dd-MM-yyyy', 'pt_BR').parse(event['end_date']);
          final formattedStartDate =
              DateFormat('dd MMMM yyyy', 'pt_BR').format(startDate);
          final formattedEndDate =
              DateFormat('dd MMMM yyyy', 'pt_BR').format(endDate);

          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              event['title'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.all(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: PhotoView(
                              imageProvider: NetworkImage(event['image']),
                              backgroundDecoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(event['image']),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      const Icon(Icons.event, color: Colors.blueAccent),
                      const SizedBox(width: 8.0),
                      Text(
                        'Início: $formattedStartDate',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(Icons.event, color: Colors.blueAccent),
                      const SizedBox(width: 8.0),
                      Text(
                        'Fim: $formattedEndDate',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Descrição do Evento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    event['description'] ?? 'Sem descrição disponível.',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Fechar',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Eventos',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
            height:
                10.0), // Adiciona um pequeno espaço entre o título e o carrossel
        Container(
          height: 130,
          child: CarouselSlider.builder(
            itemCount: events.length,
            itemBuilder: (context, index, realIdx) {
              final event = events[index];
              final truncatedTitle = event['title'].length > 20
                  ? '${event['title'].substring(0, 20)}...'
                  : event['title'];

              return GestureDetector(
                onTap: () => showEventDetails(context, event),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(event['image']),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Flexible(
                      child: Text(
                        truncatedTitle,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 1.0,
              viewportFraction: 0.3,
              enableInfiniteScroll: events.length > 2,
            ),
          ),
        ),
      ],
    );
  }
}
