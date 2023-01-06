import 'dart:math';
import 'dart:ui';
import 'package:chrashed/calculations_page.dart';
import 'package:chrashed/leaderboard_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'services.dart';
import 'booze_page.dart';

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

final PageController pageController = PageController(initialPage: 1);
final TextEditingController nameController = TextEditingController();

List<dynamic> boozes = box.read("boozes") ?? [];

String userId = box.read("userId") ?? Random().nextInt(1000000).toString();

int rowCount = box.read("rowCount") ?? 4;
int pageState = 1;

double totalAlc = box.read("totalAlc") ?? 0;
dynamic size;

Map<String, double> alcList = {};

CollectionReference leadersColl =
    FirebaseFirestore.instance.collection('leaders');

class _MainState extends State<Main> {
  @override
  void initState() {
    getAlcohols();

    super.initState();
  }

  Widget boozeButton(imageUrl, text, alc) {
    return InkWell(
      onTap: () {
        Clipboard.setData(const ClipboardData());
        HapticFeedback.heavyImpact();

        boozes.add({
          "imageUrl": "assets/$imageUrl.png",
          "scale": 1,
        });
        setState(() {});

        totalAlc += alc;
        box.write("boozes", boozes);
        box.write("totalAlc", totalAlc);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            "assets/$imageUrl.png",
            width: size.width / 4.5 ?? 2,
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

  void confirmDelete(String docRef) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 2,
            sigmaY: 2,
          ),
          child: AlertDialog(
            backgroundColor: const Color.fromARGB(255, 12, 12, 12),
            title: const Text(
              "Delete user and remove all alcohols?",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text(
                  "No",
                  style: TextStyle(color: Colors.white38),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context, true);
                    box.remove("userId");
                    box.remove("userLoggedIn");
                    box.remove("name");
                    box.remove("boozes");
                    box.remove("totalAlc");
                    totalAlc = 0;
                    boozes.clear();
                    leadersColl.doc(docRef).delete();
                  });
                },
                child: const Text(
                  "Yes",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        );
      },
    );
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
                              boozeButton("can_beer", "Can beer", 17.75),
                              boozeButton("bottle_beer", "Bottle beer", 17.75),
                              boozeButton("mug_beer", "Mug beer", 26),
                              boozeButton("hard_beer", "7.5% beer", 37.5),
                              boozeButton("small_shot", "1.5 oz shot", 16),
                              boozeButton("big_shot", "2 oz shot", 20),
                              boozeButton("champagne", "Champagne", 15),
                              boozeButton("wine_glass", "Wine", 18),
                              boozeButton("whiskey_glass", "Whiskey", 23.6),
                              boozeButton("mojito", "Mojito", 23.65),
                              boozeButton("margarita", "Margarita", 26.55),
                              boozeButton("martini", "Martini", 27.25),
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
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomAppBar(
        elevation: 100,
        color: Colors.black,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          height: size.height / 13,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                iconSize: size.height / 35,
                splashRadius: size.height / 30,
                onPressed: () {
                  pageState = 0;
                  setState(() {});
                  if (box.read("userLoggedIn") ?? false) {
                    setLeaders();
                    setState(() {});
                  }
                  pageController.animateToPage(0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.ease);
                },
                icon: const Icon(Icons.leaderboard),
                color: pageState == 0 ? Colors.white : Colors.white30,
              ),
              IconButton(
                iconSize: size.height / 30,
                splashRadius: size.height / 30,
                onPressed: () {
                  pageState = 1;
                  showMenu();
                  setState(() {});
                  pageController.animateToPage(1,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.ease);
                },
                icon: const Icon(Icons.add),
                color: pageState == 1 ? Colors.white : Colors.white30,
              ),
              IconButton(
                iconSize: size.height / 35,
                splashRadius: size.height / 30,
                onPressed: () {
                  pageState = 2;
                  getAlcohols();
                  setState(() {});
                  pageController.animateToPage(2,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.ease);
                },
                icon: Icon(
                  Icons.notes,
                  color: pageState == 2 ? Colors.white : Colors.white30,
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
              LeaderboardPage(
                confirmDelete: confirmDelete,
              ),
              BoozePage(showMenuFunc: showMenu),
              const CalculationsPage(),
            ],
          ),
        ],
      ),
    );
  }
}
