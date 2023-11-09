import 'package:flutter/material.dart';
import 'sqlite_service.dart';
import '/models/handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DatabaseHandler handler;
  TextEditingController tickerController = TextEditingController();
  TextEditingController openController = TextEditingController();
  TextEditingController highController = TextEditingController();
  TextEditingController lastController = TextEditingController();
  TextEditingController changeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      await this.addUsers();
      setState(() {});
    });
  }

  Future<int> addUsers() async {
    Model firstUser = Model(ticker: "TLKM", open: 3380, high: 3500, last: 3490, change: 2.50);
    Model secondUser = Model(ticker: "AMMN", open: 6750, high: 6750, last: 6500, change: -3.70);
    Model thirdUser = Model(ticker: "BREN", open: 4500, high: 4610, last: 4580, change: 1.78);
    Model fourthUser = Model(ticker: "CUAN", open: 5200, high: 5525, last: 5400, change: 3.85);

    List<Model> listOfUsers = [firstUser, secondUser, thirdUser, fourthUser];

    return await this.handler.insertUser(listOfUsers);
  }

  Future<void> addSaham() async {
    String ticker = tickerController.text;
    int open = int.parse(openController.text);
    int high = int.parse(highController.text);
    int last = int.parse(lastController.text);
    double change = double.parse(changeController.text);

    Model user = Model(ticker: ticker, open: open, high: high, last: last, change: change);

    await this.handler.insertUser([user]);
    setState(() {
      tickerController.clear();
      openController.clear();
      highController.clear();
      lastController.clear();
      changeController.clear();
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
        children: [
          buildForm(),
          FutureBuilder(
            future: this.handler.retrieveUsers(),
            builder: (BuildContext context, AsyncSnapshot<List<Model>> snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Dismissible(
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: const Icon(Icons.delete_forever),
                        ),
                        key: ValueKey<int>(snapshot.data![index].tickerid!),
                        child: Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8.0),
                            title: Text(snapshot.data![index].ticker),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Open: ${snapshot.data![index].open}'),
                                Text('High: ${snapshot.data![index].high}'),
                                Text('Last: ${snapshot.data![index].last}'),
                                Text(
                                  'Change: ${snapshot.data![index].change}',
                                  style: TextStyle(
                                    color: snapshot.data![index].change < 0 ? Colors.red : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }

  Column buildForm() {
    return Column(
      children: [
        TextField(
          controller: tickerController,
          decoration: const InputDecoration(labelText: 'Ticker'),
        ),
        TextField(
          controller: openController,
          decoration: const InputDecoration(labelText: 'Open'),
        ),
        TextField(
          controller: highController,
          decoration: const InputDecoration(labelText: 'High'),
        ),
        TextField(
          controller: lastController,
          decoration: const InputDecoration(labelText: 'Last'),
        ),
        TextField(
          controller: changeController,
          decoration: const InputDecoration(labelText: 'Change'),
        ),
        ElevatedButton(
          onPressed: () {
            addSaham();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data saham berhasil disimpan')));
          },
          child: const Text('Simpan Data Saham'),
        ),
      ],
    );
  }
}
