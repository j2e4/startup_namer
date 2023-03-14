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

class MyHomePage extends StatelessWidget {
  @override
  // 모든 위젯은 build 메소드를 갖는다. 자동으로 호출된다.
  Widget build(BuildContext context) {
    // watch 메소드를 통해 앱의 현재 상태를 추적한다.
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    // 모든 build 메소드는 위젯이나 위젯 트리를 반환한다. (scaffold: 발판)
    return Scaffold(
        // Column은 children을 받아 top to bottom 나열한다.
        body: Center(
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
    ));
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
