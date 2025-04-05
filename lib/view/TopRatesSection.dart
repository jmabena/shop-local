import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class TopRatesSection extends StatelessWidget {
  final List<String> imageUrls = [
    "assets/images/one.png",
    "assets/images/Two.png",
  ];

  TopRatesSection({super.key});

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
            height: 200,
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
          items: List.generate((imageUrls.length / 2).ceil(), (index) {
            int first = index * 2;
            int second = first + 1;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildImageItem(imageUrls[first]),
                ),
                if (second < imageUrls.length)
                  Expanded(
                    child: _buildImageItem(imageUrls[second]),
                  ),
              ],
            );
          }),
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
