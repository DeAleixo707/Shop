import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _imageUrlFocusNode = FocusNode();
  final _imageController = TextEditingController();
  final _form = GlobalKey<FormState>();
  final Map<String, Object> _formData = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImage);
  }

  void _updateImage() {
    if (isValidImageUrl(_imageController.text)) {
      setState(() {});
    }
  }

  bool isValidImageUrl(String url) {
    final urlLower = url.toLowerCase();
    return (urlLower.startsWith("http://") ||
            urlLower.startsWith("https://")) &&
        (urlLower.endsWith(".png") ||
            urlLower.endsWith(".jpg") ||
            urlLower.endsWith(".jpeg"));
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImage);
    _imageUrlFocusNode.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_formData.isEmpty) {
      final argument = ModalRoute.of(context)?.settings.arguments;

      if (argument != null && argument is Product) {
        final product = argument;
        _formData['id'] = product.id;
        _formData['title'] = product.title;
        _formData['price'] = product.price;
        _formData['description'] = product.description;
        _formData['imageUrl'] = product.imageUrl;
        _imageController.text = product.imageUrl;
      }
    }
  }

  Future<void> _saveForm() async {
    setState(() {
      isLoading = true;
    });
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    _form.currentState?.save();

    final newProduct = Product(
      id: _formData['id'] as String? ?? Random().nextDouble().toString(),
      title: _formData['title'] as String,
      description: _formData['description'] as String,
      price: _formData['price'] as double,
      imageUrl: _formData['imageUrl'] as String,
    );

    final productProvider = Provider.of<Products>(context, listen: false);

  
      try {
        if (_formData['id'] == null) {
          await productProvider.addNewProducts(newProduct);
        } else {
          productProvider.updateProduct(newProduct);
        }
        Navigator.of(context).pop();
      } catch (error) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Alerta'),
            content:
                const Text('Ocorreu um erro inesperado ao salvar produto!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Produto'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _formData['title']?.toString(),
                      decoration: InputDecoration(
                        labelText: 'Título',
                        border: const UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) => _formData['title'] = value ?? '',
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty ||
                            value.trim().length < 3) {
                          return 'Informe um título válido com no mínimo 3 letras';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _formData['price']?.toString(),
                      decoration: InputDecoration(
                        labelText: "Preço",
                        border: const UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onSaved: (value) =>
                          _formData['price'] = double.tryParse(value!) ?? 0.0,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe um preço válido';
                        }
                        final price = double.tryParse(value);
                        if (price == null || price <= 0) {
                          return 'Informe um preço maior que zero';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _formData['description']?.toString(),
                      decoration: InputDecoration(
                        labelText: 'Descrição',
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      onSaved: (value) =>
                          _formData['description'] = value ?? '',
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty ||
                            value.trim().length < 10) {
                          return 'Informe uma descrição válida com no mínimo 10 letras';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Imagem',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                            keyboardType: TextInputType.url,
                            focusNode: _imageUrlFocusNode,
                            controller: _imageController,
                            onFieldSubmitted: (_) => _saveForm(),
                            onSaved: (value) =>
                                _formData['imageUrl'] = value ?? '',
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !isValidImageUrl(value)) {
                                return 'Insira uma URL válida';
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          height: 100,
                          width: 100,
                          margin: const EdgeInsets.only(left: 15, top: 15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 2),
                          ),
                          child: _imageController.text.isEmpty
                              ? const Text('Image URL aqui')
                              : FittedBox(
                                  child: Image.network(
                                    _imageController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
