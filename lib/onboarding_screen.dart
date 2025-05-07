import 'package:flutter/material.dart';
import 'onboarding_content.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "images/booking.png",
      "title": "Book Your Spot Easily!",
      "description":
          "Save time and effort by booking your spot \n in advance for any service, whether at banks, restaurants, or hospitals."
    },
    {
      "image": "images/notif.png",
      "title": "Stay Updated with \n Real-Time Notifications",
      "description":
          "Dawri ensures you never miss your turn\n by sending real-time notifications about your \n queue status.Stay informed and on \n track effortlessly"
    },
    {
      "image": "images/feedback.png",
      "title": "Share Your Experience",
      "description":
          "Help improve the service by providing your\n feedback and rating after using the service."
    },
    {
      "image": "images/sp.png",
      "title": "Priority Service for Special Cases",
      "description":
          "Dawri gives special priority to individuals \nwith special needs and the elderly,\nensuring they receive faster service."
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemCount: onboardingData.length,
            itemBuilder: (context, index) => OnboardingContent(
              image: onboardingData[index]["image"]!,
              title: onboardingData[index]["title"]!,
              description: onboardingData[index]["description"]!,
            ),
          ),

          // زر حق السكيب
          Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/welcome");
                  _controller.jumpToPage(onboardingData.length - 1);
                },
                child: Text("SKIP", style: TextStyle(color: Colors.purple)),
              )),

          // نقاط حقت الصفحة
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(onboardingData.length, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    width: currentIndex == index ? 16.0 : 10.0,
                    height: 10.0,
                    decoration: BoxDecoration(
                      color:
                          currentIndex == index ? Colors.purple : Colors.grey,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                }),
              ),
            ),
          ),

          // الازرار حقت تالي وسابق
          Positioned(
            bottom: 20,
            left: 20,
            child: currentIndex > 0
                ? TextButton(
                    onPressed: () {
                      _controller.previousPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text("BACK", style: TextStyle(color: Colors.purple)),
                  )
                : SizedBox(),
          ),

// زر بدايه بعد ماتنتهي صفحات
          Positioned(
            bottom: 20,
            right: 20,
            child: currentIndex == onboardingData.length - 1
                ? ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/welcome");
                    },
                    child: Text("START"),
                  )
                : TextButton(
                    onPressed: () {
                      _controller.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text("NEXT", style: TextStyle(color: Colors.purple)),
                  ),
          ),
        ],
      ),
    );
  }
}
