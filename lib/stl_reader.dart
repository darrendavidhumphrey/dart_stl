import 'dart:convert';
import 'dart:io';
import 'package:vector_math/vector_math_64.dart' show Triangle,Vector3;

enum StlToken { solid, endSolid, facet, endFacet, loop, endLoop, vertex, error }

class StlReader {
  static StlToken tokenType(String s) {
    String line = s.toLowerCase().trimLeft();

    if (line.startsWith("solid")) {
      return StlToken.solid;
    } else if (line.startsWith("endsolid")) {
      return StlToken.endSolid;
    } else if (line.startsWith("facet")) {
      return StlToken.facet;
    } else if (line.startsWith("endfacet")) {
      return StlToken.endFacet;
    } else if (line.startsWith("outer")) {
      return StlToken.loop;
    } else if (line.startsWith("endloop")) {
      return StlToken.endLoop;
    } else if (line.startsWith("vertex")) {
      return StlToken.vertex;
    }
    return StlToken.error;
  }

  static const int triangleLines = 7;

  static Vector3? readVertex(String line) {
    List<String> tokens = line.trimLeft().split(' ');

    // Vertex should be 'vertex v1x v1y v1z'
    if (tokens.length == 4) {
      double? x = double.tryParse(tokens[1]);
      double? y = double.tryParse(tokens[2]);
      double? z = double.tryParse(tokens[3]);

      // If any value failed to parse, fail the whole thing
      if ((x != null) && (y != null) && (z != null)) {
        return Vector3(x, y, z);
      }
    }

    return null;
  }

  static bool readNextTriangle(List<String> lines, List<Triangle> tris, int lineNum) {

    /* Valid triangle looks like this
        facet normal ni nj nk   )
          outer loop
            vertex v1x v1y v1z
            vertex v2x v2y v2z
            vertex v3x v3y v3z
          endloop
        endfacet
       */

    bool isValid =
        ((lineNum+triangleLines) < lines.length) &&
         // already read the first line if we're here
         // (tokenType(lines[lineNum+0]) == StlToken.facet) &&
         (tokenType(lines[lineNum+1]) == StlToken.loop) &&
         (tokenType(lines[lineNum+2]) == StlToken.vertex) &&
         (tokenType(lines[lineNum+3]) == StlToken.vertex) &&
         (tokenType(lines[lineNum+4]) == StlToken.vertex) &&
         (tokenType(lines[lineNum+5]) == StlToken.endLoop) &&
         (tokenType(lines[lineNum+6]) == StlToken.endFacet);

    if (isValid) {
      Vector3? v1 = readVertex(lines[lineNum+2]);
      Vector3? v2 = readVertex(lines[lineNum+3]);
      Vector3? v3 = readVertex(lines[lineNum+4]);

      // Triangle is valid if all three vertices parsed correctly
      isValid = ((v1 != null) && (v2 != null) && (v3 != null));

      if (isValid) {
          tris.add(Triangle.points(v1,v2,v3));
      }
    }

    return isValid;
  }


  static List<Triangle>? loadSTLFile(File f) {
    var fileContent = f.readAsStringSync();
    return fromSTL(fileContent);
  }

  static List<Triangle>? fromSTL(String fileContent) {
    List<Triangle> triangles = [];

    List<String> lines = const LineSplitter().convert(fileContent);
    final int lineCount = lines.length;

    int currentLineNumber = 0;
    bool eof = false;

    StlToken token = tokenType(lines[0]);

    // ASCII STL will start with solid tag
    if (token == StlToken.solid) {
      currentLineNumber++;

      while ((currentLineNumber < lineCount) && (!eof)) {
        token = tokenType(lines[currentLineNumber]);

        if (token == StlToken.facet) {
          bool success = readNextTriangle(lines, triangles, currentLineNumber);
          if (success) {
            currentLineNumber += triangleLines;
          } else {
            eof = true;
          }
        } else if (token == StlToken.endSolid) {
          eof = true;
        }
        else {
          // Uh oh. In case of unexpected line, abort
          eof = true;
        }
      }
    }

    if (triangles.isEmpty) {
      return null;
    }

    return triangles;
  }
}
