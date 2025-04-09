import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../models/top_rate.dart';

class TopRatesSection extends StatelessWidget {
  final List<TopRate> topRates;

  const TopRatesSection({super.key, required this.topRates});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            "Top Rates",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        CarouselSlider(
          options: CarouselOptions(
            height: 280,
            autoPlay: true,
            animateToClosest: true,
            pauseAutoPlayOnTouch: true,
            pauseAutoPlayInFiniteScroll: true,
            pauseAutoPlayOnManualNavigate: true,
            autoPlayAnimationDuration: const Duration(seconds: 2),
            enlargeCenterPage: true,
            viewportFraction: 1.0,
            scrollPhysics: const BouncingScrollPhysics()
          ),
          items: topRates.map((topRate) {
            return Container(
              margin: const EdgeInsets.all(5),
              width: 450,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  topRate.imageUrl,
                  fit: BoxFit.cover ,
                  errorBuilder: (_, __, ___) =>
                    Image.asset('assets/images/One.png'),),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  Widget _buildImageItem(String url) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue, width: 2), 
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(url, fit: BoxFit.cover, width: double.infinity, height: 180),
      ),
    );
  }
}
