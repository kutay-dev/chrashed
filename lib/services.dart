import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

void addBooze(String imageUrl, double scale, double alc) {
  Clipboard.setData(const ClipboardData());
  HapticFeedback.heavyImpact();

  boozes.add({
    "imageUrl": imageUrl,
    "scale": scale,
  });

  totalAlc += alc;
  box.write("boozes", boozes);
  box.write("totalAlc", totalAlc);
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
}

void signUp() {
  box.write("userLoggedIn", true);
  box.write("name", nameController.text);
  box.write("userId", userId);
  setLeaders();
}

Map getAlcohols() {
  alcList["total"] = totalAlc;
  alcList["beers"] = totalAlc / 17.75;
  alcList["hard_beers"] = totalAlc / 37.5;
  alcList["small_shots"] = totalAlc / 16;
  alcList["big_shots"] = totalAlc / 20;
  alcList["wines"] = totalAlc / 18;
  alcList["martinis"] = totalAlc / 27.25;
  alcList["margaritas"] = totalAlc / 26.55;
  alcList["mojitos"] = totalAlc / 23.65;
  alcList["whiskeys"] = totalAlc / 23.6;
  return alcList;
}
