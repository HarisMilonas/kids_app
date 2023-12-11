import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:offline_app/componets/page_router.dart';
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
                    TyperAnimatedText(
                      "LaLizas Test Application",
                      // 'Γεια σου και πάλι τάδε!',
                        textStyle: headerStyles()),
                    TyperAnimatedText(
                      "This is a test application",
                        // 'Ήρθε μήπως η ώρα\nνα φορέσουμε το\n  μασελάκι μας;',
                        textStyle: headerStyles()),
                    TyperAnimatedText(
                      "Lets go",
                      // 'Φύγαμε!',
                       textStyle: headerStyles()),
                  ],
                  onFinished: () {
                    Navigator.of(context).push(CustomPageRouter.fadeThroughPageRoute(const TimerPage()));

                  },
                  onTap: () {
                     Navigator.of(context).push(CustomPageRouter.fadeThroughPageRoute(const TimerPage()));
                  },
                ),
              ),
            ],
          )
        ],
      ),
    ));
  }
  
}
