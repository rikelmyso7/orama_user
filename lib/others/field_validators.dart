class FieldValidators {
  FieldValidators._();
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Campo obrigatório";
    }

    if (value.contains(' ')) {
      return "E-mail não pode conter espaços";
    }

    const pattern = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
        r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
        r"(?:\.[a-zA-Z]{2,})+$";

    final regex = RegExp(pattern);

    if (!regex.hasMatch(value)) {
      return "E-mail inválido";
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return ("Campo obrigatório");
    }
    if (value.length < 6) {
      return ("Senha precisa ter pelo menos 6 dígitos");
    }
    if (value.length > 20) {
      return ("Senha pode ter até 20 dígitos");
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return ("Campo obrigatório");
    }
    return null;
  }

  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return ("Campo obrigatório");
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
