import 'package:flutter/material.dart';

class AllStoresSection extends StatelessWidget {
  final List<String> imageUrls = [
    "assets/images/stories01.png",
    "assets/images/stories02.png"
  ];

  AllStoresSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            "All Stories",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SingleChildScrollView(
            scrollDirection: Axis.vertical,
          child: SizedBox(
            height: 450,
            child:
              ListView.builder(
                //scrollDirection: Axis.vertical, 
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    //width: 200, 
                    margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 10), 
                    child: Image.asset(
                      imageUrls[index],
                      width: double.infinity, 
                      fit: BoxFit.cover, 
                    ),
                  );
                },
              )

          )
        ),
      ],
    );
  }
}
