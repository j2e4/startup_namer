import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
          title: 'Namer App',
          theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange)),
          // colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(0, 255, 0, 1.0))),
          // colorScheme: ColorScheme.fromSeed(seedColor: Color(0xffff9e00))),
          home: MyHomePage()),
    );
  }
}

// flutter 상태를 관리하는 간단한 방법 중 하나.
// app이 처리할 데이터를 정의하는 클래스.
// 데이터에 변화가 생기면 다른 위젯들에게 notify한다.
// ChangeNotifierProvider를 사용하는 the whole app의 어느 위젯이든 상관없이 상태를 사용할 수 있다.
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// State를 extends하기 때문에 own values를 관리할 수 있다. 스스로 변경할 수 있다.
class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = Placeholder();
        break;
      default:
        // development 환경에서 프로그램을 crash한다.
        throw UnimplementedError('no widget for $selectedIndex');
    }

    // constraints이 바뀔 때마다 builder를 호출한다.
    //  1. window 사이즈 변경  2. 디바이스 rotate 3. 주변 위젯의 사이즈 변경으로 인해 해당 위젯이 작아질 때
    return LayoutBuilder(builder: (context, constraints) {
      // 모든 build 메소드는 위젯이나 위젯 트리를 반환한다. (scaffold: 발판)
      return Scaffold(
          body: Row(
        children: [
          // 하드웨어 노치나 상대 표시줄에 의해 child가 가려지지 않도록 보장한다.
          SafeArea(
              // NavigationRail은 충분한 공간이 있어도 자동으로 label을 보여주지 않는다. 모든 context에서 충분한 공간이 무엇인지 모르기 때문
              // 참고로 Row, Column과 비슷한 Wrap 위젯을 통해 충분한 공간이 없을 때 다음 line으로 children을 wrap하거나
              //  FittedBox 위젯을 통해 개발자의 명세에 따라 사용 가능한 공간에 child를 자동으로 fit할 수 있다.
              child: NavigationRail(
            // true면 Icon 오른쪽에 Text를 표시한다.
            extended: constraints.maxWidth >= 600,
            destinations: [
              NavigationRailDestination(
                  icon: Icon(Icons.home), label: Text('Home')),
              NavigationRailDestination(
                  icon: Icon(Icons.favorite), label: Text('Favorites'))
            ],
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) {
              // setState 내부에서 상태를 변경한다. notifyListeners()와 비슷하게 UI 업데이트를 보장한다.
              setState(() {
                selectedIndex = value;
              });
            },
          )),
          // greedy하다. 최대한 많은 공간을 차지한다.
          Expanded(
              child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page)),
        ],
      ));
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  // 모든 위젯은 build 메소드를 갖는다. 자동으로 호출된다.
  Widget build(BuildContext context) {
    // watch 메소드를 통해 앱의 현재 상태를 추적한다.
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavorite();
                  },
                  icon: Icon(appState.favorites.contains(pair)
                      ? Icons.favorite_border
                      : Icons.favorite),
                  label: Text('Like')),
              SizedBox(width: 10),
              ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: Text('Next')),
            ],
          )
          // trailing comma 사용하는 게 바람직하다.
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    // 이론적으로 null일 수 있기 때문에 ! 연산자(Bang 연산자)를 사용한다.
    // copyWith 메소드는 color로 정의한 변경 사항을 적용해 text style의 복사본을 반환한다.
    var style = theme.textTheme.displayMedium!.copyWith(
        color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold);

    return Card(
      color: theme.colorScheme.primary,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          // getter로써 asLowerCase를 택했다.
          pair.asPascalCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
