import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'image_widget.dart';

class AddNewImage extends StatefulWidget {
  @override
  _AddNewImageState createState() => _AddNewImageState();
}

class _AddNewImageState extends State<AddNewImage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _controller = TextEditingController();
  TextEditingController _controller2 = TextEditingController();
  TextEditingController _controller3 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    InputDecoration _buildDecoration(String label) {
      return InputDecoration(
          labelText: label, labelStyle: TextStyle(color: Colors.grey));
    }

    final _fieldStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        elevation: 0,
        title: Text('Inserir nova imagem'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.remove, color: Colors.grey[850]),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text(
                          'Deseja cancelar a imagem?',
                          style: TextStyle(color: Colors.grey[850]),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text(
                              'Não',
                              style: TextStyle(color: Colors.red, fontSize: 17),
                            ),
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                          ),
                          FlatButton(
                              child: Text(
                                'Sim',
                                style: TextStyle(
                                    color: Colors.green, fontSize: 17),
                              ),
                              onPressed: () {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              }),
                        ],
                      ),
                );
              }),
          IconButton(
            // Botão salvar
            icon: Icon(Icons.save, color: Colors.grey[850]),
            onPressed: () {
              Firestore.instance.collection('home').document().setData({
                "pos": int.parse(_controller.text),
                "x": int.parse(_controller2.text),
                "y": int.parse(_controller3.text)
              });
              Navigator.of(context).popUntil((route) => route.isFirst);
            }, // Se ele está carregando, o botão vai ficar desabilitado, caso contrário, saveProduct.
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Form(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: <Widget>[
                TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: _buildDecoration('Posição'),
                  controller: _controller,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: _buildDecoration('Largura'),
                  controller: _controller2,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: _buildDecoration('Altura'),
                  controller: _controller3,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
