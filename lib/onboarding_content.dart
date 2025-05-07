import 'package:flutter/material.dart';

class OnboardingContent extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingContent({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
       // الخلفيه اللي وراء البنفسجيه
        Container(
          width: 350, 
          height: 700, 
          decoration: BoxDecoration(
            color: Color(0xFFC19DDA), 
            borderRadius: BorderRadius.circular(30), 
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // صورة الillustration
            Image.asset(image, width: 300), 
            SizedBox(height: 40),
            // h1
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              softWrap: true,
              maxLines: null,
            ),
            SizedBox(height: 10),
            // حق النص الوصفي
            Text(
              description,
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
              softWrap: true,
              maxLines: null,
              
            ),
          ],
        ),
      ],
    );
  }
}