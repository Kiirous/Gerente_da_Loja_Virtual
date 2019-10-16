import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gerente_loja/blocs/user_bloc.dart';
import 'package:gerente_loja/widgets/user_tile.dart';

class UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final _userBloc = BlocProvider.of<UserBloc>(context);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Pesquisar',
              hintStyle: TextStyle(color: Colors.white),
              icon: Icon(Icons.search, color: Colors.white),
              border: InputBorder.none,
            ),
            onChanged: _userBloc.onChangedSearch,
          ),
        ),
        Expanded( //Permite expandir infinitamente a tela na vertical no caso.
          child: StreamBuilder<List>(
            stream: _userBloc.outUsers,
            builder: (context, snapshot) {
              if(!snapshot.hasData)
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color.fromARGB(254, 242, 193, 94),
                    ),
                  ),
                );
              else if(snapshot.data.length == 0)
                return Center(
                  child: Text('Nenhum usuário encontrado', style: TextStyle(
                    color: Colors.white,
                  ),
                  ),
                );
              return ListView.separated(
                  itemBuilder: (context, index){
                    return UserTile(snapshot.data[index]);
                  },
                  separatorBuilder: (context, index){
                    return Divider( color: Color.fromARGB(254, 242, 193, 94));
                  },
                  itemCount: snapshot.data.length,
              );
            }
          ),
        ),
      ],
    );
  }
}
