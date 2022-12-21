import 'dart:ffi';
import 'dart:math';
import 'dart:ui';
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

  String userId = box.read("userId") ?? Random().nextInt(1000000).toString();

  int rowCount = 4;
  int pageState = 1;

  double totalAlc = box.read("totalAlc") ?? 0;

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
    });
    totalAlc += alc;
    box.write("boozes", boozes);
    box.write("totalAlc", totalAlc);
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

  Future<void> setLeaders() async {
    try {
      final DocumentSnapshot snapshot = await leadersColl.doc(userId).get();

      final Map data = snapshot.data() as Map;
      final double dbAlc = data["alc"].toDouble();

      if (dbAlc > totalAlc) {
        totalAlc = dbAlc;
      }
    } catch (e) {}

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

  Widget boozeButton(String imageUrl, String text, double alc) {
    return InkWell(
      onTap: () => addBooze("assets/$imageUrl.png", 1, alc),
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
    alcList["total"] = totalAlc;
    alcList["beers"] = totalAlc / 17.75;
    alcList["hard_beers"] = totalAlc / 37.5;
    alcList["small_shots"] = totalAlc / 16;
    alcList["big_shots"] = totalAlc / 20;
    alcList["wines"] = totalAlc / 18;
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
                              boozeButton("bottle_beer", "Bottle beer", 17.75),
                              boozeButton("can_beer", "Can beer", 17.75),
                              boozeButton("mug_beer", "Mug beer", 26),
                              boozeButton("hard_beer", "Hard beer", 37.5),
                              boozeButton("vodka", "Vodka", 129),
                              boozeButton("wine_glass", "Wine", 18),
                              boozeButton("small_shot", "Small shot", 16),
                              boozeButton("big_shot", "Big shot", 20),
                              boozeButton("whiskey", "Whiskey", 140),
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
        elevation: 100,
        color: Colors.black,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          height: 56.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  pageState = 0;
                  setState(() {});
                  if (box.read("userLoggedIn") ?? false) setLeaders();
                  pageController.animateToPage(0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.ease);
                },
                icon: const Icon(Icons.leaderboard),
                color: pageState == 0 ? Colors.white : Colors.white30,
              ),
              IconButton(
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
                          return RefreshIndicator(
                            color: Colors.black,
                            onRefresh: () {
                              setState(() {});
                              return Future.delayed(const Duration(seconds: 0));
                            },
                            child: ListView.builder(
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
                                    tileColor: (box.read("userId") ==
                                            documents[i]["id"])
                                        ? Colors.white10
                                        : const Color.fromARGB(255, 12, 12, 12),
                                    leading: Text(
                                      (i + 1).toString(),
                                      style: const TextStyle(
                                          color: Colors.white38),
                                    ),
                                    title:
                                        Text(documents[i]["name"].toString()),
                                    subtitle: Text('${documents[i]["alc"]} ml'),
                                    trailing: (box.read("userId") ==
                                            documents[i]["id"])
                                        ? IconButton(
                                            onPressed: () => confirmDelete(
                                                documents[i]["id"]),
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.white24,
                                            ),
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
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
                                  showMenu();
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
