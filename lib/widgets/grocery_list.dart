import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  double turns = 0.0;
  var isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void loadItems() async {
    final url = Uri.https(
        'papom-c875f-default-rtdb.firebaseio.com', "shopping-list.json");

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = "No Items Found!";
        });
      }

      if (response.body == 'null') {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];

      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        loadedItems.add(GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category));
      }
      setState(() {
        _groceryItems = loadedItems;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = "No Connection...";
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https('papom-c875f-default-rtdb.firebaseio.com',
        "shopping-list/${item.id}.json");
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'lib\\assets\\images\\no item.svg',
            width: 300,
            height: 300,
          ),
          const SizedBox(
            height: 8,
          ),
          const Text(
            "Add items to see here...",
            style: TextStyle(
              fontFamily: 'HelveticaNowDisplay',
              fontSize: 24,
              color: Color.fromARGB(255, 46, 74, 72),
            ),
          ),
        ],
      ),
    );

    if (isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
        child: ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (ctx, index) => Dismissible(
            onDismissed: (direction) {
              _removeItem(_groceryItems[index]);
            },
            key: ValueKey(_groceryItems[index].id),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 233, 230, 218),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: ListTile(
                    title: Text(
                      _groceryItems[index].name,
                      style: const TextStyle(
                        fontFamily: 'HelveticaNowDisplay',
                        fontSize: 22,
                        letterSpacing: 0.5,
                        color: Color.fromARGB(255, 60, 60, 60),
                      ),
                    ),
                    leading: Container(
                      height: 24,
                      width: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: _groceryItems[index].category.color,
                      ),
                    ),
                    trailing: Text(
                      _groceryItems[index].quantity.toString(),
                      style: const TextStyle(
                        fontFamily: 'HelveticaNowDisplay',
                        fontSize: 22,
                        color: Color.fromARGB(255, 60, 60, 60),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'lib\\assets\\images\\no connection.svg',
              width: 300,
              height: 300,
            ),
            Text(
              _error!,
              style: const TextStyle(
                fontFamily: 'HelveticaNowDisplay',
                fontSize: 24,
                color: Color.fromARGB(255, 46, 74, 72),
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text(
          "Shopping List",
          style: TextStyle(
            fontFamily: 'HelveticaNowDisplay',
            fontSize: 32,
            color: Color.fromARGB(255, 235, 253, 255),
          ),
        ),
        actions: [
          AnimatedRotation(
            turns: turns,
            duration: Durations.extralong4,
            child: IconButton(
              onPressed: () {
                setState(() {
                  turns = turns + 1;
                  loadItems();
                });
              },
              icon: SvgPicture.asset(
                'lib\\assets\\images\\refresh.svg',
                width: 50,
                height: 50,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _addItem();
                });
              },
              icon: SvgPicture.asset(
                'lib\\assets\\images\\add.svg',
                width: 50,
                height: 50,
              ),
            ),
          ),
        ],
      ),
      body: content,
    );
  }
}
