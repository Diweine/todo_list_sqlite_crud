import 'package:flutter/material.dart';
import 'package:todo_list_sqlite/helpers/sql_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All journals
  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;

  bool _isChecked = false;

  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals(); // Loading the diary when the app starts
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int isdone = 0;

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
      isdone = existingJournal['isdone'];
      isdone == 1 ? _isChecked = true : _isChecked = false;
    }

    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding: const EdgeInsets.fromLTRB(25.0, 15.0, 15.0, 15.0),
                width: double.infinity,
                height: 230,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(hintText: 'Título'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(hintText: 'Descrição'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _isChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _isChecked = value!;
                                    });
                                  },
                                ),
                                const Text(
                                  'concluída',
                                  style: TextStyle(fontSize: 12.0),
                                ),
                              ],
                            )),
                        Flexible(
                            flex: 1,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Save new journal
                                if (id == null) {
                                  await _addItem();
                                }

                                if (id != null) {
                                  await _updateItem(id);
                                }

                                // Clear the text fields
                                _titleController.text = '';
                                _descriptionController.text = '';
                                _descriptionController.text = '';
                                _isChecked = false;

                                // Close the bottom sheet
                                Navigator.of(context).pop();
                              },
                              child: const Text('Salvar'),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ));
  }

  Future<void> _addItem() async {
    await SQLHelper.createItem(_titleController.text,
        _descriptionController.text, _isChecked == true ? 1 : 0);
    _refreshJournals();
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(id, _titleController.text,
        _descriptionController.text, _isChecked == true ? 1 : 0);
    _refreshJournals();
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Registro excluido com sucesso.'),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Lista de Atividades')),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _journals.length,
              itemBuilder: (context, index) => Card(
                color: Colors.grey[300],
                margin: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
                child: ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Icon(
                          _journals[index]['isdone'] == 1
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: Colors.green),
                    ),
                    title: Text(_journals[index]['title']),
                    subtitle: Text(_journals[index]['description']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showForm(_journals[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _deleteItem(_journals[index]['id']),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
