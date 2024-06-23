import 'dart:io';
import 'package:vector_math/vector_math_64.dart' show Triangle,Vector3;

enum StlToken { solid, endSolid, facet, endFacet, loop, endLoop, vertex, error }


  String writeLn(String line) {
    return line + Platform.lineTerminator;
  }


class StlWriter {

  // Try to eliminate outputting "-0.0"
  static double fixDouble(double d) {
    const closeToZero = 0.00000001;
    if (d.abs() < closeToZero) {
      d = 0;
    }

    return d;
  }
  static String vertexToSTL(String tag,Vector3 v) {

      double x = fixDouble(v.x);
      double y = fixDouble(v.y);
      double z = fixDouble(v.z);

      String sx = x.toStringAsFixed(6);
      String sy = y.toStringAsFixed(6);
      String sz = z.toStringAsFixed(6);
      return "$tag $sx $sy $sz";
  }

  static void writeSTL(String fileName,String objectName,List<Triangle> tris) {
    File(fileName).writeAsStringSync(toSTL(objectName,tris));
  }


  static String toSTL(String objectName,List<Triangle> tris) {
    String result = writeLn("solid $objectName");
    String vertexTag = "        vertex";
    for (var tri in tris) {
      Vector3 normal = Vector3.zero();
      tri.copyNormalInto(normal);
      result += writeLn(vertexToSTL("facet normal",normal));
      result += writeLn("    outer loop");
      result += writeLn(vertexToSTL(vertexTag,tri.point0));
      result += writeLn(vertexToSTL(vertexTag,tri.point1));
      result += writeLn(vertexToSTL(vertexTag,tri.point2));
      result += writeLn("    endloop");
      result += writeLn("endfacet");
    }

    result += writeLn("endsolid $objectName");
    return result;
  }
}