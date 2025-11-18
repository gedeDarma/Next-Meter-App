import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/customer.dart';
import 'models/transaction.dart' as tx_model;
import 'screens/intro_screen.dart';
import 'screens/home_screen.dart';
import 'services/data_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(tx_model.TransactionAdapter());
  await Hive.openBox<Customer>('customers');
  await Hive.openBox<tx_model.Transaction>('transactions');
  await DataService.seedMockCustomersIfEmpty();
  runApp(const NextMeterApp());
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}

class ThemeProviderInherited extends InheritedNotifier<ThemeProvider> {
  const ThemeProviderInherited({
    super.key,
    required ThemeProvider super.notifier,
    required super.child,
  });

  static ThemeProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ThemeProviderInherited>()!
        .notifier!;
  }
}

class NextMeterApp extends StatefulWidget {
  const NextMeterApp({super.key});

  @override
  State<NextMeterApp> createState() => _NextMeterAppState();
}

class _NextMeterAppState extends State<NextMeterApp> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeProvider,
      builder: (context, child) {
        return ThemeProviderInherited(
          notifier: _themeProvider,
          child: MaterialApp(
            title: 'Next Meter - Water Token',
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode:
                _themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const IntroScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
            },
          ),
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0066CC),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
      cardTheme: CardThemeData(
        color: Colors.grey[50],
        elevation: 2,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0066CC),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF1a1a1a),
        foregroundColor: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
      ),
    );
  }
}

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
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
