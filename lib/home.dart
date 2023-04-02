import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  late final userData;
  late final imageUrl;
  String name = "";
  String surname = "";
  String lastname = "";

  Future<String> getData() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    lastname = data['last_name'];
    name = data['first_name'];
    surname = data['middle_name'];

    return "";
  }

  Future<String> loadImage() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    var filePath = documentSnapshot['profile_image']['storage_path'];

    Reference ref = FirebaseStorage.instance.ref().child(filePath);

    var url = await ref.getDownloadURL();

    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Главное окно",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24),
              ),
              Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FutureBuilder<String>(
                      future: loadImage(),
                      builder:
                          (BuildContext context, AsyncSnapshot<String> image) {
                        if (image.hasData) {
                          return Column(children: [
                            Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.blue,
                                        width: 2,
                                        style: BorderStyle.solid)),
                                child: Container(
                                    width: 200,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: Image.network(
                                      image.data.toString(),
                                      fit: BoxFit.scaleDown,
                                    ))),
                          ]);
                        } else {
                          return new Container(); // placeholder
                        }
                      },
                    ),
                    Padding(
                        padding: EdgeInsets.all(30),
                        child: Column(children: [
                          FutureBuilder<String>(
                              future: getData(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> userdata) {
                                return Column(
                                  children: [
                                    Text('Фамилия ' + surname,
                                        style: TextStyle(fontSize: 15)),
                                    Text('Имя: ' + name,
                                        style: TextStyle(fontSize: 15)),
                                    Text('Отчество: ' + lastname,
                                        style: TextStyle(fontSize: 15)),
                                    Text('Почта: ' + user.email.toString(),
                                        style: TextStyle(fontSize: 15))
                                  ],
                                );
                              })
                        ])),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, 'profile');
                                },
                                child: Text("Изменить")),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Container(
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, 'posts');
                                  },
                                  child: Text("Лента")))
                        ]),
                  ],
                ),
              ),
            ]),
      ),
    ));
  }
}
