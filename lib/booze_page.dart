import 'package:flutter/material.dart';
import 'main.dart';

class BoozePage extends StatefulWidget {
  const BoozePage({Key? key, this.god}) : super(key: key);
  final god;

  @override
  State<BoozePage> createState() => _BoozePageState();
}

class _BoozePageState extends State<BoozePage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox(
          height: 810,
          width: double.infinity,
          child: (boozes.isEmpty)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "You havent consumed any booze yet",
                      style: TextStyle(color: Colors.white38),
                    ),
                    IconButton(
                      onPressed: () {
                        widget.god();
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.white,
                        size: 40,
                      ),
                    )
                  ],
                )
              : GridView.count(
                  reverse: true,
                  crossAxisCount: rowCount,
                  children: <Widget>[
                    for (int i = 0; i < boozes.length; i++)
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: Image.asset(
                          boozes[i]["imageUrl"],
                          scale: 1,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
        ),
        Positioned(
          top: 50,
          right: 0,
          child: IconButton(
            onPressed: () {
              setState(() {
                if (rowCount > 2) {
                  rowCount--;
                  box.write("rowCount", rowCount);
                }
              });
            },
            icon: const Icon(Icons.add),
            color: Colors.grey,
          ),
        ),
        Positioned(
          top: 90,
          right: 0,
          child: IconButton(
            onPressed: () {
              setState(() {
                rowCount++;
                box.write("rowCount", rowCount);
              });
            },
            icon: const Icon(Icons.remove),
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
