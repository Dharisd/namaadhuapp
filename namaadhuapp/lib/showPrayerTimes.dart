import 'dart:async';
import 'package:flutter/material.dart';
import 'package:namaadhuapp/namaadhuTime.dart';
import 'main.dart';
import 'package:intl/intl.dart';
import 'size_config.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PrayerTimes extends StatefulWidget {
  PrayerTimes({Key key, @required this.islandDetails}) : super(key: key);

  final IslandEntry islandDetails;
  final DateTime date = DateTime.now();
  final String currentDate =
      new DateFormat("dd-MM-yyyy").format(DateTime.now());

  @override
  _PrayerTimesState createState() => _PrayerTimesState(islandDetails);
}

class _PrayerTimesState extends State<PrayerTimes> {
  IslandEntry islandDetails;
  NamaadhuTimeProvider dbHelper;
  Future<PrayerDateTimes> islandTimes;
  String islandName;

  _PrayerTimesState(IslandEntry islandDetails) {
    this.islandDetails = islandDetails;
  }

  @override
  void initState() {
    super.initState();
    final DateTime date = DateTime.now();
    dbHelper = NamaadhuTimeProvider();
    islandTimes = dbHelper.getPrayerTimes(date, islandDetails);
    islandName = islandDetails.atoll + "." + islandDetails.island;

    print(islandTimes);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return new Scaffold(

        //hit Ctrl+space in intellij to know what are the options you can use in flutter widgets
        body: Center(
      child: FutureBuilder<PrayerDateTimes>(
        future: islandTimes,
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? PrayerTimesView(
                  islandName: islandName, islandTimes: snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
    ));
  }
}

class PrayerTimesView extends StatelessWidget {
  final PrayerDateTimes islandTimes;
  final String islandName;

  PrayerTimesView(
      {Key key, @required this.islandTimes, @required this.islandName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (Container(
          margin: EdgeInsets.all(1),
          alignment: Alignment.center,
          child: Center(
              child: SafeArea(
                  child: Column(children: <Widget>[
            _changeLocation(context),
            _hero(islandName,
                DateFormat.yMMMMEEEEd().format(islandTimes.fajuru), context),
            SizedBox(height: SizeConfig.blockSizeVertical * 3),
            _prayerCard(islandTimes, context)
          ]))))),
    );
  }
}



_changeLocation(context) {
  return Container(
      child: Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisAlignment: MainAxisAlignment.end,
    children: <Widget>[
      IconButton(
        icon: Icon(Icons.location_on),
        tooltip: 'Change location',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IslandSelectPage(),
            ),
          );
        },
      ),
    ],
  ));
}



_hero(islandName, date, context) {
  return Container(
      height: SizeConfig.blockSizeVertical * 20,
      width: SizeConfig.blockSizeHorizontal * 90,
      decoration: new BoxDecoration(
        boxShadow: [
          new BoxShadow(
            color: Color(0xFFC7C8D5),
            blurRadius: 30.0,
            spreadRadius: 5.0,
          ),
        ],
      ),
      child: Card(
          color: Color(0xFF04D193),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 0,
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  AutoSizeText(
                    date,
                    style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 6.4,
                        color: Colors.white.withOpacity(0.9),
                        fontFamily: "roboto"),
                  ),
                  SizedBox(height: SizeConfig.blockSizeHorizontal * 4.5),
                  AutoSizeText(islandName,
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 7.1,
                        color: Colors.white.withOpacity(0.9),
                      )),
                ],
              ))));
}

_prayerCard(islandTimes, context) {
  return (Container(
      width: SizeConfig.blockSizeHorizontal * 80,
      child: Column(
        children: <Widget>[
          _prayerEntry("ފަޖުރު", DateFormat.Hm().format(islandTimes.fajuru)),
          _prayerEntry("އިރުއަރާ", DateFormat.Hm().format(islandTimes.sunrise)),
          _prayerEntry("މެންދުރު", DateFormat.Hm().format(islandTimes.dhuhr)),
          _prayerEntry("ޢަސްރު", DateFormat.Hm().format(islandTimes.asr)),
          _prayerEntry("މަޣްރިބް", DateFormat.Hm().format(islandTimes.maghrib)),
          _prayerEntry("އިޝާ", DateFormat.Hm().format(islandTimes.isha)),
        ],
      )));
}



_prayerEntry(prayerName, formattedtime) {
  return SizedBox(
      height: SizeConfig.blockSizeVertical * 10,
      width: SizeConfig.blockSizeHorizontal * 75,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ListTile(
                title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                AutoSizeText(formattedtime,
                    style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 5.1,
                        fontFamily: "roboto",
                        color: Color(0xFF61707D))),
                Text(prayerName,
                    style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 5.3,
                        fontFamily: "Dhivehi",
                        color: Color(0xFF0C1B33))),
              ],
            )),
          ],
        ),
      ));
}
