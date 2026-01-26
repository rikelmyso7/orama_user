class FieldValidators {
  FieldValidators._();
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return ("Campo obrigatório");
    }
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
    if (!emailValid) return ("E-mail inválido");
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    if (value.contains(' ')) {
      return 'A senha não pode conter espaços';
    }
    if (value.length < 6) {
      return 'Senha precisa ter pelo menos 6 caracteres';
    }
    if (value.length > 20) {
      return 'Senha pode ter até 20 caracteres';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  static String? validateMoney(String? value) {
  if (value == null || value.isEmpty) {
    return 'Informe um valor válido.';
  }
  final number = double.tryParse(value);
  if (number == null) {
    return 'Digite um valor numérico.';
  }
  return null;
}

}
