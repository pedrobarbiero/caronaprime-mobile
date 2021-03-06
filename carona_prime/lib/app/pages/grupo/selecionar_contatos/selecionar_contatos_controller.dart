import 'package:contacts_service/contacts_service.dart';
import 'package:mobx/mobx.dart';
import 'package:simple_permissions/simple_permissions.dart';
part 'selecionar_contatos_controller.g.dart';

class SelecionarContatosController = SelecionarContatosBase
    with _$SelecionarContatosController;

abstract class SelecionarContatosBase with Store {
  @observable
  ObservableList<Contact> todosContatos = ObservableList<Contact>();

  @observable
  ObservableList<Contact> contatosSelecionados = ObservableList<Contact>();

  @observable
  bool carregouContato = false;

  @observable
  String query = "";

  @computed
  List<Contact> get contatosFiltrados {
    if (query != null && query.isNotEmpty)
      return todosContatos
          .where(
              (c) => c.displayName.toUpperCase().contains(query.toUpperCase()))
          .toList();

    return todosContatos;
  }

  @action
  void adicionarContatoSelecionado(Contact contact) =>
      contatosSelecionados.add(contact);

  @action
  void removerContatoSelecionado(Contact contact) =>
      contatosSelecionados.remove(contact);

  @action
  setQuery(String value) => query = value;

  @action
  Future loadContacts() async {
    try {
      await SimplePermissions.requestPermission(Permission.ReadContacts);
      if (await SimplePermissions.checkPermission(Permission.ReadContacts)) {
        var contatos = await ContactsService.getContacts();
        todosContatos.clear();
        todosContatos.addAll(contatos);
        carregouContato = true;
      }
    } catch (e) {
      print(e.toString());
      carregouContato = false;
    }
  }

  String textNotEmptyValidator(String text) {
    if (text == null || text.isEmpty) return "Deve ser informado.";

    return null;
  }
}
