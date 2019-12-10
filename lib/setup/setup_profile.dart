import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:preschool/screens/main_screen.dart';
import 'package:preschool/setup/setup_children.dart';

class SetupProfilePage extends StatefulWidget {
  @override
  const SetupProfilePage({this.onSignedOut});
  final VoidCallback onSignedOut;
  _SetupProfilePageState createState() => _SetupProfilePageState(onSignedOut);
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  _SetupProfilePageState(this.onSignedOut);
  VoidCallback onSignedOut;
  FirebaseUser user;
  File _image;
  String _username, _fullname, _phonenumber, _address, _profileimage, _role;
  final _addressController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phonenumberController = TextEditingController();
  List<String> _myclass = List<String>();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _usernameController.dispose();
    _fullnameController.dispose();
    _phonenumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  getCurrentUser() async {
    user = await FirebaseAuth.instance.currentUser();
    await Firestore.instance
        .collection('Users')
        .document(user.uid)
        .get()
        .then((DocumentSnapshot ds) {
      _role = ds.data['role'];
    });
  }

  void initState() {
    getCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future getImage() async {
      var image = await ImagePicker.pickImage(
          source: ImageSource.gallery, maxWidth: 960, maxHeight: 675);
      setState(() {
        _image = image;
      });
    }

    Future setupUser(BuildContext context) async {
      String fileName = basename(_image.path);
      StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('ProfileImage').child(fileName);
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      setState(() {
        print("Profile Picture uploaded");
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Profile Picture Uploaded')));
      });
      _username = _usernameController.text;
      _fullname = _fullnameController.text;
      _phonenumber = _phonenumberController.text;
      _address = _addressController.text;
      _profileimage = fileName;
      Firestore.instance.runTransaction((transaction) async {
        await transaction
            .update(Firestore.instance.collection('Users').document(user.uid), {
          "username": _username,
          "fullname": _fullname,
          "phonenumber": _phonenumber,
          "address": _address,
          "profileimage": _profileimage
        });
      });
      if (_role == 'teacher') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MainScreen(onSignedOut: onSignedOut)));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    SetupChildrenPage(onSignedOut: onSignedOut)));
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(FontAwesomeIcons.arrowLeft),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text('Thiết lập đăng nhập lần đầu'),
      ),
      body: Builder(
        builder: (context) => Container(
          child: new SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        radius: 100,
                        backgroundColor: Color(0xff476cfb),
                        child: ClipOval(
                          child: new SizedBox(
                            width: 195,
                            height: 195,
                            child: (_image != null)
                                ? Image.file(
                                    _image,
                                    fit: BoxFit.fill,
                                  )
                                : Image.network(
                                    "https://images.unsplash.com/photo-1502164980785-f8aa41d53611?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 60.0),
                      child: IconButton(
                        icon: Icon(
                          FontAwesomeIcons.camera,
                          size: 30.0,
                        ),
                        onPressed: () {
                          getImage();
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _usernameController,
                          decoration:
                              InputDecoration(hintText: 'Tên người dùng'),
                        ),
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _fullnameController,
                          decoration:
                              InputDecoration(hintText: 'Họ và tên đầy đủ'),
                        ),
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _phonenumberController,
                          decoration:
                              InputDecoration(hintText: 'Số điện thoại'),
                        ),
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _addressController,
                          decoration: InputDecoration(hintText: 'Địa chỉ'),
                        ),
                      ),
                    ]),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      color: Color(0xff476cfb),
                      onPressed: () {
                        setupUser(context);
                      },
                      elevation: 4.0,
                      splashColor: Colors.blueGrey,
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}