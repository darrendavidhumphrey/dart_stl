import 'package:dart_stl/stl_reader.dart';
import 'package:dart_stl/stl_writer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' show Triangle,Vector3;

String oneTriangleSTL = '''
solid test.stl
facet normal 0.0 0.0 -320.0
  outer loop
    vertex 1.0 2.0 3.5
    vertex 80.0 90.0 -10.0
    vertex 76.0 -4.0 0.0
  endloop
endfacet
endsolid
''';

String twoTriangleSTL = '''
solid test.stl
facet normal 0.0 0.0 -320.0
  outer loop
    vertex 1.0 2.0 3.5
    vertex 80.0 90.0 -10.0
    vertex 76.0 -4.0 0.0
  endloop
endfacet
facet normal 0.0 0.0 -320.0
  outer loop
    vertex 3.0 4.0 5.0
    vertex 80.0 90.0 -10.0
    vertex 76.0 -4.0 0.0
  endloop
endfacet
endsolid
''';


String capitalsButOK = '''
SOLID test.stl
FACET NORMAL 0.0 0.0 -320.0
  OUTER LOOP
    VERTEX 1.0 2.0 3.5
    vertex 80.0 90.0 -10.0
    VERTEX 76.0 -4.0 0.0
  ENDLOOP
ENDFACET
ENDSOLID
''';

String noLeadingWhiteSpaceOK = '''
SOLID test.stl
FACET NORMAL 0.0 0.0 -320.0
OUTER LOOP
VERTEX 1.0 2.0 3.5
vertex 80.0 90.0 -10.0
VERTEX 76.0 -4.0 0.0
ENDLOOP
ENDFACET
ENDSOLID
''';

String noHeader = '''
facet normal 0.0 0.0 -320.0
''';

String badHeader = '''
s0lid test.stl
facet normal 0.0 0.0 -320.0
''';

String missingFacet = '''
SOLID test.stl
#FACET NORMAL 0.0 0.0 -320.0
OUTER LOOP
VERTEX 1.0 2.0 3.5
vertex 80.0 90.0 -10.0
VERTEX 76.0 -4.0 0.0
ENDLOOP
ENDFACET
ENDSOLID
''';

String missingOuter = '''
SOLID test.stl
FACET NORMAL 0.0 0.0 -320.0
#OUTER LOOP
VERTEX 1.0 2.0 3.5
vertex 80.0 90.0 -10.0
VERTEX 76.0 -4.0 0.0
ENDLOOP
ENDFACET
ENDSOLID
''';

String missingVertex = '''
SOLID test.stl
FACET NORMAL 0.0 0.0 -320.0
OUTER LOOP
#VERTEX 1.0 2.0 3.5
vertex 80.0 90.0 -10.0
VERTEX 76.0 -4.0 0.0
ENDLOOP
ENDFACET
ENDSOLID
''';

String missingVertexComponent = '''
SOLID test.stl
FACET NORMAL 0.0 0.0 -320.0
OUTER LOOP
VERTEX 1.0 2.0 
vertex 80.0 90.0 -10.0
VERTEX 76.0 -4.0 0.0
ENDLOOP
ENDFACET
ENDSOLID
''';

String missingEndLoop= '''
SOLID test.stl
FACET NORMAL 0.0 0.0 -320.0
OUTER LOOP
#VERTEX 1.0 2.0 3.5
vertex 80.0 90.0 -10.0
VERTEX 76.0 -4.0 0.0
#ENDLOOP
ENDFACET
ENDSOLID
''';

String missingEndFacet= '''
SOLID test.stl
FACET NORMAL 0.0 0.0 -320.0
OUTER LOOP
#VERTEX 1.0 2.0 3.5
vertex 80.0 90.0 -10.0
VERTEX 76.0 -4.0 0.0
ENDLOOP
#ENDFACET
ENDSOLID
''';

