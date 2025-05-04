import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  TextEditingController? _textEditingController;
  String name = 'data';
  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    if (_textEditingController != null) _textEditingController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProveOne(),
      child: Builder(
        builder: (context) {
          print("ــــــــــــــــــــــــــــــــــــــــــــــ");
          return Scaffold(
            appBar: AppBar(title: Text('test')),
            body: ListView(
              padding: EdgeInsets.all(10),
              children: [
                Center(
                  child: Text(
                    context.watch<ProveOne>().name,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    context.read<ProveOne>().changeName();
                  },
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: Text('do some thing'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProveOne extends ChangeNotifier {
  String name = 'welcome';
  changeName() {
    name = 'Eid';
    notifyListeners();
  }
}
