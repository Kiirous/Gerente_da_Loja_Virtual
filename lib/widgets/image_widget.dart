import 'package:flutter/material.dart';
import 'package:gerente_loja/widgets/image_source_sheet.dart';

class ImagesWidget extends FormField<List>{

  //Sistema para Acesso a camera ou galeria.
  ImagesWidget({
    BuildContext context,
    FormFieldSetter<List> onSaved,
    FormFieldValidator<List> validator,
    List initialValue, // Vou passar as imagens do produto pro initialValue
    bool autoValidate = false,
  }) : super(
    onSaved: onSaved,
    validator: validator,
    initialValue: initialValue,
    autovalidate: autoValidate,
    builder: (state){ // Esse State é o estado do nosso Formulário. Vai ter valor atual, erro, etc..
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container( // Quadrado que vai conter as imagens do produto e permitir removelas.
            height: 124,
            padding: EdgeInsets.only(top: 16, bottom: 8),
            child: ListView(
              scrollDirection: Axis.horizontal, // Rolar a lista de imagens na horizontal
              children: state.value.map<Widget>((i){
                return Container(
                  height: 100,
                  width: 100,
                  margin: EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    child: i is String ? Image.network(i, fit: BoxFit.cover,) : // Se a imagem(i) for String... É apenas para verificar o tipo da imagem
                        Image.file(i, fit: BoxFit.cover,),
                    onLongPress: (){
                      state.didChange(state.value..remove(i)); // O .. me retorna o valor final e não o resultado da operação.
                    },
                  ),
                );
              }).toList()..add(
                GestureDetector(
                  child: Container(
                    height: 100,
                    width: 100,
                    child: Icon(Icons.camera_enhance, color: Colors.white,),
                    color: Colors.white.withAlpha(50),
                  ),
                  onTap: (){
                    showModalBottomSheet(
                        context: context,
                        builder: (context) => ImageSourceSheet(
                          onImageSelected: (image){
                            state.didChange(state.value..add(image)); // Adicionei a Imagem na lista e informei que a lista mudou.
                          Navigator.of(context).pop();
                          },
                        )
                    );
                  },
                ),
              ),
            ),
          ),
          state.hasError ? Text( // Se tiver erro, vai mostrar um texto com a mensagem de erro em vermelho
            state.errorText,
            style: TextStyle(color: Colors.red, fontSize: 12),
          ) : Container() // Caso ao contrário, nao mostra nada.
        ],
      );
    }
  );
}