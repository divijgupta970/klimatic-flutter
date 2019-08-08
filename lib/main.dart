import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:charcode/charcode.dart' as ascii;
import 'package:klimatic/utils/widgetClass.dart';
import 'package:flare_flutter/flare_actor.dart';

//apikey dd82e8fd95a26848525ee6c1e08e7342
void main() {
  runApp(MaterialApp(
    title: "Klimatic",
    home: Klimatic(),
  ));
}

class Klimatic extends StatefulWidget {
  @override
  _KlimaticState createState() => _KlimaticState();
}

class _KlimaticState extends State<Klimatic> {
  String cityFromSecondScreen;
  widgetClass defaultClass = widgetClass(
      Text(
        "City Not Found",
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w200, fontSize: 32.0),
      ),
      Container(),
      Container(),
      "none",
      "","empty","Stand");
  widgetClass widgets;

  _KlimaticState() {
    widgets = defaultClass;
  }

  Future navigate(BuildContext context) async {
    Map results = await Navigator.of(context)
        .push(MaterialPageRoute<Map>(builder: (BuildContext context) {
      return SearchScreen();
    }));
    if (results != null && results.containsKey("cityName")) {
      cityFromSecondScreen = results["cityName"];
      getAllWidgets(cityFromSecondScreen);
    }
  }

  void getAllWidgets(String cityEntered) async {
    Map data = await getJson(cityEntered);
    if (data != null) {
      if (data.containsKey("main")) {
        Text temp = Text(
          ((data["main"]["temp"] - 273.15)).toStringAsFixed(0) +
              String.fromCharCode(ascii.$deg) +
              "C",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w200, fontSize: 64.0),
        );
        Text min_temp = Text(
          "Min: " +
              (data["main"]["temp_min"] - 273.15).toStringAsFixed(0) +
              String.fromCharCode(ascii.$deg) +
              "C",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w200),
        );
        Text max_temp = Text(
          "Max: " +
              (data["main"]["temp_max"] - 273.15).toStringAsFixed(0) +
              String.fromCharCode(ascii.$deg) +
              "C",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w200),
        );
        List weather = data["weather"];
        String desc = weather[0]["main"];

        setState(() {
          widgets = widgetClass(temp, min_temp, max_temp, desc, data["name"],weather[0]["description"],"Wave");
        });
      } else {
        setState(() {
          widgets = defaultClass;
        });
      }
    }
  }

  @override
  void initState() {
    getAllWidgets("Jammu");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          "Klimatic",
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        backgroundColor: Color.fromARGB(255, 48, 50, 107),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: new Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              navigate(context);
            },
          )
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          /*Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("images/back.jpg"), fit: BoxFit.cover)),
          ),*/
          Container(
            decoration: BoxDecoration(color: Color.fromARGB(255, 48, 50, 107)),
          ),
          FlareActor("images/minion.flr",
          animation: widgets.animationType,
          fit: BoxFit.contain,
          alignment: Alignment.center,),
          Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.fromLTRB(0.0, 16.0, 16.0, 0.0),
            child: Text(
              widgets.cityName,
              style: TextStyle(color: Colors.white, fontSize: 28.0),
            ),
          ),
          Container(
            alignment: Alignment.bottomLeft,
            margin: EdgeInsets.fromLTRB(24.0, 0, 0, 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                widgets.temp,
                widgets.min_temp,
                widgets.max_temp
              ],
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.fromLTRB(24,24,0,0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  iconSelection(widgets.image_type),
                  color: Colors.white,
                  scale: 1.35,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,16, 0, 0),
                  child: Text(
                    setImageDesc(widgets.imageDesc),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w300),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  String iconSelection(String type){
    switch(type){
      case "Thunderstorm":return "images/thunderstorm.png";
      break;
      case "Drizzle":return "images/drizzle.png";
      break;
      case "Rain":return "images/rain.png";
      break;
      case "Snow":return "images/snow.png";
      break;
      case "Clear":return "images/clear.png";
      break;
      case "Clouds":return "images/clouds.png";
      break;
      case "none":return "images/error.png";
      break;
      default: return "images/other.png";
    }
  }

  Future<Map> getJson(String city) async {
    String apiUrl =
        "http://api.openweathermap.org/data/2.5/weather?q=$city&appid=dd82e8fd95a26848525ee6c1e08e7342";
    try {
      http.Response response = await http.get(apiUrl);
      return json.decode(response.body);
    } catch (e) {
      errorState();
    }
  }

  void errorState() {
    setState(() {
      widgets = widgetClass(
          Row(
            children: <Widget>[
              Text(
                "No Internet connection",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w200,
                    fontSize: 24.0),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                child: Material(
                  child: InkWell(
                    child: Container(
                        padding: EdgeInsets.all(2.0),
                        child: Icon(
                          Icons.refresh,
                          color: Colors.white,
                        )),
                    onTap: () {
                      getAllWidgets(cityFromSecondScreen == null
                          ? "Jammu"
                          : cityFromSecondScreen);
                    },
                  ),
                  color: Colors.transparent,
                ),
              )
            ],
          ),
          Container(),
          Container(),
          "none",
          "","empty","Jump");
    });
  }

  String setImageDesc(String imageDesc) {
    return imageDesc=="empty"?"":imageDesc[0].toUpperCase()+imageDesc.substring(1);
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var searchFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          "Change City",
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        backgroundColor: Color.fromARGB(255, 48, 50, 107),
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          /*Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("images/city2.jpg"), fit: BoxFit.cover),
            ),
          ),*/
          Container(
            decoration: BoxDecoration(color: Color.fromARGB(255, 48, 50, 107)),
          ),
          FlareActor("images/minion.flr",
            animation: "Dance",
            fit: BoxFit.contain,
            alignment: Alignment.center,),
          Container(
            alignment: Alignment.topCenter,
            margin: EdgeInsets.fromLTRB(16, 32, 16, 0),
            child: TextField(
              style: TextStyle(
                  color: Color.fromARGB(255, 255, 210, 73), fontSize: 24.0),
              cursorColor: Colors.white,
              controller: searchFieldController,
              decoration: InputDecoration(
                labelText: "City Name",
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                suffixIcon: IconButton(
                    icon: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(
                          context, {'cityName': searchFieldController.text});
                    }),
              ),
            ),
          )
        ],
      ),
    );
  }
}
