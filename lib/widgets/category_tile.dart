import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerente_loja/screens/product_screen.dart';
import 'package:gerente_loja/widgets/edit_category_dialog.dart';

class CategoryTile extends StatelessWidget {

  //tenho que receber o snapshot do documento aqui no construtor. Pois la no products_tab passamos um snapshot do documento.
  final DocumentSnapshot category;

  CategoryTile(this.category);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ExpansionTile(
          leading: GestureDetector(
            onTap: (){
              showDialog(
                  context: context,
                  builder: (context) => EditCategoryDialog(
                    category: category,
                  ),
              );
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(category.data['icon']),
              backgroundColor: Colors.transparent,
            ),
          ),
          title: Text(
            category.data['title'],
            style: TextStyle(color: Colors.grey[850], fontWeight: FontWeight.w500),
          ),
          children: <Widget>[ // O que vai aparecer quando abrirmos o ExpansionTile
            FutureBuilder<QuerySnapshot>(
            future: category.reference.collection('itens').getDocuments(),
        builder: (context, snapshot){
              if(!snapshot.hasData) return Container();
              return Column(
                children: snapshot.data.documents.map((doc){
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(doc.data['images'][0]), //O [0] é necessário pois temos uma lista de imagens de cada protudo. E nós só queremos a primeira imagem.
                    ),
                    title: Text(doc.data['title']),
                    trailing: Text('R\$${doc.data['price'].toStringAsFixed(2)}'), //toStringAsFixed pois eu quero apenas mostrar 2 casas decimais
                    onTap: (){
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context)=> ProductScreen(
                            categoryId : category.documentID,
                            product: doc,
                          )));
                    },
                  );
                }).toList()..add(
                  ListTile(
                    leading: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.add, color: Color.fromARGB(254, 242, 193, 94),),
                  ),
                    title: Text('Adicionar'),
                    onTap: (){
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context)=> ProductScreen(
                            categoryId : category.documentID,
                          )));
                    },
                  ),
                ), //Esse ..add() é uma notação de cascata, permite colocarmos mais um widget na nossa lista.
              );
        },
            ),
          ],
        ),
      ),
    );
  }
}
