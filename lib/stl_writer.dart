import 'dart:io';
import 'package:vector_math/vector_math.dart' show Triangle,Vector3;

enum StlToken { solid, endSolid, facet, endFacet, loop, endLoop, vertex, error }


  String writeLn(String line) {
    return line + Platform.lineTerminator;
  }


class StlWriter {

  static String vertexToSTL(String tag,Vector3 v) {
      String sx = v.x.toStringAsFixed(6);
      String sy = v.y.toStringAsFixed(6);
      String sz = v.z.toStringAsFixed(6);
      return "$tag $sx $sy $sz";
  }

  static void writeSTL(File f,String objectName,List<Triangle> tris) {
    f.writeAsStringSync(toSTL(objectName,tris));
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