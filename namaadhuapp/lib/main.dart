import 'dart:convert';
import 'dart:developer';
import 'size_config.dart';
import 'package:flutter/material.dart';
import 'namaadhuTime.dart';
import 'showPrayerTimes.dart';

void main() => runApp(NamaadhuApp());

class NamaadhuApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Namaadhu App',
      theme: ThemeData(
        fontFamily: 'Dhivehi',
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF212121),
        accentColor: const Color(0xFF64ffda),
        canvasColor: const Color(0xFFF5F5FF),
      ),
      home: IslandSelectPage(title: 'launch'),
    );
  }
}

class IslandSelectPage extends StatefulWidget {
  IslandSelectPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _IslandSelectPageState createState() => _IslandSelectPageState();
}

class _IslandSelectPageState extends State<IslandSelectPage> {



  int _counter = 0;
  Future<List<IslandEntry>> islands;
  NamaadhuTimeProvider dbHelper;
  String _selectedIsland;
  PrefsHelper _prefshelper;

  @override
  void initState() {
    super.initState();
    _prefshelper = PrefsHelper();
    dbHelper = NamaadhuTimeProvider();
    islands = dbHelper.listIslands();

    print(islands);
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(


      body: 
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        FutureBuilder<String>(
          future: _prefshelper.fromPrefs(),
          builder: (context,snapshot){
            if (snapshot.hasData && widget.title =="launch"){
              //assuming that it will only have data when set
              //show the prayer screen
              if (snapshot.data != "not_set"){
                final islandDetails = IslandEntry.fromMap(jsonDecode(snapshot.data));
                return PrayerTimes(islandDetails: islandDetails);
              }
              else{
                return _islandSelectScreen(islands,_prefshelper,context);
              }

            }
            else if (snapshot.hasData && widget.title !="launch"){
              return _islandSelectScreen(islands,_prefshelper,context);

            }
            else{
              return Center(child: CircularProgressIndicator());
            }
          }
        )

 // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


_islandSelectScreen(islands,_prefshelper,context){
  return 
  Scaffold(
        appBar: AppBar(
        title: const Text('Select island',textAlign: TextAlign.right,),
      ),
  
  body:Center(
    child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<List<IslandEntry>>(
                future: islands,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var islandData = snapshot.data;

                    return new Expanded(
                        child: ListView.builder(
                            itemCount: islandData.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                  child: InkWell(
                                splashColor: Colors.blue.withAlpha(30),
                                onTap: () {
                                  _prefshelper.toPrefs(islandData[index]);
                                  Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                  builder: (context) => PrayerTimes(islandDetails: islandData[index]),
                                  ),
                                    );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                                  child: ListTile(
                                    title: Text(
                                      islandData[index].atoll +
                                          "." +
                                          islandData[index].island,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(fontSize: 25.0),
                                    ),
                                  ),
                                ),
                              ));
                            }));
                  }
                  if (snapshot.data == null || snapshot.data.length == 0) {
                    return Center(child: CircularProgressIndicator());
                  }
                  
                }),
          ],
        )));
}
