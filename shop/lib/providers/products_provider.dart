import 'dart:convert';
import 'package:flutter/material.dart';
import 'products.dart';
import 'package:http/http.dart' as http;

class ProductsProvider with ChangeNotifier {
  List<Products> _items = [
    // Products(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Products(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Products(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Products(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  List<Products> get fvtItems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }

  List<Products> get items {
    // if (_showFavouritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavourite).toList();
    // }
    return [..._items];
  }

  Products findById(String id) {
    return _items.firstWhere((element) => id == element.id);
  }

  // void showFavouritesOnly() {
  //   _showFavouritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavouritesOnly = false;
  //   notifyListeners();
  // }
  Future<void> fetchAndSetProducts() async {
    var url = Uri.parse(
        'https://shop-e0f27-default-rtdb.asia-southeast1.firebasedatabase.app/products.json');
    try {
      final response = await http.get(url);
      final List<Products> loadedProducts = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          Products(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavourite: prodData['isFavourite'],
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Products products) async {
    var url = Uri.parse(
        'https://shop-e0f27-default-rtdb.asia-southeast1.firebasedatabase.app/products.json');
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': products.title,
            'price': products.price,
            'description': products.description,
            'imageUrl': products.imageUrl,
            'isFavourite': products.isFavourite,
          }));
      final newProduct = Products(
        id: json.decode(response.body)['name'],
        title: products.title,
        description: products.description,
        price: products.price,
        imageUrl: products.imageUrl,
      );
      _items.add(newProduct);
      // _items.add(value);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Products newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      var url = Uri.parse(
          'https://shop-e0f27-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'price': newProduct.price,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  void deleteProduct(String id) async {
    var url = Uri.parse(
        'https://shop-e0f27-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json');
    await http.delete(url);
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
  }
}
