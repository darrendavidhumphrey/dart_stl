import 'dart:io';
import 'package:vector_math/vector_math_64.dart' show Triangle, Vector3;

/// A class for saving triangle lists to ASCII STL files or Strings
class StlWriter {
  /// Helper function that tries to eliminate outputting "-0.0"
  /// It takes a single double parameter [d]
  /// and returns a double
  static double _fixDouble(double d) {
    const closeToZero = 0.00000001;
    if (d.abs() < closeToZero) {
      d = 0;
    }

    return d;
  }

  /// Helper function for converting a single vertex to STL
  /// It takes two parameters a [prefix] which is output at
  /// the start of the string, and a Vector3 [v] containing the
  /// vertex data
  ///
  static String _vertexToSTL(String prefix, Vector3 v) {
    double x = _fixDouble(v.x);
    double y = _fixDouble(v.y);
    double z = _fixDouble(v.z);

    String sx = x.toStringAsFixed(6);
    String sy = y.toStringAsFixed(6);
    String sz = z.toStringAsFixed(6);
    return "$prefix $sx $sy $sz";
  }

  /// Saves a list of triangles as an ASCII STL file
  /// Takes a [filename] parameter, an [objectName] which is emitted
  /// at the top of the STL file, e.g. 'solid objectName'
  /// and a list of triangles [tris]
  static void writeSTL(
    String fileName,
    String objectName,
    List<Triangle> tris,
  ) {
    File(fileName).writeAsStringSync(toSTL(objectName, tris));
  }

  // Write a line to a string with the OS specific terminator
  static String _writeLn(String line) {
    return line + Platform.lineTerminator;
  }

  /// Converts a list of triangles to a string in ASCII STL format
  /// Takes an [objectName] which is emitted at the top of the STL file,
  /// e.g. 'solid objectName' and a list of triangles [tris]
  /// and returns a string containing the STL data
  static String toSTL(String objectName, List<Triangle> tris) {
    String result = _writeLn("solid $objectName");
    const String vertexTag = "        vertex";

    for (var tri in tris) {
      Vector3 normal = Vector3.zero();
      tri.copyNormalInto(normal);
      result += _writeLn(_vertexToSTL("facet normal", normal));
      result += _writeLn("    outer loop");
      result += _writeLn(_vertexToSTL(vertexTag, tri.point0));
      result += _writeLn(_vertexToSTL(vertexTag, tri.point1));
      result += _writeLn(_vertexToSTL(vertexTag, tri.point2));
      result += _writeLn("    endloop");
      result += _writeLn("endfacet");
    }

    result += _writeLn("endsolid $objectName");
    return result;
  }
}
