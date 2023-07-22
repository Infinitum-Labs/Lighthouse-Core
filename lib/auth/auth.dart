library core.auth;

import 'dart:convert';

import 'package:lighthouse_core/utils/utils.dart';

part './jwt.dart';
part './access_key.dart';
part './permissions.dart';

const secret = String.fromEnvironment('jwtSecret', defaultValue: 'secret');
