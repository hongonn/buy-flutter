// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login-body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginBody _$LoginBodyFromJson(Map<String, dynamic> json) {
  return LoginBody(
    json['username'] as String,
    json['password'] as String,
  );
}

Map<String, dynamic> _$LoginBodyToJson(LoginBody instance) => <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };