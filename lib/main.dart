import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white38,
            ),
      ),
      debugShowCheckedModeBanner: false,
      home: const Main(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  State<Main> createState() => _MainState();
}

final GetStorage box = GetStorage();

class _MainState extends State<Main> {
  final PageController pageController = PageController(initialPage: 1);
  final TextEditingController nameController = TextEditingController();

  List<dynamic> boozes = box.read("boozes") ?? [];
  List<dynamic> alcohols = box.read("alcohols") ?? [];

  String userId = box.read("userId") ?? Random().nextInt(1000000).toString();

  int rowCount = 4;

  Map<String, double> alcList = {};

  CollectionReference leadersColl =
      FirebaseFirestore.instance.collection('leaders');

  @override
  void initState() {
    getAlcohols();

    super.initState();
  }

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

  Future<void> setLeaders() async {
    int totalAlc = getTotalAlc().toInt();

    leadersColl.doc(userId).set({
      'id': userId,
      'name': box.read("name"),
      'alc': totalAlc,
    });

    setState(() {});
  }

  void signUp() {
    box.write("userLoggedIn", true);
    box.write("name", nameController.text);
    box.write("userId", userId);
    setLeaders();

    setState(() {});
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

  double getTotalAlc() {
    double totalAlc = 0;
    for (int i = 0; i < alcohols.length; i++) {
      totalAlc += alcohols[i];
    }
    return totalAlc;
  }

  Map getAlcohols() {
    double totalAlc = getTotalAlc();
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
                              boozeButton("wine_glass", 1, "Wine", 18),
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
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  if (box.read("userLoggedIn") ?? false) setLeaders();

                  pageController.animateToPage(0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.ease);
                },
                icon: const Icon(Icons.leaderboard),
                color: Colors.white,
              ),
              IconButton(
                onPressed: () {
                  pageController.animateToPage(1,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.ease);
                  showMenu();
                  setState(() {});
                },
                icon: const Icon(Icons.add),
                color: Colors.white,
              ),
              IconButton(
                onPressed: () {
                  getAlcohols();
                  setState(() {});
                  pageController.animateToPage(2,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.ease);
                },
                icon: const Icon(
                  Icons.notes,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          PageView(
            controller: pageController,
            children: <Widget>[
              (box.read("userLoggedIn") ?? false
                  ? FutureBuilder<QuerySnapshot>(
                      future: leadersColl
                          .limit(20)
                          .orderBy('alc', descending: true)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text("Something went wrong");
                        }

                        if (snapshot.connectionState == ConnectionState.done) {
                          final List<DocumentSnapshot> documents =
                              snapshot.data!.docs;
                          return ListView.builder(
                            itemCount: documents.length,
                            itemBuilder: (context, i) {
                              return Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(70, 7, 70, 7),
                                child: ListTile(
                                  visualDensity:
                                      const VisualDensity(vertical: -3),
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(width: 2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  dense: true,
                                  tileColor: Colors.white10,
                                  leading: Text(
                                    (i + 1).toString(),
                                    style:
                                        const TextStyle(color: Colors.white38),
                                  ),
                                  title: Text(documents[i]["name"].toString()),
                                  subtitle: Text('${documents[i]["alc"]} ml'),
                                ),
                              );
                            },
                          );
                        }

                        return const Center(
                          child: SizedBox(
                            height: 60,
                            width: 60,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    )
                  : SafeArea(
                      child: Column(
                        children: [
                          const SizedBox(height: 50),
                          const Text(
                            "To reach and contribute to leaderboard please sign up",
                            style:
                                TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              decoration: const InputDecoration(
                                labelStyle: TextStyle(color: Colors.white60),
                                hintText: "username",
                                hintStyle: TextStyle(color: Colors.white24),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white24),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white38),
                                ),
                              ),
                              controller: nameController,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () =>
                                (nameController.text != "") ? signUp() : null,
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                backgroundColor: Colors.white),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                        ],
                      ),
                    )),
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
                  Positioned(
                    top: 130,
                    right: 0,
                    child: IconButton(
                      onPressed: () {
                        box.remove("userId");
                        box.remove("userLoggedIn");
                        box.remove("name");
                      },
                      icon: const Icon(Icons.delete),
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                    Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                          mainAxisAlignment: MainAxisAlignment.center,
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