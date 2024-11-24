import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MindMap Notes',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> mindMaps = [];

  @override
  void initState() {
    super.initState();
    _loadMindMaps();
  }

  Future<void> _loadMindMaps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        mindMaps = prefs.getStringList('mindMaps') ?? [];
      });
    } catch (e) {
      print("Erro ao carregar os mapas mentais: $e");
    }
  }

  Future<void> _saveMindMaps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('mindMaps', mindMaps);
    } catch (e) {
      print("Erro ao salvar os mapas mentais: $e");
    }
  }

  void _addMindMap(String title) {
    setState(() {
      mindMaps.add(title);
    });
    _saveMindMaps();
  }

  void _deleteMindMap(int index) {
    setState(() {
      mindMaps.removeAt(index);
    });
    _saveMindMaps();
  }

  // Função de edição de mapa mental
  void _editMindMap(int index) async {
    final newTitle = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditScreen(initialTitle: mindMaps[index]),
      ),
    );

    if (newTitle != null && newTitle != mindMaps[index]) {
      setState(() {
        mindMaps[index] = newTitle;
      });
      _saveMindMaps();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MindMap Notes'),
      ),
      body: mindMaps.isEmpty
          ? const Center(
              child: Text('Nenhum mapa mental criado.'),
            )
          : ListView.builder(
              itemCount: mindMaps.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(mindMaps[index]),
                    onTap: () => _editMindMap(index), // Editar ao tocar no item
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteMindMap(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTitle = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditScreen()),
          );
          if (newTitle != null) {
            _addMindMap(newTitle);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EditScreen extends StatefulWidget {
  final String? initialTitle;

  const EditScreen({Key? key, this.initialTitle}) : super(key: key);

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.initialTitle == null
            ? const Text('Novo Mapa Mental')
            : const Text('Editar Mapa Mental'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Título do Mapa Mental',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  Navigator.pop(context, _controller.text);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
