import 'package:flutter/material.dart';
import 'main.dart';

class BoozePage extends StatefulWidget {
  const BoozePage({Key? key, this.showMenuFunc}) : super(key: key);
  final showMenuFunc;

  @override
  State<BoozePage> createState() => _BoozePageState();
}

class _BoozePageState extends State<BoozePage> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox(
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
                      iconSize: size.width / 10,
                      onPressed: () {
                        widget.showMenuFunc();
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.white,
                      ),
                    )
                  ],
                )
              : GridView.count(
                  controller: scrollController,
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
          child: SizedBox(
            width: 40,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(0),
                  backgroundColor: Colors.transparent),
              onPressed: () {
                setState(() {
                  if (rowCount > 2) {
                    rowCount--;
                    box.write("rowCount", rowCount);
                  }
                });
              },
              child: const Icon(
                Icons.add,
              ),
            ),
          ),
        ),
        Positioned(
          top: 100,
          right: 0,
          child: SizedBox(
            width: 40,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(0),
                  backgroundColor: Colors.transparent),
              onPressed: () {
                setState(() {
                  rowCount++;
                  box.write("rowCount", rowCount);
                });
              },
              child: const Icon(
                Icons.remove,
              ),
            ),
          ),
        ),
        Positioned(
          top: 50,
          left: 0,
          child: SizedBox(
            width: 40,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(0),
                  backgroundColor: Colors.transparent),
              onPressed: () {
                scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              },
              child: const Icon(
                Icons.arrow_upward,
              ),
            ),
          ),
        ),
        Positioned(
          top: 100,
          left: 0,
          child: SizedBox(
            width: 40,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(0),
                  backgroundColor: Colors.transparent),
              onPressed: () {
                scrollController.animateTo(
                  scrollController.position.minScrollExtent,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              },
              child: const Icon(
                Icons.arrow_downward,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