String testOutput ='''
solid test
facet normal 0.000000 0.000000 -1.000000
    outer loop
        vertex 0.000000 0.000000 0.000000
        vertex 0.000000 1.000000 0.000000
        vertex 1.000000 1.000000 0.000000
    endloop
endfacet
endsolid test
''';

void main() {
  group('reader tests', () {
    test('File should parse and create a list', () {
      List<Triangle>? tris = StlReader.fromSTL(oneTriangleSTL);
      expect((tris != null), true);
    });
    test('list should have one triangle', () {
      List<Triangle>? tris = StlReader.fromSTL(oneTriangleSTL);
      expect((tris!.length), 1);
    });

    test('list should have two triangle', () {
      List<Triangle>? tris = StlReader.fromSTL(twoTriangleSTL);
      expect((tris!.length), 2);
    });

    test('Vertex 1 data is correct', () {
      List<Triangle>? tris = StlReader.fromSTL(oneTriangleSTL);
      Vector3 v1 = tris![0].point0;
      expect((v1.x), 1.0);
      expect((v1.y), 2.0);
      expect((v1.z), 3.5);
    });
    test('Vertex 2 data is correct', () {
      List<Triangle>? tris = StlReader.fromSTL(oneTriangleSTL);
      Vector3 v2 = tris![0].point1;
      expect((v2.x), 80.0);
      expect((v2.y), 90.0);
      expect((v2.z), -10.0);
    });
    test('Vertex 3 data is correct', () {
      List<Triangle>? tris = StlReader.fromSTL(oneTriangleSTL);
      Vector3 v3 = tris![0].point2;
      expect((v3.x), 76.0);
      expect((v3.y), -4.0);
      expect((v3.z), 0.0);
    });

    test('Capitalized tokens', () {
      List<Triangle>? tris = StlReader.fromSTL(capitalsButOK);
      expect((tris != null), true);
      expect((tris!.length), 1);
    });
    test('No leading whitespace tokens', () {
      List<Triangle>? tris = StlReader.fromSTL(noLeadingWhiteSpaceOK);
      expect((tris != null), true);
      expect((tris!.length), 1);
    });

    test('bad header', () {
      List<Triangle>? tris = StlReader.fromSTL(badHeader);
      expect((tris == null), true);
    });

    test('no header', () {
      List<Triangle>? tris = StlReader.fromSTL(noHeader);
      expect((tris == null), true);
      
    });

    test('missingFacet', () {
      List<Triangle>? tris = StlReader.fromSTL(missingFacet);
      expect((tris == null), true);
      
    });

    test('missingOuter', () {
      List<Triangle>? tris = StlReader.fromSTL(missingOuter);
      expect((tris == null), true);
      
    });

    test('missingVertexComponent', () {
      List<Triangle>? tris = StlReader.fromSTL(missingVertexComponent);
      expect((tris == null), true);
      
    });

    test('missingVertex', () {
      List<Triangle>? tris = StlReader.fromSTL(missingVertex);
      expect((tris == null), true);
      
    });

    test('missingEndFacet', () {
      List<Triangle>? tris = StlReader.fromSTL(missingEndFacet);
      expect((tris == null), true);
      
    });

    test('missingEndLoop', () {
      List<Triangle>? tris = StlReader.fromSTL(missingEndLoop);
      expect((tris == null), true);
      
    });

  });

  group('writer tests', () {
    test('Save to STL, re-read and compare', () {
      List<Triangle> tris = [
        Triangle.points(
          Vector3(0,0,0),
          Vector3(0,1.7,-12.9),
          Vector3(100.456,100.67881,-0.12)
        )
      ];
      String stl = StlWriter.toSTL("test",tris);
      List<Triangle>? tris2 = StlReader.fromSTL(stl);
      expect(tris2!=null, true);
      expect(tris2![0].point0, tris[0].point0);
      expect(tris2[0].point1, tris[0].point1);
      expect(tris2[0].point2, tris[0].point2);
    });

  });
}
