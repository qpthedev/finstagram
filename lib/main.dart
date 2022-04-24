import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finstagram/style.dart' as style;

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
  var posts = 3;

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
            onPressed: () {},
            icon: Icon(Icons.add_box_outlined),
            iconSize: 30,
          ),
          Padding(padding: EdgeInsetsDirectional.only(end: 10))
        ],
      ),
      // body: [Text('Home'), Text('Shop')][tab],
      body: ListView.builder(
        itemCount: posts,
        itemBuilder: (context, index) {
          return PostItem(index: index);
        },
      ),
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

class PostItem extends StatelessWidget {
  PostItem({Key? key, this.index}) : super(key: key);

  var index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 500,
            child: Image.asset(
              'assets/images/pic${index + 1}.png',
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Likes'),
                Text('Author'),
                Text('Content'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
