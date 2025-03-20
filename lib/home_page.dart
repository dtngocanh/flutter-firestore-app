import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // for text editing controller
  final TextEditingController loaispController = TextEditingController();
  final TextEditingController giaController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final CollectionReference myItems = FirebaseFirestore.instance.collection(
    "items",
  );
  // for create operation
  Future<void> create() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return myDialogBox(
          name: "Create Product",
          condition: "Create",
          onPressed: () {
            String loaisp = loaispController.text;
            double gia = double.parse(giaController.text);
            addItems(loaisp, gia);
            Navigator.pop(context); // terminate dialog after creating items
          },
        );
      },
    );
  }

  void addItems(String loaisp, double gia) {
    myItems.add({'loaisp': loaisp, 'gia': gia});
  }

  // for update operation
  Future<void> update(DocumentSnapshot documentSnapshot) async {
    loaispController.text = documentSnapshot['loaisp'];
    giaController.text = documentSnapshot['gia'].toString();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return myDialogBox(
          name: "Update Product",
          condition: "Update",
          onPressed: () async {
            String loaisp = loaispController.text;
            double gia = double.parse(giaController.text);
            // addItems(loaisp, gia);
            await myItems.doc(documentSnapshot.id).update({
              'loaisp': loaisp,
              'gia': gia,
            });
            // loaispController.text = '';
            // giaController.text = '';
            loaispController.clear();
            giaController.clear();
            Navigator.pop(context); // terminate dialog after updating items
          },
        );
      },
    );
  }

  // for delete operation
  Future<void> delete(String productId) async {
    await myItems.doc(productId).delete();
    //   for snackbar after delete items
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(microseconds: 1000),
        content: Text("Delete Successfully"),
      ),
    );
  }

  String searchText = '';
  void onSearchChange(String value) {
    setState(() {
      searchText = value;
    });
  }

  bool isSearchClick = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[100],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.orange,
        title:
            isSearchClick
                ? Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    onChanged: onSearchChange,
                    controller: searchController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                      hintText: "Search...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                )
                : const Text(
                  "Admin panel",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isSearchClick = !isSearchClick;
              });
            },
            icon: Icon(
              isSearchClick ? Icons.close : Icons.search,
              color: Colors.white,
            ),
          ),
        ],
      ),
      //   for display the firstore items
      body: StreamBuilder(
        stream: myItems.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            final List<DocumentSnapshot> items =
                streamSnapshot.data!.docs
                    .where(
                      (doc) => doc['loaisp'].toLowerCase().contains(
                        searchText.toLowerCase(),
                      ),
                    )
                    .toList();
            return ListView.builder(
              // itemCount: streamSnapshot.data!.docs.length,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot = items[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(20),
                    child: ListTile(
                      title: Text(
                        documentSnapshot['loaisp'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Text("\$${documentSnapshot['gia']}"),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => update(documentSnapshot),
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () => delete(documentSnapshot.id),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      //   for create new project icon
      floatingActionButton: FloatingActionButton(
        onPressed: create,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Dialog myDialogBox({
    required String name,
    required String condition,
    required VoidCallback onPressed,
  }) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close),
              ),
            ],
          ),
          TextField(
            controller: loaispController,
            decoration: InputDecoration(
              labelText: "Enter the Category",
              hintText: 'eg. mobile',
            ),
          ),
          TextField(
            controller: giaController,
            decoration: InputDecoration(
              labelText: "Enter the Price",
              hintText: 'eg. 100',
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(onPressed: onPressed, child: Text(condition)),
          SizedBox(height: 10),
        ],
      ),
    ),
  );
}

// now we make this dialog box reusable
