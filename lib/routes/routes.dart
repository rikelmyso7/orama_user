import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:orama_user/auth/authStateSwitcher.dart';
import 'package:orama_user/pages/login_page.dart';
import 'package:orama_user/pages/user/user_add_descartaveis.dart';
import 'package:orama_user/pages/user/user_add_sorvetes.dart';
import 'package:orama_user/pages/user/user_comandas_page.dart';
import 'package:orama_user/pages/user/user_descartaveis_page.dart';
import 'package:orama_user/pages/user/user_descartaveis_select.dart';

class RouteName {
  static const auth = '/';
  static const login = "/login";

  static const user_add_sorvetes = "/user_add_sorvetes";
  static const user_add_descartaveis = "/user_add_descartaveis";
  static const user_sabores_page = "/user_sabores_page";
  static const user_comandas_page = "/user_comandas_pages";
  static const user_descartaveis_page = "/user_descartaveis_pages";
  static const user_descartaveis_select = "/user_descartaveis_select";
}

class Routes {
  Routes._();
  static final routes = {
    RouteName.auth: (BuildContext context) {
      return AuthStateSwitcher();
    },
    RouteName.login: (BuildContext context) {
      return LoginPage();
    },


    RouteName.user_add_sorvetes: (BuildContext context) {
      return UserAddSorvetes();
    },
    RouteName.user_add_descartaveis: (BuildContext context) {
      return UserAddDescartaveis();
    },
    RouteName.user_descartaveis_select: (BuildContext context) {
      return UserDescartaveisSelect(
        pdv: '',
        nome: '',
        data: '', userId: GetStorage().read('userId'),
      );
    },
    RouteName.user_comandas_page: (BuildContext context) {
      return UserComandasPage();
    },
    RouteName.user_descartaveis_page: (BuildContext context) {
      return UserDescartaveisPage();
    },
  };
}
