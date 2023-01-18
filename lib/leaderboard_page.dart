// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'services.dart';
import 'package:country_picker/country_picker.dart';

class LeaderboardPage extends StatefulWidget {
  final confirmDelete;

  const LeaderboardPage({Key? key, this.confirmDelete}) : super(key: key);

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  @override
  Widget build(BuildContext context) {
    return (box.read("userLoggedIn") ?? false
        ? FutureBuilder<QuerySnapshot>(
            future:
                leadersColl.limit(20).orderBy('alc', descending: true).get(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("Something went wrong");
              }

              if (snapshot.connectionState == ConnectionState.done) {
                final List<DocumentSnapshot> documents = snapshot.data!.docs;
                return RefreshIndicator(
                  color: const Color.fromARGB(255, 100, 100, 100),
                  backgroundColor: const Color.fromARGB(255, 17, 17, 17),
                  onRefresh: () {
                    setState(() {});
                    return Future.delayed(const Duration(seconds: 0));
                  },
                  child: ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: size.width / 2,
                              height: size.height / 13,
                              child: ListTile(
                                visualDensity:
                                    const VisualDensity(vertical: -3),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(width: 2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                dense: true,
                                tileColor:
                                    (box.read("userId") == documents[i]["id"])
                                        ? Colors.white10
                                        : const Color.fromARGB(255, 12, 12, 12),
                                leading: Text(
                                  (i + 1).toString(),
                                  style: const TextStyle(color: Colors.white38),
                                ),
                                title: Text(documents[i]["name"].toString()),
                                subtitle: Text(
                                    '${double.parse((documents[i]["alc"]).toStringAsFixed(2))} ml'),
                                trailing: SizedBox(
                                  width: 20,
                                  child: Image.asset(
                                      'icons/flags/png/${documents[i]["countryCode"]}.png',
                                      package: 'country_icons'),
                                ),
                              ),
                            ),
                            (box.read("userId") == documents[i]["id"])
                                ? SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.all(0),
                                          backgroundColor: Colors.transparent),
                                      onPressed: () {
                                        widget
                                            .confirmDelete(documents[i]["id"]);
                                      },
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.white24,
                                      ),
                                    ),
                                  )
                                : Text("")
                          ],
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
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                    IconButton(
                      splashRadius: 0.1,
                      icon: Image.asset('icons/flags/png/$countryCode.png',
                          package: 'country_icons'),
                      onPressed: () {
                        showCountryPicker(
                          countryListTheme: CountryListThemeData(
                            borderRadius: BorderRadius.all(Radius.zero),
                            inputDecoration: InputDecoration(
                              labelStyle: TextStyle(color: Colors.white60),
                              hintText: "Country",
                              hintStyle: TextStyle(color: Colors.white24),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white24),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white38),
                              ),
                            ),
                            bottomSheetHeight: 500,
                            backgroundColor: Color.fromARGB(255, 16, 16, 16),
                            textStyle: TextStyle(color: Colors.white),
                          ),
                          context: context,
                          showPhoneCode: false,
                          onSelect: (Country country) {
                            countryCode = country.countryCode.toLowerCase();
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => (nameController.text != "")
                      ? {
                          box.write("userLoggedIn", true),
                          box.write("name", nameController.text),
                          box.write("userId", userId),
                          setLeaders().then((_) {
                            setState(() {});
                          }),
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      backgroundColor: Colors.white),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ));
  }
}
