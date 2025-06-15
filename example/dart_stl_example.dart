import 'dart:io';

import 'package:dart_stl/stl_reader.dart';
import 'package:dart_stl/stl_writer.dart';
import 'package:vector_math/vector_math_64.dart' show Triangle;

void main() {
  /// Read STL file, returning a list of Triangle
  File bunnyFile = File('bunny.stl');
  List<Triangle>? tris = StlReader.loadSTLFile(bunnyFile);

  /// Write a list of Triangles to an STL file
  StlWriter.writeSTL("bunny2.stl", "bunny", tris!);

  /// Write a list of Triangles to a string
  String bunnySTL = StlWriter.toSTL("bunny", tris);

  // Convert string back into list of Triangle
  List<Triangle>? bunnyTriangles2 = StlReader.fromSTL(bunnySTL);
}
