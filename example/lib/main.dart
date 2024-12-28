
import 'package:animated_linear_step_indicator/animated_linear_step_indicator.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(MyApp());
}

enum DemoStages { created, precessed, sent, completed }

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light
        ),
        useMaterial3: true,
        brightness: Brightness.light
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark
        ),
        useMaterial3: true,
        brightness: Brightness.dark
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }

}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  DemoStages _stage = DemoStages.created;

  void _incrementStage(){
    int currentStage = _stage.index;
    currentStage++;
    if(currentStage >= DemoStages.values.length){
      currentStage = DemoStages.created.index;
    }
    setState(() {
      _stage = DemoStages.values[currentStage];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          StagedLine<DemoStages>(
            stageState: _stage,
            stagesNames: const {
              DemoStages.created : 'created',
              DemoStages.precessed: 'precessed',
              DemoStages.sent: 'sent',
              DemoStages.completed: 'completed'
            },
            stagesColors: const {
              DemoStages.created : Colors.yellow,
              DemoStages.precessed: Colors.orange,
              DemoStages.sent: Colors.blue,
              DemoStages.completed: Colors.green
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: (){setState(() { _stage = DemoStages.created; });}, child: Text("created")),
              TextButton(onPressed: (){setState(() { _stage = DemoStages.precessed; });}, child: Text("precessed")),
              TextButton(onPressed: (){setState(() { _stage = DemoStages.sent; });}, child: Text("sent")),
              TextButton(onPressed: (){setState(() { _stage = DemoStages.completed; });}, child: Text("completed")),
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){ _incrementStage(); },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
