import 'dart:convert';
import 'dart:io';
import 'package:vector_math/vector_math_64.dart' show Triangle, Vector3;

/// These are the tokens that make up an ASCII STL file
enum StlToken {
  /// Start of a solid
  solid,

  /// End of a solid
  endSolid,

  /// Start of a facet
  facet,

  /// End of a facet
  endFacet,

  /// Start of a loop
  loop,

  /// End of a loop
  endLoop,

  /// Vertex
  vertex,

  /// A token to indicate a parse error occurred
  error,
}

/// A class for loading ASCII STL data from files or Strings
class StlReader {
  /// Examines a string and determines what kind of token it is
  static StlToken _tokenType(String s) {
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

  /// Reads a vertex from the string
  static Vector3? _readVertex(String line) {
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

  /// How many lines to read to parse a triangle
  static const int _triangleLines = 7;

  /// Read the next triangle from the list of lines
  static bool _readNextTriangle(
    List<String> lines,
    List<Triangle> tris,
    int lineNum,
  ) {
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
        ((lineNum + _triangleLines) < lines.length) &&
        // already read the first line if we're here
        // (tokenType(lines[lineNum+0]) == StlToken.facet) &&
        (_tokenType(lines[lineNum + 1]) == StlToken.loop) &&
        (_tokenType(lines[lineNum + 2]) == StlToken.vertex) &&
        (_tokenType(lines[lineNum + 3]) == StlToken.vertex) &&
        (_tokenType(lines[lineNum + 4]) == StlToken.vertex) &&
        (_tokenType(lines[lineNum + 5]) == StlToken.endLoop) &&
        (_tokenType(lines[lineNum + 6]) == StlToken.endFacet);

    if (isValid) {
      Vector3? v1 = _readVertex(lines[lineNum + 2]);
      Vector3? v2 = _readVertex(lines[lineNum + 3]);
      Vector3? v3 = _readVertex(lines[lineNum + 4]);

      // Triangle is valid if all three vertices parsed correctly
      isValid = ((v1 != null) && (v2 != null) && (v3 != null));

      if (isValid) {
        tris.add(Triangle.points(v1, v2, v3));
      }
    }

    return isValid;
  }

  /// Load a STL file
  /// This function takes a file parameter [f]
  /// and returns List of triangles, or null on error
  static List<Triangle>? loadSTLFile(File f) {
    var fileContent = f.readAsStringSync();
    return fromSTL(fileContent);
  }

  /// Create a list of triangles from a String containing
  /// a valid STL file
  /// This function takes a string parameter [fileContent]
  /// and returns List of triangles, or null on error
  static List<Triangle>? fromSTL(String fileContent) {
    List<Triangle> triangles = [];

    List<String> lines = const LineSplitter().convert(fileContent);
    final int lineCount = lines.length;

    int currentLineNumber = 0;
    bool eof = false;

    StlToken token = _tokenType(lines[0]);

    // ASCII STL will start with solid tag
    if (token == StlToken.solid) {
      currentLineNumber++;

      while ((currentLineNumber < lineCount) && (!eof)) {
        token = _tokenType(lines[currentLineNumber]);

        if (token == StlToken.facet) {
          bool success = _readNextTriangle(lines, triangles, currentLineNumber);
          if (success) {
            currentLineNumber += _triangleLines;
          } else {
            eof = true;
          }
        } else if (token == StlToken.endSolid) {
          eof = true;
        } else {
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
