import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class IslandEntry {
 String atoll;
 String island;
 int islandId;
 int categoryId;
 int minutes;

  IslandEntry({this.atoll ,this.island, this.islandId, this.categoryId, this.minutes});

  IslandEntry.fromMap(Map<String, dynamic> map) {  
        atoll = map['Atoll'];
        island = map['Island'];
        categoryId =  map['CategoryId'];
        islandId = map['IslandId'];
        minutes = map['Minutes'];
 }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Atoll'] = this.atoll;
    data['Island'] = this.island;
    data['CategoryId'] = this.categoryId;
    data['IslandId'] = this.islandId;
    data['Minutes'] = this.minutes;
    return data;
  }
}


//need to improve this method to use aservice for prefrences
class PrefsHelper {
  


  Future<String> fromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final islandEntryString =  await prefs.get("IslandEntry") ?? "not_set";


    return islandEntryString;

  }  
  
  
  toPrefs(IslandEntry islandDetails) async{
    final prefs = await SharedPreferences.getInstance();
    var jsonEntry = islandDetails.toJson();
    prefs.setBool("is_set", true);
    prefs.setString("IslandEntry", json.encode(jsonEntry));
  }

}


//efforts to actually use datetime objects for prayertimes so it is will be easier  to add nitification support
class PrayerDateTimes{
  DateTime fajuru;
  DateTime sunrise;
  DateTime dhuhr;
  DateTime asr;
  DateTime maghrib;
  DateTime isha;

  PrayerDateTimes(this.fajuru,this.sunrise,this.dhuhr,this.asr,this.maghrib,this.isha);

  PrayerDateTimes.fromMap(DateTime date,Map<String, dynamic> map,int minutes){
    print(map["Fajuru"]);
    print(minutes);
    fajuru = getPrayerDateTime(date,map["Fajuru"],minutes);
    sunrise = getPrayerDateTime(date,map["Sunrise"],minutes);
    dhuhr = getPrayerDateTime(date,map["Dhuhr"],minutes);
    asr = getPrayerDateTime(date,map["Asr"],minutes);
    maghrib = getPrayerDateTime(date,map["Maghrib"],minutes);
    isha = getPrayerDateTime(date,map["Isha"],minutes);
  }

  DateTime getPrayerDateTime(DateTime date,dayMinutes,int adjustMinutes){
      final int adjustedDayMins = dayMinutes + adjustMinutes;
      final int hour = adjustedDayMins ~/ 60;
      final int minutes = adjustedDayMins % 60;

      final prayerTime = DateTime(date.year,date.month,date.day,hour,minutes);

      return prayerTime;

  }


}







class NamaadhuTimeProvider {
 static Database _db; 
 
 final String dbPath = join("assets","salat.db");   
 
 Future<Database> get db async {    
   if (_db != null) {    
     return _db;    
   }    
   _db = await initDatabase();    
   return _db;    
 }    
     

 initDatabase() async {   
   var databasesPath = await getDatabasesPath();
var path = join(databasesPath, "salat.db");

// Check if the database exists
var exists = await databaseExists(path);

if (!exists) {
  // Should happen only the first time you launch your application
  print("Creating new copy from asset");

  // Make sure the parent directory exists
  try {
    await Directory(dirname(path)).create(recursive: true);
  } catch (_) {}
    
  // Copy from asset
  ByteData data = await rootBundle.load(join("assets", "salat.db"));
  List<int> bytes =
  data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  
  // Write and flush the bytes written
  await File(path).writeAsBytes(bytes, flush: true);

} else {
  print("Opening existing database");
}
// open the database
var db = await openDatabase(path, readOnly: true);    
  
  
  return db;    
 } 


  
  Future<List<IslandEntry>> listIslands() async {
    var dbClient =  await db; 

    final List<Map<String, dynamic>> maps = await dbClient.query('Island');

    final islandList = List.generate((maps.length), (i) {
      print(IslandEntry.fromMap(maps[i]).island);
      return IslandEntry.fromMap(maps[i]);

    });
    
    return islandList;
  }

//this takes date and island Detail as param and returns prayertimes as result
  Future<PrayerDateTimes> getPrayerTimes(DateTime date, IslandEntry islandDetail) async{
    int islandCategory = islandDetail.categoryId;
    int adjustMins = islandDetail.minutes; 
    
    var dbClient =  await db;

    //get day number of year from date 
    final diff = date.difference(new DateTime(date.year, 1, 1, 0, 0));
    final diffInDays = diff.inDays - 1;

  //query db with calculated data
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'PrayerTimes',
     columns:['Fajuru,Sunrise,Dhuhr,Asr,Maghrib,Isha'],
     where:'"CategoryId"=? and "Date"=?',
     whereArgs: [islandCategory,diffInDays]);

     return PrayerDateTimes.fromMap(date, maps[0], adjustMins);



  }
  
  
  
  
  
  
  }






