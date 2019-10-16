import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gerente_loja/blocs/orders_bloc.dart';
import 'package:gerente_loja/blocs/user_bloc.dart';
import 'package:gerente_loja/tabs/coupons_tab.dart';
import 'package:gerente_loja/tabs/news_tab.dart';
import 'package:gerente_loja/tabs/orders_tab.dart';
import 'package:gerente_loja/tabs/products_tab.dart';
import 'package:gerente_loja/tabs/users_tab.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gerente_loja/widgets/add_new_coupon.dart';
import 'package:gerente_loja/widgets/add_new_image.dart';
import 'package:gerente_loja/widgets/edit_category_dialog.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  PageController _pageController;
  int _page = 0;
  
  UserBloc _userBloc;
  OrdersBloc _ordersBloc;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _userBloc = UserBloc();
    _ordersBloc = OrdersBloc();
  }


  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Color.fromARGB(254, 242, 193, 94),
          primaryColor: Colors.grey[850],
          textTheme: Theme.of(context).textTheme.copyWith(
            caption: TextStyle(color: Colors.grey[850]),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _page,
            onTap: (p){
              _pageController.animateToPage(
                  p,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.ease);
            },
            items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.grey[850]),
            title: Text('Clientes', style: TextStyle(color: Colors.grey[850])),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, color: Colors.grey[850]),
            title: Text('Pedidos', style: TextStyle(color: Colors.grey[850])),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list, color: Colors.grey[850]),
            title: Text('Produtos', style: TextStyle(color: Colors.grey[850])),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard, color: Colors.grey[850]),
            title: Text('Cupons', style: TextStyle(color: Colors.grey[850])),
          ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_to_home_screen, color: Colors.grey[850]),
                title: Text('Novidades', style: TextStyle(color: Colors.grey[850])),
              ),
        ]),

      ),
      body: SafeArea( // Considera a barra padrão Android e IOS onde tem notificações de bateria etc. Dessa forma coloca a estrutura a partir dela.
        child: BlocProvider<UserBloc>(
          bloc: _userBloc,
          child: BlocProvider<OrdersBloc>(
            bloc: _ordersBloc,
            child: PageView(
              controller: _pageController,
              onPageChanged: (p){
                setState(() {
                  _page = p;
                });
              },
              children: <Widget>[
                UsersTab(),
                OrdersTab(),
                ProductsTab(),
                CouponsTab(),
                NewsTab(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloating(),
    );
  }

  Widget _buildFloating(){
    switch(_page){
      case 0:
        return null;

      case 1:
        return SpeedDial(
          child: Icon(Icons.sort, color: Colors.grey[850],),
          backgroundColor: Color.fromARGB(254, 242, 193, 94),
          overlayOpacity: 0.4, // surge um fundo transparete para dar contraste com o botao
          overlayColor: Colors.black,
          children:[
            SpeedDialChild(
              child: Icon(Icons.arrow_downward, color: Colors.grey[850],),
              backgroundColor: Colors.white,
              label: 'Concluidos Abaixo',
              labelStyle: TextStyle(fontSize: 14),
              onTap: (){
                _ordersBloc.setOrderCriteria(SortCriteria.READY_LAST);
              }
            ),
            SpeedDialChild(
                child: Icon(Icons.arrow_upward, color: Colors.grey[850],),
                backgroundColor: Colors.white,
                label: 'Concluidos Acima',
                labelStyle: TextStyle(fontSize: 14),
                onTap: (){
                  _ordersBloc.setOrderCriteria(SortCriteria.READY_FIRST);
                }
            ),
          ], // Definindo os subBotões
        );
      case 2:
        return FloatingActionButton(
          child: Icon(Icons.add, color: Colors.grey[850]),
          backgroundColor: Color.fromARGB(254, 242, 193, 94),
          onPressed: (){
            showDialog(
              context: context,
              builder: (context) => EditCategoryDialog(),
            );
          },
        );
      case 3:
        return FloatingActionButton(
          child: Icon(Icons.add, color: Colors.grey[850]),
          backgroundColor: Color.fromARGB(254, 242, 193, 94),
          onPressed: (){
            showDialog(
              context: context,
              builder: (context) => AddNewCoupon(),
            );
          },
        );
      case 4:
        return FloatingActionButton(
          child: Icon(Icons.add, color: Colors.grey[850]),
          backgroundColor: Color.fromARGB(254, 242, 193, 94),
          onPressed: (){
            showDialog(
              context: context,
              builder: (context) => AddNewImage(),
            );
          },
        );
    }
  }
}
