// ============================================================================
// GROUP COMPONENT
// ============================================================================
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'floor.dart';
import 'pathfinder.dart';

const List<Map<String, dynamic>> kGroupConfigs = [
  {
    'id': 'g14',
    'name': 'g14',
    'gx': 1100.0,
    'gy': 1100.0,
    'gw': 1110.0,
    'gh': 1100.0,
    'thickness': 40.0,
    'cornerRadiusTL': 0.0,
    'cornerRadiusTR': 0.0,
    'cornerRadiusBR': 0.0,
    'cornerRadiusBL': 0.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'G14',
    'labelHeight': 2000.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'Q32',
    'name': 'Q32',
    'gx': 300.0,
    'gy': 300.0,
    'gw': 300.0,
    'gh': 300.0,
    'thickness': 3000.0,
    'cornerRadius': 0.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'Q32',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'Q31',
    'name': 'Q31',
    'gx': 300.0,
    'gy': 610.0,
    'gw': 300.0,
    'gh': 300.0,
    'thickness': 3000.0,
    'cornerRadius': 0.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'Q31',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'Q30',
    'name': 'Q30',
    'gx': 300.0,
    'gy': 1110.0,
    'gw': 380.0,
    'gh': 1100.0,
    'thickness': 3000.0,
    'cornerRadius': 0.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'Q30',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'Q29',
    'name': 'Q29',
    'gx': 300.0,
    'gy': 2215.0,
    'gw': 450.0,
    'gh': 600.0,
    'thickness': 3000.0,
    'cornerRadius': 0.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'Q29',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'O21',
    'name': 'O21',
    'gx': 760.0,
    'gy': 2215.0,
    'gw': 180.0,
    'gh': 600.0,
    'thickness': 3000.0,
    'cornerRadius': 0.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'cornerRadiusTL': 0.0,
    'cornerRadiusTR': 0.0,
    'cornerRadiusBR': 50.0,
    'cornerRadiusBL': 0.0,
    'label': '021',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'O22',
    'name': 'O22',
    'gx': 760.0,
    'gy': 1110.0,
    'gw': 180.0,
    'gh': 1100.0,
    'thickness': 3000.0,
    'cornerRadius': 0.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '022',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '023',
    'name': '023',
    'gx': 610.0,
    'gy': 610.0,
    'gw': 300.0,
    'gh': 300.0,
    'thickness': 3000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'O23',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '024',
    'name': '024',
    'gx': 610.0,
    'gy': 300.0,
    'gw': 300.0,
    'gh': 300.0,
    'thickness': 3000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'O24',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'I16',
    'name': 'I16',
    'gx': 1100.0,
    'gy': 300.0,
    'gw': 1100.0,
    'gh': 200.0,
    'thickness': 3000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'I16',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'H15',
    'name': 'H15',
    'gx': 1100.0,
    'gy': 600.0,
    'gw': 1100.0,
    'gh': 300.0,
    'thickness': 3000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'H15',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'G13',
    'name': 'g13',
    'gx': 1200.0,
    'gy': 2400.0,
    'gw': 1050.0,
    'gh': 400.0,
    'thickness': 3000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'cornerRadiusTL': 0.0,
    'cornerRadiusTR': 0.0,
    'cornerRadiusBR': 0.0,
    'cornerRadiusBL': 50.0,
    'label': 'G13',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'N8',
    'name': 'N8',
    'gx': 2400.0,
    'gy': 300.0,
    'gw': 1100.0,
    'gh': 200.0,
    'thickness': 3000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'N8',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'N7',
    'name': 'N7',
    'gx': 2400.0,
    'gy': 600.0,
    'gw': 1100.0,
    'gh': 300.0,
    'thickness': 3000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'N7',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'N6',
    'name': 'N6',
    'gx': 2400.0,
    'gy': 1200.0,
    'gw': 1110.0,
    'gh': 1000.0,
    'thickness': 3000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'N6',
    'labelHeight': 2000.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'N5',
    'name': 'N5',
    'gx': 2400.0,
    'gy': 2400.0,
    'gw': 1100.0,
    'gh': 200.0,
    'thickness': 3000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'N5',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },


    {
    'id': 'NA',
    'name': 'NA',
    'gx': 2400,
    'gy': 2700.0,
    'gw': 1100.0,
    'gh': 100.0,
    'thickness': 3000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'cornerRadiusTL': 50.0,
    'cornerRadiusTR': 0.0,
    'cornerRadiusBR': 50.0,
    'cornerRadiusBL': 0.0,


    'label': 'NA',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },


  {
    'id': 'Q28',
    'name': 'Q28',
    'gx': 300.0,
    'gy': 3500.0,
    'gw': 300.0,
    'gh': 350.0,
    'thickness': 3000.0,
    'cornerRadius': 0.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'cornerRadiusTL': 0.0,
    'cornerRadiusTR': 0.0,
    'cornerRadiusBR': 0.0,
    'cornerRadiusBL': 0.0,
    'label': 'Q28',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'Q20',
    'name': 'Q20',
    'gx': 600.0,
    'gy': 3500.0,
    'gw': 450.0,
    'gh': 350.0,
    'thickness': 3000.0,
    'cornerRadius': 0.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'cornerRadiusTL': 0.0,
    'cornerRadiusTR': 50.0,
    'cornerRadiusBR': 0.0,
    'cornerRadiusBL': 0.0,
    'label': 'Q20',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'E12',
    'name': 'E12',
    'gx': 1300.0,
    'gy': 3500.0,
    'gw': 1000.0,
    'gh': 350.0,
    'thickness': 3000.0,
    'cornerRadius': 0.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'cornerRadiusTL': 50.0,
    'cornerRadiusTR': 0.0,
    'cornerRadiusBR': 0.0,
    'cornerRadiusBL': 0.0,
    'label': 'E12',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'N4',
    'name': 'N4',
    'gx': 2400.0,
    'gy': 3660.0,
    'gw': 1100.0,
    'gh': 200.0,
    'thickness': 3000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'N4',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },


  {
    'id': 'NA2',
    'name': 'NA2',
    'gx': 2400,
    'gy': 3500.0,
    'gw': 1100.0,
    'gh': 100.0,
    'thickness': 3000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'cornerRadiusTL': 0.0,
    'cornerRadiusTR': 50.0,
    'cornerRadiusBR': 0.0,
    'cornerRadiusBL': 0.0,


    'label': 'NA2',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },

  {
    'id': 'memorial',
    'name': 'memorial',
    'gx': 950.0,
    'gy': 2900.0,
    'gw': 500.0,
    'gh': 500.0,
    'thickness': 3000.0,
    'cornerRadius': 300.0, 
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'MEMORIAL',
    'labelHeight': 550.0,
    'labelFontSize': 400.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'SHED',
    'name': 'SHED',
    'gx': 3300.0,
    'gy': 2900.0,
    'gw': 500.0,
    'gh': 500.0,
    'thickness': 3000.0,
    'cornerRadius': 300.0, 
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'SHED',
    'labelHeight': 550.0,
    'labelFontSize': 400.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'Q27',
    'name': 'Q27',
    'gx': 300.0,
    'gy': 4200.0,
    'gw': 300.0,
    'gh': 300.0,
    'thickness': 3000.0,
    'cornerRadius': 0.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'Q27',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'Q26',
    'name': 'Q26',
    'gx': 300.0,
    'gy': 4510.0,
    'gw': 300.0,
    'gh': 300.0,
    'thickness': 3000.0,
    'cornerRadius': 0.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'Q26',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'Q25',
    'name': 'Q25',
    'gx': 300.0,
    'gy': 4820.0,
    'gw': 300.0,
    'gh': 300.0,
    'thickness': 3000.0,
    'cornerRadius': 0.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'Q25',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'BONE DEPOSIT',
    'name': 'BONE DEPOSIT',
    'gx': 610.0,
    'gy': 4820.0,
    'gw': 150.0,
    'gh': 300.0,
    'thickness': 3000.0,
    'cornerRadius': 0.0,
    'visible': true,
    'topColor':     Color.fromARGB(255, 78, 42, 1),
    'outlineColor': Color.fromARGB(255, 0, 0, 0),
    'lightCurb':    Color.fromARGB(255, 78, 42, 1),
    'darkCurb':     Color.fromARGB(255, 78, 42, 1),
    'label': 'BONE DEPOSIT',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'P17',
    'name': 'P17',
    'gx': 770.0,
    'gy': 4820.0,
    'gw': 300.0,
    'gh': 300.0,
    'thickness': 3000.0,
    'cornerRadius': 0.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'P17',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'P18',
    'name': 'P18',
    'gx': 770.0,
    'gy': 4510.0,
    'gw': 300.0,
    'gh': 300.0,
    'thickness': 3000.0,
    'cornerRadius': 0.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'P18',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'P18',
    'name': 'P18',
    'gx': 770.0,
    'gy': 4510.0,
    'gw': 300.0,
    'gh': 300.0,
    'thickness': 3000.0,
    'cornerRadius': 0.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'P18',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'P19',
    'name': 'P19',
    'gx': 770.0,
    'gy': 4200.0,
    'gw': 300.0,
    'gh': 300.0,
    'thickness': 3000.0,
    'cornerRadius': 0.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'P19',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'D11',
    'name': 'D11',
    'gx': 1350.0,
    'gy': 4200.0,
    'gw': 1100.0,
    'gh': 250.0,
    'thickness': 3000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'D11',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'C10',
    'name': 'C10',
    'gx': 1350.0,
    'gy': 4520.0,
    'gw': 1100.0,
    'gh': 250.0,
    'thickness': 3000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'C10',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'B9',
    'name': 'B9',
    'gx': 1350.0,
    'gy': 4860.0,
    'gw': 1100.0,
    'gh': 250.0,
    'thickness': 3000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'B9',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'N3',
    'name': 'N3',
    'gx': 2500.0,
    'gy': 4200.0,
    'gw': 1000.0,
    'gh': 250.0,
    'thickness': 3000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'N3',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'N2',
    'name': 'N2',
    'gx': 2500.0,
    'gy': 4520.0,
    'gw': 1000.0,
    'gh': 250.0,
    'thickness': 3000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'N2',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'N1',
    'name': 'N1',
    'gx': 2500.0,
    'gy': 4860.0,
    'gw': 1000.0,
    'gh': 250.0,
    'thickness': 3000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'N1',
    'labelHeight': 550.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },


   {
    'id': '75',
    'name': '75',
    'gx': 50.0,
    'gy': 200.0,
    'gw': 100.0,
    'gh': 250.0,
    'thickness': 600.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '75',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '74',
    'name': '74',
    'gx': 50.0,
    'gy': 480.0,
    'gw': 100.0,
    'gh': 250.0,
    'thickness': 600.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '74',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '73',
    'name': '73',
    'gx': 50.0,
    'gy': 760.0,
    'gw': 100.0,
    'gh': 250.0,
    'thickness': 600.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '73',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '72',
    'name': '72',
    'gx': 50.0,
    'gy': 1040.0,
    'gw': 100.0,
    'gh': 250.0,
    'thickness': 600.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '72',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '71',
    'name': '71',
    'gx': 50.0,
    'gy': 1320.0,
    'gw': 100.0,
    'gh': 250.0,
    'thickness': 600.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '71',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '70',
    'name': '70',
    'gx': 50.0,
    'gy': 1600.0,
    'gw': 100.0,
    'gh': 250.0,
    'thickness': 600.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '70',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '69',
    'name': '69',
    'gx': 50.0,
    'gy': 1880.0,
    'gw': 100.0,
    'gh': 250.0,
    'thickness': 600.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '69',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '68',
    'name': '68',
    'gx': 50.0,
    'gy': 2160.0,
    'gw': 100.0,
    'gh': 250.0,
    'thickness': 600.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '68',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '67',
    'name': '67',
    'gx': 50.0,
    'gy': 2440.0,
    'gw': 100.0,
    'gh': 250.0,
    'thickness': 600.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '67',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '66',
    'name': '66',
    'gx': 50.0,
    'gy': 2720.0,
    'gw': 100.0,
    'gh': 250.0,
    'thickness': 600.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '66',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '65',
    'name': '65',
    'gx': 50.0,
    'gy': 3000.0,
    'gw': 100.0,
    'gh': 250.0,
    'thickness': 600.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '65',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '64',
    'name': '64',
    'gx': 50.0,
    'gy': 3280.0,
    'gw': 100.0,
    'gh': 250.0,
    'thickness': 600.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '64',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '63',
    'name': '63',
    'gx': 50.0,
    'gy': 3560.0,
    'gw': 100.0,
    'gh': 250.0,
    'thickness': 600.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '63',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'MUSLIM',
    'name': 'MUSLIM',
    'gx': 50.0,
    'gy': 3840.0,
    'gw': 100.0,
    'gh': 1250.0,
    'thickness': 600.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'MUSLIM',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },


  {
    'id': '58',
    'name': '58',
    'gx': 80.0,
    'gy': 5200.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '58',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '57',
    'name': '57',
    'gx': 296.7,
    'gy': 5200.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '57',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '56',
    'name': '56',
    'gx': 513.4,
    'gy': 5200.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '56',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '55',
    'name': '55',
    'gx': 730.0,
    'gy': 5200.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '55',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '54',
    'name': '54',
    'gx': 946.7,
    'gy': 5200.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '54',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '53',
    'name': '53',
    'gx': 1163.4,
    'gy': 5200.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '53',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '52',
    'name': '52',
    'gx': 1380.0,
    'gy': 5200.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '52',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '51',
    'name': '51',
    'gx': 1596.7,
    'gy': 5200.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '51',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '50',
    'name': '50',
    'gx': 1813.4,
    'gy': 5200.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '50',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '49',
    'name': '49',
    'gx': 2030.0,
    'gy': 5200.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '49',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '48',
    'name': '48',
    'gx': 2246.7,
    'gy': 5200.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '48',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '47',
    'name': '47',
    'gx': 2463.4,
    'gy': 5200.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '47',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '46',
    'name': '46',
    'gx': 2680.0,
    'gy': 5200.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '46',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '45',
    'name': '45',
    'gx': 2896.7,
    'gy': 5200.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '45',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '44',
    'name': '44',
    'gx': 3113.4,
    'gy': 5200.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '44',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '43',
    'name': '43',
    'gx': 3330.0,
    'gy': 5200.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '43',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '33',
    'name': '33',
    'gx': 3547.2,
    'gy': 5200.0,
    'gw': 350,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '33',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '34',
    'name': '34',
    'gx': 3650.20,
    'gy': 4800.0,
    'gw': 200,
    'gh': 300.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '34',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '35',
    'name': '35',
    'gx': 3650.20,
    'gy': 4540.0,
    'gw': 200,
    'gh': 200.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '35',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '36',
    'name': '36',
    'gx': 3650.20,
    'gy': 4320.0,
    'gw': 200,
    'gh': 200.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '36',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '37',
    'name': '37',
    'gx': 3650.20,
    'gy': 4100.0,
    'gw': 200,
    'gh': 200.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '37',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': 'CR1',
    'name': 'CR1',
    'gx': 3650.20,
    'gy': 3500.0,
    'gw': 200,
    'gh': 500.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'CR1',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },

  {
    'id': 'CR2',
    'name': 'CR2',
    'gx': 3650.20,
    'gy': 2300.0,
    'gw': 200,
    'gh': 500.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': 'CR2',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },

  {
    'id': '38',
    'name': '38',
    'gx': 3600.0,
    'gy': 1700.0,
    'gw': 300,
    'gh': 400.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '38',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '39',
    'name': '39',
    'gx': 3600.0,
    'gy': 1200.0,
    'gw': 300,
    'gh': 400.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '39',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '40',
    'name': '40',
    'gx': 3600.0,
    'gy': 700.0,
    'gw': 300,
    'gh': 400.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '40',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '41',
    'name': '41',
    'gx': 3600.0,
    'gy': 200.0,
    'gw': 300,
    'gh': 400.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '41',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },


  {
    'id': '76',
    'name': '76',
    'gx': 50.0,
    'gy': 50.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '76',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '77',
    'name': '77',
    'gx': 266.67,
    'gy': 50.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '77',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
 
  {
    'id': '78',
    'name': '78',
    'gx': 483.33,
    'gy': 50.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '78',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '79',
    'name': '79',
    'gx': 700.0,
    'gy': 50.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '79',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '80',
    'name': '80',
    'gx': 916.67,
    'gy': 50.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '80',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '81',
    'name': '81',
    'gx': 1133.33,
    'gy': 50.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '81',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '82',
    'name': '82',
    'gx': 1350.0,
    'gy': 50.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '82',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '83',
    'name': '83',
    'gx': 1566.67,
    'gy': 50.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '83',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '84',
    'name': '84',
    'gx': 1783.33,
    'gy': 50.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '84',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '85',
    'name': '85',
    'gx': 2000.00,
    'gy': 50.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '85',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '86',
    'name': '86',
    'gx': 2216.67,
    'gy': 50.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '86',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '87',
    'name': '87',
    'gx': 2433.33,
    'gy': 50.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '87',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '88',
    'name': '88',
    'gx': 2650.00,
    'gy': 50.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '88',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '89',
    'name': '89',
    'gx': 2866.67,
    'gy': 50.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '89',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '90',
    'name': '90',
    'gx': 3083.33,
    'gy': 50.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '90',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '91',
    'name': '91',
    'gx': 3300.00,
    'gy': 50.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '91',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '92',
    'name': '92',
    'gx': 3516.67,
    'gy': 50.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '92',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
  {
    'id': '42',
    'name': '42',
    'gx': 3733.33,
    'gy': 50.0,
    'gw': 216.67,
    'gh': 90.0,
    'thickness': 1000.0,
    'visible': true,
    'topColor':     Color(0xFFB0B0B0),
    'outlineColor': Color(0xFF8A8A8A),
    'lightCurb':    Color(0xFF7A7A7A),
    'darkCurb':     Color(0xFF5A5A5A),
    'label': '42',
    'labelHeight': 200.0,
    'labelFontSize': 500.0,
    'labelColor': Colors.white,
    'labelOutlineColor': Colors.black,
  },
];

const String kDefaultFocusGroupId = 'g14';

Map<String, dynamic>? getFocusGroupConfig() {
  for (final g in kGroupConfigs) {
    if (g['id'] == kDefaultFocusGroupId) return g;
  }
  return kGroupConfigs.isNotEmpty ? kGroupConfigs.first : null;
}

double _num(Map<String, dynamic> m, String k, double fallback) =>
    (m[k] as num?)?.toDouble() ?? fallback;

class GroupBounds {
  final double gx, gy, gw, gh;
  const GroupBounds(this.gx, this.gy, this.gw, this.gh);

  double get left => gx;
  double get top => gy;
  double get right => gx + gw;
  double get bottom => gy + gh;
  double get centerX => gx + gw / 2;
  double get centerY => gy + gh / 2;
}

GroupBounds? getFocusGroupBounds() {
  final cfg = getFocusGroupConfig();
  if (cfg == null) return null;
  return GroupBounds(
    _num(cfg, 'gx', 0),
    _num(cfg, 'gy', 0),
    _num(cfg, 'gw', 0),
    _num(cfg, 'gh', 0),
  );
}

class Group extends StatelessWidget {
  const Group({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([Floor.repaint, Pathfinder.current]),
      builder: (_, __) {
        return CustomPaint(
          size: Size(Floor.canvasWidth, Floor.canvasHeight),
          painter: _GroupPainter(),
        );
      },
    );
  }
}

class _GroupPainter extends CustomPainter {
  _GroupPainter()
      : super(repaint: Listenable.merge([Floor.repaint, Pathfinder.current]));

  static final Map<String, (TextPainter, TextPainter)> _labelCache = {};

  static const int _cornerSegments = 8;

  Paint get _fade =>
      Paint()..color = Colors.white.withOpacity(Pathfinder.seeThroughOpacity);

  @override
  void paint(Canvas canvas, Size size) {
    final visible = <Map<String, dynamic>>[];
    for (final cfg in kGroupConfigs) {
      if (cfg['visible'] == false) continue;
      final gw = _num(cfg, 'gw', 0);
      final gh = _num(cfg, 'gh', 0);
      if (gw <= 0 || gh <= 0) continue;
      visible.add(cfg);
    }

    final depth = <Map<String, dynamic>, double>{};
    for (final cfg in visible) {
      final gx = _num(cfg, 'gx', 0);
      final gy = _num(cfg, 'gy', 0);
      final gw = _num(cfg, 'gw', 0);
      final gh = _num(cfg, 'gh', 0);
      final p1 = Floor.project(gx, gy);
      final p2 = Floor.project(gx + gw, gy);
      final p3 = Floor.project(gx + gw, gy + gh);
      final p4 = Floor.project(gx, gy + gh);
      depth[cfg] = math.max(math.max(p1.dy, p2.dy), math.max(p3.dy, p4.dy));
    }

    visible.sort((a, b) {
      final da = depth[a] ?? double.negativeInfinity;
      final db = depth[b] ?? double.negativeInfinity;
      final c = da.compareTo(db);
      if (c != 0) return c;
      return _num(a, 'gx', 0).compareTo(_num(b, 'gx', 0));
    });

    final affected = _affectedGroups(visible);

    for (final cfg in visible) {
      _drawGroup(canvas, cfg, affected.contains(cfg));
    }
    for (final cfg in visible) {
      _drawGroupLabel(canvas, cfg, affected.contains(cfg));
    }
  }

  (List<Offset>, double) _outline(Map<String, dynamic> cfg) {
    final gx = _num(cfg, 'gx', 0);
    final gy = _num(cfg, 'gy', 0);
    final gw = _num(cfg, 'gw', 0);
    final gh = _num(cfg, 'gh', 0);
    final thickness = _num(cfg, 'thickness', 40.0);

    final legacy = _num(cfg, 'cornerRadius', 0.0);
    final cap = math.min(gw, gh) / 2;
    final rTL = _num(cfg, 'cornerRadiusTL', legacy).clamp(0.0, cap).toDouble();
    final rTR = _num(cfg, 'cornerRadiusTR', legacy).clamp(0.0, cap).toDouble();
    final rBR = _num(cfg, 'cornerRadiusBR', legacy).clamp(0.0, cap).toDouble();
    final rBL = _num(cfg, 'cornerRadiusBL', legacy).clamp(0.0, cap).toDouble();

    final world = _roundedRectWorld(
      gx, gy, gw, gh,
      rTL, rTR, rBR, rBL,
      _cornerSegments,
    );
    return ([for (final p in world) Floor.project(p.dx, p.dy)], thickness);
  }

  Set<Map<String, dynamic>> _affectedGroups(
    List<Map<String, dynamic>> visible,
  ) {
    final out = Set<Map<String, dynamic>>.identity();
    final route = Pathfinder.current.value;
    if (route == null || route.points.length < 2) return out;

    final pts = [for (final p in route.points) Floor.project(p.dx, p.dy)];
    final half = Pathfinder.maxLineWidth / 2;
    const step = 40.0;

    final samples = <Offset>[];
    for (int k = 1; k < pts.length; k++) {
      final a = pts[k - 1];
      final b = pts[k];
      final n = math.max(1, ((b - a).distance / step).ceil());
      for (int t = (k == 1 ? 0 : 1); t <= n; t++) {
        final p = Offset.lerp(a, b, t / n)!;
        samples.add(p);
        samples.add(p + Offset(-half, 0));
        samples.add(p + Offset(half, 0));
      }
    }

    for (final cfg in visible) {
      final (sp, thickness) = _outline(cfg);
      if (sp.length < 3) continue;

      double minX = double.infinity, maxX = -double.infinity;
      double minY = double.infinity, maxY = -double.infinity;
      for (final p in sp) {
        minX = math.min(minX, p.dx);
        maxX = math.max(maxX, p.dx);
        minY = math.min(minY, p.dy);
        maxY = math.max(maxY, p.dy);
      }
      minY -= thickness;
      final bounds = Rect.fromLTRB(minX, minY, maxX, maxY);

      final candidates = <Offset>[
        for (final s in samples)
          if (bounds.contains(s)) s,
      ];
      if (candidates.isEmpty) continue;

      final polys = <List<Offset>>[
        sp,
        [for (final p in sp) p - Offset(0, thickness)],
      ];
      for (int i = 0; i < sp.length; i++) {
        final a = sp[i];
        final b = sp[(i + 1) % sp.length];
        polys.add([a, b, b - Offset(0, thickness), a - Offset(0, thickness)]);
      }

      outer:
      for (final s in candidates) {
        for (final poly in polys) {
          if (_inPoly(s, poly)) {
            out.add(cfg);
            break outer;
          }
        }
      }
    }
    return out;
  }

  bool _inPoly(Offset p, List<Offset> poly) {
    bool inside = false;
    for (int i = 0, j = poly.length - 1; i < poly.length; j = i++) {
      final a = poly[i];
      final b = poly[j];
      if ((a.dy > p.dy) != (b.dy > p.dy) &&
          p.dx < (b.dx - a.dx) * (p.dy - a.dy) / (b.dy - a.dy) + a.dx) {
        inside = !inside;
      }
    }
    return inside;
  }

  void _drawGroup(Canvas canvas, Map<String, dynamic> cfg, bool faded) {
    final gx = _num(cfg, 'gx', 0);
    final gy = _num(cfg, 'gy', 0);
    final gw = _num(cfg, 'gw', 0);
    final gh = _num(cfg, 'gh', 0);
    final thickness = _num(cfg, 'thickness', 40.0);

    if (gw <= 0 || gh <= 0) return;

    final legacy = _num(cfg, 'cornerRadius', 0.0);
    final cap = math.min(gw, gh) / 2;
    final rTL = _num(cfg, 'cornerRadiusTL', legacy).clamp(0.0, cap).toDouble();
    final rTR = _num(cfg, 'cornerRadiusTR', legacy).clamp(0.0, cap).toDouble();
    final rBR = _num(cfg, 'cornerRadiusBR', legacy).clamp(0.0, cap).toDouble();
    final rBL = _num(cfg, 'cornerRadiusBL', legacy).clamp(0.0, cap).toDouble();

    final topColor     = (cfg['topColor']     as Color?) ?? const Color(0xFFB0B0B0);
    final outlineColor = (cfg['outlineColor'] as Color?) ?? const Color(0xFF8A8A8A);
    final lightCurb    = (cfg['lightCurb']    as Color?) ?? const Color(0xFF7A7A7A);
    final darkCurb     = (cfg['darkCurb']     as Color?) ?? const Color(0xFF5A5A5A);

    final worldPts = _roundedRectWorld(
      gx, gy, gw, gh,
      rTL, rTR, rBR, rBL,
      _cornerSegments,
    );
    final screenPts = worldPts.map((p) => Floor.project(p.dx, p.dy)).toList();
    if (_isDegenerate(screenPts)) return;

    if (faded) {
      double minX = double.infinity, maxX = -double.infinity;
      double minY = double.infinity, maxY = -double.infinity;
      for (final p in screenPts) {
        minX = math.min(minX, p.dx);
        maxX = math.max(maxX, p.dx);
        minY = math.min(minY, p.dy);
        maxY = math.max(maxY, p.dy);
      }
      final layerBounds =
          Rect.fromLTRB(minX - 20, minY - thickness - 20, maxX + 30, maxY + 30);
      canvas.saveLayer(layerBounds, _fade);
    }

    final midTop    = Floor.project(gx + gw / 2, gy);
    final midBottom = Floor.project(gx + gw / 2, gy + gh);
    final midLeft   = Floor.project(gx, gy + gh / 2);
    final midRight  = Floor.project(gx + gw, gy + gh / 2);

    final nearIsTopEdge  = midTop.dy  > midBottom.dy;
    final nearIsLeftEdge = midLeft.dy > midRight.dy;

    final shadow = Path();
    for (int i = 0; i < screenPts.length; i++) {
      final p = screenPts[i] + const Offset(6, 8);
      if (i == 0) {
        shadow.moveTo(p.dx, p.dy);
      } else {
        shadow.lineTo(p.dx, p.dy);
      }
    }
    shadow.close();
    canvas.drawPath(shadow, Paint()..color = Colors.black26);

    final edges = <_SideEdge>[];
    for (int i = 0; i < screenPts.length; i++) {
      final a = screenPts[i];
      final b = screenPts[(i + 1) % screenPts.length];

      final wa = worldPts[i];
      final wb = worldPts[(i + 1) % worldPts.length];
      final cx = (wa.dx + wb.dx) / 2 - gx;
      final cy = (wa.dy + wb.dy) / 2 - gy;

      final dTop    = cy;
      final dBottom = gh - cy;
      final dLeft   = cx;
      final dRight  = gw - cx;
      final dMin = [dTop, dBottom, dLeft, dRight].reduce(math.min);

      final bool onTop    = dMin == dTop;
      final bool onBottom = dMin == dBottom;

      final bool isHorizEdge = onTop || onBottom;
      final Color base = isHorizEdge ? lightCurb : darkCurb;

      final edgeDepth = (a.dy + b.dy) / 2;
      edges.add(_SideEdge(a, b, base, edgeDepth));
    }

    edges.sort((a, b) => a.depth.compareTo(b.depth));

    for (final e in edges) {
      _drawSideQuad(canvas, e.a, e.b, thickness, e.color);
    }

    final topPath = Path();
    for (int i = 0; i < screenPts.length; i++) {
      final p = screenPts[i] - Offset(0, thickness);
      if (i == 0) {
        topPath.moveTo(p.dx, p.dy);
      } else {
        topPath.lineTo(p.dx, p.dy);
      }
    }
    topPath.close();

    canvas.drawPath(topPath, Paint()..color = topColor);
    canvas.drawPath(
      topPath,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );

    final cornerPaint = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..strokeWidth = 1.4;

    void guide(Offset mid, bool near, double rA, double rB) {
      if (!near) return;
      if (rA > 1.0 || rB > 1.0) return;
      canvas.drawLine(mid, mid - Offset(0, thickness), cornerPaint);
    }

    guide(midTop,    nearIsTopEdge,   rTL, rTR);
    guide(midBottom, !nearIsTopEdge,  rBL, rBR);
    guide(midLeft,   nearIsLeftEdge,  rTL, rBL);
    guide(midRight,  !nearIsLeftEdge, rTR, rBR);

    if (faded) canvas.restore();
  }

  bool _isDegenerate(List<Offset> pts) {
    if (pts.length < 2) return true;
    final first = pts.first;
    for (final p in pts) {
      if ((p - first).distance > 0.5) return false;
    }
    return true;
  }

  void _drawSideQuad(
    Canvas canvas,
    Offset a,
    Offset b,
    double thickness,
    Color color,
  ) {
    final aTop = a - Offset(0, thickness);
    final bTop = b - Offset(0, thickness);
    final p = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(bTop.dx, bTop.dy)
      ..lineTo(aTop.dx, aTop.dy)
      ..close();
    canvas.drawPath(p, Paint()..color = color);
    canvas.drawPath(
      p,
      Paint()
        ..color = Colors.black.withOpacity(0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  List<Offset> _roundedRectWorld(
    double gx,
    double gy,
    double gw,
    double gh,
    double rTL,
    double rTR,
    double rBR,
    double rBL,
    int segs,
  ) {
    if (rTL <= 0 && rTR <= 0 && rBR <= 0 && rBL <= 0) {
      return <Offset>[
        Offset(gx, gy),
        Offset(gx + gw, gy),
        Offset(gx + gw, gy + gh),
        Offset(gx, gy + gh),
      ];
    }

    final pts = <Offset>[];

    if (rTL > 0) {
      final c = Offset(gx + rTL, gy + rTL);
      for (int i = 0; i <= segs; i++) {
        final a = math.pi + (math.pi / 2) * (i / segs);
        pts.add(Offset(c.dx + rTL * math.cos(a), c.dy + rTL * math.sin(a)));
      }
    } else {
      pts.add(Offset(gx, gy));
    }

    if (rTR > 0) {
      final c = Offset(gx + gw - rTR, gy + rTR);
      for (int i = 0; i <= segs; i++) {
        final a = 3 * math.pi / 2 + (math.pi / 2) * (i / segs);
        pts.add(Offset(c.dx + rTR * math.cos(a), c.dy + rTR * math.sin(a)));
      }
    } else {
      pts.add(Offset(gx + gw, gy));
    }

    if (rBR > 0) {
      final c = Offset(gx + gw - rBR, gy + gh - rBR);
      for (int i = 0; i <= segs; i++) {
        final a = (math.pi / 2) * (i / segs);
        pts.add(Offset(c.dx + rBR * math.cos(a), c.dy + rBR * math.sin(a)));
      }
    } else {
      pts.add(Offset(gx + gw, gy + gh));
    }

    if (rBL > 0) {
      final c = Offset(gx + rBL, gy + gh - rBL);
      for (int i = 0; i <= segs; i++) {
        final a = math.pi / 2 + (math.pi / 2) * (i / segs);
        pts.add(Offset(c.dx + rBL * math.cos(a), c.dy + rBL * math.sin(a)));
      }
    } else {
      pts.add(Offset(gx, gy + gh));
    }

    return pts;
  }

  void _drawGroupLabel(
    Canvas canvas,
    Map<String, dynamic> cfg,
    bool faded,
  ) {
    final label = (cfg['label'] as String?)?.trim() ?? '';
    if (label.isEmpty) return;

    final gx = _num(cfg, 'gx', 0);
    final gy = _num(cfg, 'gy', 0);
    final gw = _num(cfg, 'gw', 0);
    final gh = _num(cfg, 'gh', 0);
    final thickness = _num(cfg, 'thickness', 40.0);

    if (gw <= 0 || gh <= 0) return;

    final labelHeight = _num(cfg, 'labelHeight', 550.0);
    final fontSize    = _num(cfg, 'labelFontSize', 260.0);

    final fillColor    = (cfg['labelColor']        as Color?) ?? Colors.white;
    final outlineColor = (cfg['labelOutlineColor'] as Color?) ?? Colors.black;

    final centre = Floor.project(gx + gw / 2, gy + gh / 2);
    final anchor = Offset(
      centre.dx,
      centre.dy - thickness - labelHeight,
    );

    final (strokeTp, fillTp) = _labelFor(
      text: label,
      fontSize: fontSize,
      fillColor: fillColor,
      outlineColor: outlineColor,
    );

    final topLeft = Offset(
      anchor.dx - fillTp.width / 2,
      anchor.dy - fillTp.height / 2,
    );

    if (faded) {
      final pad = fontSize * 0.5;
      canvas.saveLayer(
        Rect.fromLTWH(
          topLeft.dx - pad,
          topLeft.dy - pad,
          fillTp.width + pad * 2,
          fillTp.height + pad * 2,
        ),
        _fade,
      );
    }

    strokeTp.paint(canvas, topLeft);
    fillTp.paint(canvas, topLeft);

    if (faded) canvas.restore();
  }

  (TextPainter, TextPainter) _labelFor({
    required String text,
    required double fontSize,
    required Color fillColor,
    required Color outlineColor,
  }) {
    final key = '$text|$fontSize|${fillColor.value}|${outlineColor.value}';
    final cached = _labelCache[key];
    if (cached != null) return cached;

    final strokeTp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: fontSize * 0.03,
          foreground: Paint()
            ..color = outlineColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = fontSize * 0.16
            ..strokeJoin = StrokeJoin.round,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final fillTp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: fillColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: fontSize * 0.03,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.7),
              blurRadius: fontSize * 0.20,
              offset: Offset(fontSize * 0.06, fontSize * 0.06),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    _labelCache[key] = (strokeTp, fillTp);
    return (strokeTp, fillTp);
  }

  @override
  bool shouldRepaint(covariant _GroupPainter oldDelegate) => true;
}

class _SideEdge {
  final Offset a;
  final Offset b;
  final Color color;
  final double depth;
  _SideEdge(this.a, this.b, this.color, this.depth);
}