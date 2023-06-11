import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecatalog/bloc/add_product/add_product_bloc.dart';
import 'package:flutter_ecatalog/bloc/products/products_bloc.dart';
import 'package:flutter_ecatalog/data/datasources/local_datasource.dart';
import 'package:flutter_ecatalog/data/models/request/product_request_model.dart';
import 'package:flutter_ecatalog/presentation/login_page.dart';

import '../data/models/response/product_response_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController? titleController;
  TextEditingController? priceController;
  TextEditingController? descriptionController;
  ScrollController scrollController = ScrollController();
  int offset = 0;
  int limit = 10;
  bool isLoading = false;

  List<ProductResponseModel> listData = [];
  void setupScrollController(context) {
    scrollController.addListener(() {
      // print(scrollController.position.userScrollDirection);
      print(offset);
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          BlocProvider.of<ProductsBloc>(context)
              .add(GetProductsEvent(limit: limit, offset: offset));
        }
      }
    });
  }

  @override
  void initState() {
    titleController = TextEditingController();
    priceController = TextEditingController();
    descriptionController = TextEditingController();
    super.initState();
    setupScrollController(context);
    context.read<ProductsBloc>().add(GetProductsEvent(limit: 10, offset: 0));
  }

  @override
  void dispose() {
    super.dispose();
    titleController!.dispose();
    priceController!.dispose();
    descriptionController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        elevation: 5,
        actions: [
          IconButton(
            onPressed: () async {
              await LocalDataSource().removeToken();
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return const LoginPage();
              }));
            },
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(
            width: 16,
          )
        ],
      ),
      body: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          if (state is ProductsLoading) {
            listData = state.data;
            isLoading = true;
          }
          if (state is ProductsLoaded) {
            listData = state.data;
            print(listData.length);
            isLoading = false;
            offset = limit;
            limit = limit + 10;
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    // reverse: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          int id = listData[index].id!;

                          titleController!.text = listData[index].title!;
                          priceController!.text =
                              listData[index].price.toString();
                          descriptionController!.text =
                              listData[index].description!;

                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Update Product'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: titleController,
                                        decoration: const InputDecoration(
                                            labelText: 'Title'),
                                      ),
                                      TextField(
                                        controller: priceController,
                                        decoration: const InputDecoration(
                                            labelText: 'Price'),
                                      ),
                                      TextField(
                                        controller: descriptionController,
                                        decoration: const InputDecoration(
                                            labelText: 'Description'),
                                        maxLines: 3,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Cancel')),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    BlocConsumer<AddProductBloc,
                                        AddProductState>(
                                      listener: (context, state) {
                                        if (state is UpdateProductLoaded) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Update Product Success')),
                                          );
                                          context
                                              .read<ProductsBloc>()
                                              .add(GetProductsEvent());
                                          titleController!.clear();
                                          priceController!.clear();
                                          descriptionController!.clear();
                                          Navigator.pop(context);
                                        }
                                        if (state is AddProductError) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Add Product ${state.message}')),
                                          );
                                        }
                                      },
                                      builder: (context, state) {
                                        if (state is AddProductLoading) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        return ElevatedButton(
                                            onPressed: () {
                                              final model = ProductRequestModel(
                                                id: id,
                                                title: titleController!.text,
                                                price: int.parse(
                                                    priceController!.text),
                                                description:
                                                    descriptionController!.text,
                                              );

                                              context
                                                  .read<AddProductBloc>()
                                                  .add(DoUpdateProductEvent(
                                                      model: model));
                                            },
                                            child: const Text('Add'));
                                      },
                                    ),
                                  ],
                                );
                              });
                        },
                        child: Card(
                          child: ListTile(
                            title: Text(listData[index].title ?? '-'),
                            subtitle: Text('${listData[index].price}\$'),
                          ),
                        ),
                      );
                    },
                    itemCount: listData.length,
                  ),
                ),
                isLoading ? CircularProgressIndicator() : SizedBox()
              ],
            ),
          );

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Add Product'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      TextField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: 'Price'),
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel')),
                    const SizedBox(
                      width: 8,
                    ),
                    BlocConsumer<AddProductBloc, AddProductState>(
                      listener: (context, state) {
                        if (state is AddProductLoaded) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Add Product Success')),
                          );
                          context.read<ProductsBloc>().add(GetProductsEvent());
                          titleController!.clear();
                          priceController!.clear();
                          descriptionController!.clear();
                          Navigator.pop(context);
                        }
                        if (state is AddProductError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Add Product ${state.message}')),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is AddProductLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return ElevatedButton(
                            onPressed: () {
                              final model = ProductRequestModel(
                                title: titleController!.text,
                                price: int.parse(priceController!.text),
                                description: descriptionController!.text,
                              );

                              context
                                  .read<AddProductBloc>()
                                  .add(DoAddProductEvent(model: model));
                            },
                            child: const Text('Add'));
                      },
                    ),
                  ],
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
