import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formkey = GlobalKey<FormState>();
  var enteredName = '';
  var enteredQuantity = 1;
  var selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;

  void _saveitem() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url = Uri.https(
          'papom-c875f-default-rtdb.firebaseio.com', "shopping-list.json");
      final response = await http.post(
        url,
        headers: {"contentType": "application/json"},
        body: json.encode(
          {
            'name': enteredName,
            'quantity': enteredQuantity,
            'category': selectedCategory.title
          },
        ),
      );
      final Map<String, dynamic> resData = json.decode(response.body);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(
        GroceryItem(
          id: resData['name'],
          name: enteredName,
          quantity: enteredQuantity,
          category: selectedCategory,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text(
          'Add Item',
          style: TextStyle(
            fontFamily: 'HelveticaNowDisplay',
            fontSize: 28,
            color: Color.fromARGB(255, 200, 220, 222),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              const SizedBox(
                height: 8,
              ),
              TextFormField(
                style: const TextStyle(
                  fontFamily: 'HelveticaNowDisplay',
                  fontSize: 30,
                  color: Color.fromARGB(255, 60, 60, 60),
                ),
                maxLength: 50,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  errorStyle: TextStyle(
                    fontFamily: 'HelveticaNowDisplay',
                    fontSize: 12,
                    color: Color.fromARGB(255, 255, 84, 84),
                  ),
                  counterStyle: TextStyle(
                    fontFamily: 'HelveticaNowDisplay',
                    fontSize: 12,
                    color: Color.fromARGB(255, 60, 60, 60),
                  ),
                  label: Text(
                    "Item Name",
                    style: TextStyle(
                      fontFamily: 'HelveticaNowDisplay',
                      fontSize: 24,
                      color: Color.fromARGB(255, 60, 60, 60),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return "Must be between 1 and 50 characters.";
                  }
                  return null;
                },
                onSaved: (value) {
                  enteredName = value!;
                },
              ),
              const SizedBox(
                height: 24,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      style: const TextStyle(
                        fontFamily: 'HelveticaNowDisplay',
                        fontSize: 22,
                        color: Color.fromARGB(255, 60, 60, 60),
                      ),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        errorStyle: TextStyle(
                          fontFamily: 'HelveticaNowDisplay',
                          fontSize: 12,
                          color: Color.fromARGB(255, 255, 84, 84),
                        ),
                        label: Text(
                          "Quantity",
                          style: TextStyle(
                            fontFamily: 'HelveticaNowDisplay',
                            fontSize: 20,
                            color: Color.fromARGB(255, 60, 60, 60),
                          ),
                        ),
                      ),
                      initialValue: enteredQuantity.toString(),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! < 1) {
                          return "Must be a positive number.";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      iconEnabledColor: const Color.fromARGB(255, 29, 27, 32),
                      dropdownColor: const Color.fromARGB(255, 235, 243, 236),
                      style: const TextStyle(
                        fontFamily: 'HelveticaNowDisplay',
                        fontSize: 18,
                        color: Color.fromARGB(255, 46, 74, 72),
                      ),
                      value: selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  category.value.title,
                                ),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formkey.currentState!.reset();
                          },
                    child: const Text(
                      "Reset",
                      style: TextStyle(
                        fontFamily: 'HelveticaNowDisplay',
                        fontSize: 16,
                        color: Color.fromARGB(255, 46, 74, 72),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveitem,
                    child: _isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text(
                            "Add Item",
                            style: TextStyle(
                              fontFamily: 'HelveticaNowDisplay',
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Color.fromARGB(255, 46, 74, 72),
                            ),
                          ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
