<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

## Introduction

A 100% dart library for reading and writing STL files, a 3D file format widely used in 3D printing.

## Features

The initial release only supports reading and writing ASCII STL files.
Binary support will be added in a future release.


## Getting started

This package requires the vector_math package. Install it first.

```dart
 $ flutter pub add vector_math
```

## Examples

1\. Read an STL file from a File into a List of Triangles

```dart
import 'package:dart_stl/stl_reader.dart';

File bunnyFile = File('bunny.stl');
List<Triangle>? tris = StlReader.loadSTL(bunnyFile);
```

2\. Write a List of Triangles to an STL file

```dart
import 'package:dart_stl/stl_writer.dart';

List<Triangle> bunnyTriangles = ...
File bunnyFile = File('bunny.stl');

StlWriter.writeSTL(bunnyTriangles,"bunny",bunnyFile);

```

3\. Write/read STL data to/from a String
```dart
List<Triangle> bunnyTriangles = ...
String bunnySTL = StlWriter.toSTL(bunnyTriangles,"bunny");
List<Triangles> bunnyTriangles2 = StlReader.fromSTL(bunnySTL);
```
