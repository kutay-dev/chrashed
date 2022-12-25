import 'package:flutter/material.dart';
import 'main.dart';

class CalculationsPage extends StatefulWidget {
  const CalculationsPage({Key? key}) : super(key: key);

  @override
  State<CalculationsPage> createState() => _CalculationsPageState();
}

class _CalculationsPageState extends State<CalculationsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Column(
            children: [
              Text(
                "total ≈ ${alcList['total']!.toStringAsFixed(2)} ml of alc",
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Instead of drinking those you could've drink these",
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "${alcList['small_shots']!.toStringAsFixed(2)} shots of",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Image.asset(
                      "assets/small_shot.png",
                      scale: 3,
                      color: Colors.white,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "${alcList['big_shots']!.toStringAsFixed(2)} shots of",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Image.asset(
                      "assets/big_shot.png",
                      scale: 3,
                      color: Colors.white,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "${alcList['beers']!.toStringAsFixed(2)} bottles of",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Image.asset(
                      "assets/bottle_beer.png",
                      scale: 3,
                      color: Colors.white,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "${alcList['hard_beers']!.toStringAsFixed(2)} cans of",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Image.asset(
                      "assets/hard_beer.png",
                      scale: 3,
                      color: Colors.white,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "${alcList['wines']!.toStringAsFixed(2)} glasses of",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Image.asset(
                      "assets/wine_glass.png",
                      scale: 3,
                      color: Colors.white,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "${alcList['whiskeys']!.toStringAsFixed(2)} glasses of",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Image.asset(
                      "assets/whiskey_glass.png",
                      scale: 3,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
