import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finstagram/style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MaterialApp(
      theme: style.theme,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tab = 0;
  var dataURL = '';
  var data = [];
  var userImage;
  var userContent;

  saveData() async {
    var storage = await SharedPreferences.getInstance();
    storage.setString('name', 'John');
  }

  addMyData() {
    var myData = {
      'id': data.length,
      'image': userImage,
      'likes': 5,
      'date': 'July 25',
      'content': userContent,
      'liked': false,
      'user': 'John Kim',
    };
    setState(() {
      data.insert(0, myData);
    });
  }

  setUserContent(content) {
    userContent = content;
  }

  getData(url) async {
    var result = await http.get(Uri.parse(url));

    if (result.statusCode == 200) {
      setState(() {
        data = jsonDecode(result.body);
      });
    } else {
      return Text('Data could not be retrieved');
    }
  }

  @override
  void initState() {
    super.initState();
    getData(dataURL);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Finstagram',
          style: GoogleFonts.rockSalt(),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              var picker = ImagePicker();
              var image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() {
                  userImage = File(image.path);
                });
              } else {
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Upload(
                      userImage: userImage,
                      setUserContent: setUserContent,
                      addMyData: addMyData,
                    );
                  },
                ),
              );
            },
            icon: Icon(Icons.add_box_outlined),
            iconSize: 30,
          ),
          Padding(padding: EdgeInsetsDirectional.only(end: 10))
        ],
      ),
      body: [Home(data: data), Text('Shopping Page')][tab],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'shopping',
          )
        ],
        onTap: (i) {
          setState(() {
            tab = i;
          });
        },
      ),
    );
  }
}

class Upload extends StatelessWidget {
  const Upload({Key? key, this.userImage, this.setUserContent, this.addMyData})
      : super(key: key);

  final userImage;
  final setUserContent;
  final addMyData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.chevron_left,
                color: Colors.black,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              addMyData();
              Navigator.pop(context);
            },
            icon: Icon(Icons.send),
          )
        ],
      ),
      body: ListView(
        children: [
          Image.file(userImage),
          Text('Image Upload Screen'),
          TextField(
            onChanged: (value) {
              setUserContent(value);
            },
          )
        ],
      ),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key? key, this.data}) : super(key: key);

  var data;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var posts = 3;
  var scroll = ScrollController();
  var dataURL = '';

  getMore(dataURL) async {
    var result = await http.get(Uri.parse(dataURL));
    setState(() {
      widget.data = [...widget.data, jsonDecode(result.body)];
    });
  }

  @override
  void initState() {
    super.initState();
    scroll.addListener(() {
      if (scroll.position.pixels == scroll.position.maxScrollExtent) {
        getMore(dataURL);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isNotEmpty) {
      return ListView.builder(
        controller: scroll,
        itemCount: widget.data.length,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: 30,
              ),
              // Image.asset('assets/images/pic${data.length - index}.png'),
              widget.data[index]['image'].runtimeType == String
                  ? Image.network(widget.data[index]['image'])
                  : Image.file(widget.data[index]['image']),

              Text('Likes: ${widget.data[index]['likes']}'),
              Text('Author: ${widget.data[index]['user']}'),
              Text(widget.data[index]['content']),
            ],
          );
        },
      );
    } else {
      return Center(
        child: Text('Loading'),
      );
    }
  }
}
