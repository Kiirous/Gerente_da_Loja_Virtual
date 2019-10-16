import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerente_loja/blocs/category_bloc.dart';
import 'package:gerente_loja/widgets/image_source_sheet.dart';

class EditCategoryDialog extends StatefulWidget {

  final DocumentSnapshot category;
  EditCategoryDialog({this.category});

  @override
  _EditCategoryDialogState createState() => _EditCategoryDialogState(
    category: category
  );
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  final CategoryBloc _categoryBloc;
  final TextEditingController _controller;

  _EditCategoryDialogState({DocumentSnapshot category}) : //Colocando o category como opcional pois podemos mandar ou não
        _categoryBloc = CategoryBloc(category),
        _controller = TextEditingController(text: category != null ?
        category.data['title'] : ''
        );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: GestureDetector(
                onTap: (){
                  showModalBottomSheet(context: context,
                      builder: (context) => ImageSourceSheet(
                        onImageSelected: (image){
                          Navigator.of(context).pop();
                          _categoryBloc.setImage(image);
                        },
                      ));
                },
                child: StreamBuilder(
                    stream: _categoryBloc.outImage,
                    builder: (context, snapshot) {
                      if(snapshot.data != null) //Se for diferente de nulo significa que eu tenho uma imagem(ou um file ou uma String) no Stream
                        return CircleAvatar(
                          child: snapshot.data is File ?
                          Image.file(snapshot.data, fit: BoxFit.cover,) : //Desenha a imagem vindo do arquivo
                          Image.network(snapshot.data, fit: BoxFit.cover,), //Desenha a imagem vinda de uma url
                          backgroundColor: Colors.transparent,
                        );
                      else return Icon(Icons.image, color: Color.fromARGB(254, 115, 34, 34),);
                    }
                ),
              ),
              title: StreamBuilder<String>(
                stream: _categoryBloc.outTitle,
                builder: (context, snapshot) {
                  return TextField(
                    controller: _controller,
                    onChanged: _categoryBloc.setTitle,
                    decoration: InputDecoration(
                      errorText: snapshot.hasError ? snapshot.error : null,
                    ),
                  );
                }
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                StreamBuilder<bool>(
                    stream: _categoryBloc.outDelete,
                    builder: (context, snapshot) {
                      if(!snapshot.hasData) return Container(); // Garantindo que ele nunca vai tentar ler o dado dentro do onpressed.
                      return FlatButton(
                        child: Text('Excluir'),
                        textColor: Colors.red,
                        onPressed: snapshot.data ? (){
                          _categoryBloc.delete();
                          Navigator.of(context).pop();
                        } : null,
                      );
                    }
                ),
                StreamBuilder<bool>(
                  stream: _categoryBloc.submitValid,
                  builder: (context, snapshot) {
                    return FlatButton(
                        child: Text('Salvar'),
                        onPressed: snapshot.hasData ? () async{
                          await _categoryBloc.saveData();
                          Navigator.of(context).pop();
                        } : null,
                      
                    );
                  }
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

