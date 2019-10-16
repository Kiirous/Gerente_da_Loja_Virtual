import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:transparent_image/transparent_image.dart';

class NewsTab extends StatefulWidget {
  @override
  _NewsTabState createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab>{
  @override
  Widget build(BuildContext context) {

    Widget _buildBodyBack() => Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 254, 207, 99),
            Color.fromARGB(255, 254, 254, 254),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );

    return Stack(
      children: <Widget>[
        _buildBodyBack(),
        CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Novidades', style: TextStyle(color: Color.fromARGB(255, 110, 39, 31)),),
                centerTitle: true,
              ),
            ),
            FutureBuilder<QuerySnapshot>(
              future: Firestore.instance.collection('home').orderBy('pos').getDocuments(),
              builder: (context, snapshot){
                if(!snapshot.hasData)
                  return SliverToBoxAdapter(
                      child: Container(
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                  );
                else
                  return SliverStaggeredGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 1.0,
                    crossAxisSpacing: 1.0,

                    //staggeredTiles: dimensoes das imagens
                    //snapshot.data.documents.map: pegamos uma lista de documentos

                    staggeredTiles: snapshot.data.documents.map(
                      //para mapear a lista, usamos uma funcao anonima que recebe um documento e retorna um documento
                            (doc){
                          return StaggeredTile.count(doc.data["x"], doc.data["y"]);
                        }
                    ).toList(),
                    children: snapshot.data.documents.map(
                            (doc){
                          return GestureDetector(
                            child: FadeInImage.memoryNetwork(
                              //import 'package:transparent_image/transparent_image.dart';
                              placeholder: kTransparentImage,
                              image: doc.data["image"],
                              fit: BoxFit.cover,
                            ),
                            onTap: (){
                              showDialog(context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Deseja excluir esta imagem?', style: TextStyle(color: Colors.grey[850]),),
                                    actions: <Widget>[
                                      FlatButton(
                                        child:Text('Não', style: TextStyle(color: Colors.red, fontSize: 17)),
                                        onPressed: (){
                                          Navigator.pop(context, false);
                                        },
                                      ),
                                      FlatButton(
                                          child: Text('Sim', style: TextStyle(color: Colors.green, fontSize: 17)),
                                          onPressed:  (){
                                            //widget.coupon.reference.delete(); aqui vai o código para apagar a imagem

                                            Navigator.of(context).popUntil((route) => route.isFirst);
                                          }
                                      ),
                                    ],
                                  ),
                              );
                            },
                          );
                        }
                    ).toList(),
                  );
              },
            ),
          ],
        ),
      ],
    );
  }
}
