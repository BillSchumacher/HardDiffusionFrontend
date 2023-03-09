import 'package:args/args.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hard_diffusion/constants.dart';
import 'package:hard_diffusion/layout/landscape.dart';
import 'package:hard_diffusion/layout/portrait.dart';
import 'package:hard_diffusion/pages/login_page.dart';
import 'package:hard_diffusion/pages/splash_page.dart';
import 'package:hard_diffusion/state/auth.dart';
import 'package:hard_diffusion/state/text_to_image_form.dart';
import 'package:hard_diffusion/state/text_to_image_websocket.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? prefs;
String apiHost = "";
String websocketHost = "";
String imageHost = "";

var parser = ArgParser()
  ..addOption('apiHost', abbr: 'a', defaultsTo: 'localhost:8000')
  ..addFlag('secureApi', abbr: 's', defaultsTo: false)
  ..addOption('websocketHost', abbr: 'w', defaultsTo: 'localhost:8000')
  ..addFlag('secureWebsocket', abbr: 't', defaultsTo: false)
  ..addOption('imageHost', abbr: 'i', defaultsTo: 'localhost:8000')
  ..addFlag('secureImage', abbr: 'u', defaultsTo: false);

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  var results = parser.parse(args);
  apiHost = "http${results['secureApi'] ? 's' : ''}://${results['apiHost']}";
  websocketHost =
      "ws${results['secureWebsocket'] ? 's' : ''}://${results['websocketHost']}";
  imageHost =
      "http${results['secureImage'] ? 's' : ''}://${results['imageHost']}";
  prefs = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthState(),
      child: ChangeNotifierProvider(
        create: (context) => TextToImageWebsocketState(),
        child: ChangeNotifierProvider(
          create: (context) => TextToImageFormState(),
          child: MaterialApp(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.helloWorld,
            title: 'Hard Diffusion',
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: theme,
            initialRoute: '/',
            routes: <String, WidgetBuilder>{
              '/': (_) => const SplashPage(),
              '/login': (_) => const LoginPage(),
              '/generate': (_) => MyHomePage(),
            },
            // const MyHomePage(title: 'Hard Diffusion'),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  /*
  late Future<Album> futureAlbum;
  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }
  */
  void setSelectedIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    /*
    Widget page = GeneratePage();
    switch (selectedIndex) {
      case 0:
        page = GeneratePage();
        break;
      default:
        print("Nope");
        break;
      //throw UnimplementedError("no widget for $selectedIndex");
    }*/
    return LayoutBuilder(builder: (context, constraints) {
      var contextSize = MediaQuery.of(context).size;
      final double screenHeight = contextSize.height;
      final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      return SafeArea(
          child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(toolbarHeight: 30, title: Text("Hard Diffusion")),
              body: SizedBox(
                width: constraints.maxWidth,
                height: screenHeight - keyboardHeight - 30,
                child: OrientationBuilder(builder: (context, orientation) {
                  if (orientation == Orientation.landscape) {
                    return LandscapeView(
                        setSelectedIndex: setSelectedIndex,
                        selectedIndex: selectedIndex,
                        constraints: constraints);
                  }
                  return PortraitView(
                      setSelectedIndex: setSelectedIndex,
                      selectedIndex: selectedIndex,
                      constraints: constraints);
                }),
              )));
    });
  }
}



/*
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
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

    var localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(AppLocalizations.of(context)!.helloWorld),
        actions: [
          IconButton(
            tooltip: "favorite", //localization.starterAppTooltipFavorite,
            icon: const Icon(
              Icons.favorite,
            ),
            onPressed: () {},
          ),
          IconButton(
            tooltip: "search", //localization.starterAppTooltipSearch,
            icon: const Icon(
              Icons.search,
            ),
            onPressed: () {},
          ),
          PopupMenuButton<Text>(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text(
                    "first", //localization.demoNavigationRailFirst,
                  ),
                ),
                PopupMenuItem(
                  child: Text(
                    "second", //localization.demoNavigationRailSecond,
                  ),
                ),
                PopupMenuItem(
                  child: Text(
                    "third", //localization.demoNavigationRailThird,
                  ),
                ),
              ];
            },
          )
        ],
      ),
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Row(children: [
        Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ])),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
*/