import 'package:flutter/material.dart';
import 'package:gerente_loja/widgets/add_size_dialog.dart';

class ProductSizes extends FormField<List> {

  ProductSizes(
  {
    BuildContext context,
    List initialValue, // Valores iniciais, Pois quando for aberto a tela, vai ser passado a lista de tamanhos
    FormFieldSetter<List> onSaved,
    FormFieldValidator<List> validator,
}
      ) : super(
    initialValue: initialValue,
    onSaved: onSaved,
    validator: validator,
    builder: (state){
      return SizedBox(
        height: 34, //Altura do quadradinho dos tamanhos
        child: GridView(
          padding: EdgeInsets.symmetric(vertical: 4),
          scrollDirection: Axis.horizontal, //Podermos deslizar para esquerda e direita na horizontal.
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( // É mais facil para definir espaçamento entre um quadrado para outro.
              crossAxisCount: 1, //Itens que vamos ter no eixo cruzado
            mainAxisSpacing: 8, //Espaçamento entre os tamanhos
            childAspectRatio: 0.5, //Faz o tamanho da altura ser metado do tamanho do cumprimento.
          ),
          children: state.value.map(
              (s){
                return GestureDetector(
                  onLongPress: (){
                    state.didChange(state.value..remove(s)); // Remove o tamanho que foi pressionado e refaz o widget inteiro novamente
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4)), //Curvinha da borda
                      border: Border.all(
                        color: Color.fromARGB(254, 242, 193, 94),
                        width: 3,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(s,
                    style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }
          ).toList()..add(
              GestureDetector(
                onTap: () async {
                  String size = await showDialog(context: context, builder: (context) => AddSizeDialog());
                  if(size != null) state.didChange(state.value..add(size));
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)), //Curvinha da borda
                    border: Border.all(
                      color: state.hasError ? Colors.red : Color.fromARGB(254, 242, 193, 94),
                      width: 3,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text('+',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ),
        ),
      );
    }
  );
}