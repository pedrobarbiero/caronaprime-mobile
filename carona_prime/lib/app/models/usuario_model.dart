import 'package:json_annotation/json_annotation.dart';

part 'usuario_model.g.dart';

@JsonSerializable()
class UsuarioModel {
  int id;
  String nome;
  String celular;

  UsuarioModel(this.nome, this.celular, {this.id});

  factory UsuarioModel.fromJson(Map<String, dynamic> json) =>
      _$UsuarioModelFromJson(json);
  Map<String, dynamic> toJson() => _$UsuarioModelToJson(this);
}
