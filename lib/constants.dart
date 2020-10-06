import 'models.dart';

const Map<String, Rule> kRules = {
  'C': Rule(color: true), // same colour
  'N': Rule(number: true), // multiples of number N, e.g. 2, 4, 6..
  'NC': Rule(number: true, color: true), // multiples of N that are of same colour 
  'TC': Rule(timer: true, color: true), // same colour but within timer
  'TN': Rule(timer: true, number: true), // multiples of N but within timer
  'TNC': Rule(timer: true, number: true, color: true), // multiples of N that are of same colour but within timer
};
