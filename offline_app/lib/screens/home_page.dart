import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:offline_app/screens/timer_page.dart';

import 'package:offline_app/styles/text_styles.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 100),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              FadeInDown(
                from: 100,
                child: AnimatedTextKit(
                  isRepeatingAnimation: false,
                  animatedTexts: [
                    TyperAnimatedText('Γεια σου και πάλι τάδε!',
                        textStyle: headerStyles()),
                    TyperAnimatedText(
                        'Ήρθε μήπως η ώρα\nνα φορέσουμε το\n  μασελάκι μας;',
                        textStyle: headerStyles()),
                    TyperAnimatedText('Φύγαμε!', textStyle: headerStyles()),
                  ],
                  onFinished: () {
                    Navigator.of(context).push(_fadeThroughPageRoute(const TimerPage()));

                  },
                  onTap: () {
                     Navigator.of(context).push(_fadeThroughPageRoute(const TimerPage()));
                  },
                ),
              ),
            ],
          )
        ],
      ),
    ));
  }

  PageRouteBuilder _fadeThroughPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}
