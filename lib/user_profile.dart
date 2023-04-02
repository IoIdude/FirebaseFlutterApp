import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class UserProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final user = FirebaseAuth.instance.currentUser!;
  PlatformFile? file = null;

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

  GlobalKey<FormState> _key = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _middleNameController = TextEditingController();
  late Map<String, dynamic> imageData = {};
  bool isObscure = true;
  bool _isValid = true;

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    String id = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
        body: Column(
      // ignore: sort_child_properties_last
      children: [
        FutureBuilder<DocumentSnapshot>(
          future: users.doc(id).get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text("Something went wrong");
            }

            if (snapshot.hasData && !snapshot.data!.exists) {
              return Text("Document does not exist");
            }

            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
              _lastNameController.text = data['last_name'];
              _firstNameController.text = data['first_name'];
              _middleNameController.text = data['middle_name'];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Form(
                    key: _key,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Изменение профиля",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24),
                        ),

                        //last name
                        Padding(
                          padding:
                              EdgeInsets.only(left: 100, right: 100, top: 15),
                          child: TextFormField(
                            controller: _lastNameController,
                            validator: (value) {
                              if (!_isValid) {
                                return null;
                              }
                              if (value!.isEmpty) {
                                return 'Поле пустое';
                              }
                              if (value.length < 1) {
                                return 'Фамилия должна содержать не менее 1 символа';
                              }
                              return null;
                            },
                            maxLength: 255,
                            decoration: const InputDecoration(
                              labelText: 'Фамилия',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),

                        //first name
                        Padding(
                          padding:
                              EdgeInsets.only(left: 100, right: 100, top: 15),
                          child: TextFormField(
                            controller: _firstNameController,
                            validator: (value) {
                              if (!_isValid) {
                                return null;
                              }
                              if (value!.isEmpty) {
                                return 'Поле пустое';
                              }
                              if (value.length < 1) {
                                return 'Имя должно содержать не менее 1 символа';
                              }
                              return null;
                            },
                            maxLength: 255,
                            decoration: const InputDecoration(
                              labelText: 'Имя',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        //middle name
                        Padding(
                          padding:
                              EdgeInsets.only(left: 100, right: 100, top: 15),
                          child: TextFormField(
                            controller: _middleNameController,
                            validator: (value) {
                              if (!_isValid) {
                                return null;
                              }
                              if (value!.isEmpty) {
                                return 'Поле пустое';
                              }
                              if (value.length < 1) {
                                return 'Отчество должно содержать не менее 1 символа';
                              }
                              return null;
                            },
                            maxLength: 255,
                            decoration: const InputDecoration(
                              labelText: 'Отчество',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Column(children: [
                            FutureBuilder<String>(
                                future: loadImage(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> image) {
                                  if (image.hasData && file == null) {
                                    return Container(
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
                                            )));
                                  } else if (file != null) {
                                    return Container(
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
                                            child: Image.memory(
                                              file!.bytes!,
                                              fit: BoxFit.scaleDown,
                                            ))); // placeholder
                                  } else {
                                    return new Container();
                                  }
                                })
                          ]),
                        ),
                        Padding(
                            padding:
                                EdgeInsets.only(left: 350, right: 350, top: 10),
                            child: Container(
                              width: 50,
                              child: ElevatedButton(
                                child: Text("Загрузить фото профиля"),
                                onPressed: () => {_pickFile()},
                              ),
                            )),
                        Padding(
                            padding:
                                EdgeInsets.only(left: 350, right: 350, top: 50),
                            child: Container(
                              width: 50,
                              child: ElevatedButton(
                                child: Text("Сохранить изменения"),
                                onPressed: () => {
                                  _isValid = true,
                                  if (_key.currentState!.validate())
                                    {saveChanges()}
                                },
                              ),
                            )),
                        Padding(
                            padding:
                                EdgeInsets.only(left: 350, right: 350, top: 50),
                            child: ElevatedButton(
                              child: Text("Отмена"),
                              onPressed: () => {
                                _isValid = false,
                                _key.currentState!.validate(),
                                Navigator.pushNamed(context, 'home'),
                              },
                            ))
                      ],
                    ),
                  ),
                ],
              );
            }

            return const Center(
              child: Text("Загрузка..."),
            );
          },
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    ));
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      file = result.files.first;
      await FirebaseStorage.instance
          .ref('uploads/${file!.name}')
          .putData(file!.bytes!);

      imageData = {
        "size": file!.size,
        "file_extensions": file!.extension!,
        "name": file!.name,
        'storage_path': 'uploads/${file!.name}'
      };
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Изображение успешно загружено"),
        ),
      );
    } else {}
  }

  Future saveChanges() async {
    String id = FirebaseAuth.instance.currentUser!.uid;

    if (imageData == null) {
      var data = ModalRoute.of(context)!.settings.arguments;

      if (data != null) {
        Map<String, dynamic> values = data as Map<String, dynamic>;
        DocumentSnapshot snapshot = values['user'];

        imageData = values['profile_image'];
      }
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .set({
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'middle_name': _middleNameController.text.trim(),
          'profile_image': imageData
        })
        .then((value) => {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Данные сохранены"),
                ),
              ),
              Navigator.pushNamed(context, 'home'),
            })
        .onError((error, stackTrace) => {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Не удалось сохранить изменения"),
                ),
              )
            });
  }
}
