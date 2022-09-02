import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

final GetStorage box = GetStorage();

final PageController controller = PageController();

class _MyHomePageState extends State<MyHomePage> {
  void addBooze(String imageUrl, double scale, double alc) {
    Clipboard.setData(const ClipboardData());
    HapticFeedback.heavyImpact();

    setState(() {
      boozes.add({
        "imageUrl": imageUrl,
        "scale": scale,
      });
      alcohols.add(alc);
    });
    box.write("boozes", boozes);
    box.write("alcohols", alcohols);
  }

  List<dynamic> boozes = box.read("boozes") ?? [];
  List<dynamic> alcohols = box.read("alcohols") ?? [];

  int rowCount = 4;
  num otoScale = 2;

  Map<String, double> alcList = {};

  @override
  void initState() {
    getAlcohols();
    super.initState();
  }

  Widget boozeButton(String imageUrl, double scale, String text, double alc) {
    return InkWell(
      onTap: () => addBooze("assets/$imageUrl.png", scale, alc),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            "assets/$imageUrl.png",
            scale: 3,
            color: Colors.black87,
          ),
          Text(
            text,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Map getAlcohols() {
    double totalAlc = 0;
    for (int i = 0; i < alcohols.length; i++) {
      totalAlc += alcohols[i];
    }
    alcList["total"] = totalAlc;
    alcList["beers"] = totalAlc / 17.75;
    alcList["hard_beers"] = totalAlc / 37.5;
    alcList["shots"] = totalAlc / 16;
    alcList["vodkas"] = totalAlc / 129;
    alcList["whiskeys"] = totalAlc / 140;
    return alcList;
  }

  void showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                height: 0,
              ),
              Expanded(
                child: SizedBox(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    child: Stack(
                      alignment: const Alignment(0, 0),
                      children: <Widget>[
                        Positioned(
                          child: GridView.count(
                            crossAxisCount: 3,
                            children: <Widget>[
                              boozeButton(
                                  "bottle_beer", 1, "Bottle beer", 17.75),
                              boozeButton("can_beer", 1, "Can beer", 17.75),
                              boozeButton("mug_beer", 1, "Mug beer", 26),
                              boozeButton("hard_beer", 1, "Hard beer", 37.5),
                              boozeButton("vodka", 1, "Vodka", 129),
                              boozeButton("wine_glass", 1, "Wine", 17),
                              boozeButton("small_shot", 1, "Small shot", 16),
                              boozeButton("big_shot", 1, "Big shot", 20),
                              boozeButton("whiskey", 1, "Whiskey", 140),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 0,
                color: const Color(0xff4a6572),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      //backgroundColor: Color.fromARGB(255, 4, 4, 4),
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomAppBar(
        elevation: 10,
        color: Colors.black,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          height: 56.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    boozes.clear();
                    alcohols.clear();
                    box.remove("boozes");
                    box.remove("alcohols");
                  });
                },
                icon: const Icon(Icons.remove_circle),
                color: Colors.white,
              ),
              IconButton(
                onPressed: () {
                  controller.animateToPage(0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.ease);
                  showMenu();
                },
                icon: const Icon(Icons.add),
                color: Colors.white,
              ),
              IconButton(
                onPressed: () {
                  controller.animateToPage(1,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.ease);
                  setState(() {
                    getAlcohols();
                  });
                },
                icon: const Icon(Icons.notes),
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          PageView(
            controller: controller,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  SizedBox(
                    height: 810,
                    width: double.infinity,
                    child: GridView.count(
                      reverse: true,
                      crossAxisCount: rowCount,
                      children: <Widget>[
                        for (int i = 0; i < boozes.length; i++)
                          Container(
                            alignment: Alignment.bottomCenter,
                            child: Image.asset(
                              boozes[i]["imageUrl"],
                              scale: (boozes[i]["scale"]),
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
                          if (rowCount > 1) {
                            rowCount--;
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
                        });
                      },
                      icon: const Icon(Icons.remove),
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      "total ≈ ${alcList['total']!.toStringAsFixed(2)} ml of alc",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      "Instead of drinking those you could've drink these",
                      style: TextStyle(
                        color: Colors.white54,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "${alcList['shots']!.toStringAsFixed(2)} shots of",
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "${alcList['beers']!.toStringAsFixed(2)} botttles of",
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "${alcList['vodkas']!.toStringAsFixed(2)} bottles of",
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              Image.asset(
                                "assets/vodka.png",
                                scale: 3,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "${alcList['whiskeys']!.toStringAsFixed(2)} bottles of",
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              Image.asset(
                                "assets/whiskey.png",
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
