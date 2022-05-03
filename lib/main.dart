import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finstagram/style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finstagram/notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:finstagram/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => Store(),
      child: MaterialApp(
        theme: style.theme,
        home: MyApp(),
      ),
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
    initNotification();
    getData(dataURL);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Text('+'),
        onPressed: () {
          showNotification2();
        },
      ),
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

              GestureDetector(
                child: Text(widget.data[index]['user']),
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, a1, a2) => Profile(),
                      transitionsBuilder: (context, a1, a2, child) =>
                          FadeTransition(opacity: a1, child: child),
                    ),
                  );
                },
              ),
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

class Store extends ChangeNotifier {
  var name = 'qpthedev';
  var followers = 0;
  var following = false;
  var profileurl = '';
  var data = [];

  changeFollowing() {
    if (following == false) {
      followers += 1;
      following = true;
      notifyListeners();
    } else if (following == true) {
      followers -= 1;
      following = false;
      notifyListeners();
    }
  }

  getData() async {
    var result = await http.get(Uri.parse(profileurl));
    data = jsonDecode(result.body);
    notifyListeners();
  }
}

class Profile extends StatefulWidget {
  const Profile({
    Key? key,
  }) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var data = [];

  @override
  void initState() {
    super.initState();
    context.read<Store>().getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<Store>().name),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ProfileHeader(),
          ),
          SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Image.network(context.watch<Store>().data[index]),
                );
              },
              childCount: context.watch<Store>().data.length,
            ),
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          )
        ],
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            // margin: EdgeInsets.all(20),
          ),
          Text('Follower: ${context.watch<Store>().followers}'),
          ElevatedButton(
            onPressed: () {
              context.read<Store>().changeFollowing();
            },
            child: Text(context.watch<Store>().following == true
                ? 'Unfollow'
                : 'Follow'),
          ),
        ],
      ),
    );
  }
}
