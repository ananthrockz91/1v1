import 'package:game_core/game_core.dart';
import 'package:test/test.dart';

void main() {
  group('BoardGeometry Formulas & Generation', () {
    test('verifies mathematical formulas for sizes 1 through 5', () {
      for (int n = 1; n <= 5; n++) {
        final geometry = BoardGeometry(n);

        final expectedNodes = (n + 1) * (n + 2) ~/ 2;
        final expectedTriangles = n * n;
        final expectedEdges = 3 * n * (n + 1) ~/ 2;

        expect(
          geometry.nodes.length,
          equals(expectedNodes),
          reason: 'Node count mismatch for size $n',
        );
        expect(
          geometry.triangles.length,
          equals(expectedTriangles),
          reason: 'Triangle count mismatch for size $n',
        );
        expect(
          geometry.edges.length,
          equals(expectedEdges),
          reason: 'Edge count mismatch for size $n',
        );
      }
    });

    test('verifies unique node IDs and edge IDs', () {
      final geometry = BoardGeometry(4);

      final nodeIds = geometry.nodes.map((n) => n.id).toSet();
      expect(nodeIds.length, equals(geometry.nodes.length));

      final edgeIds = geometry.edges.map((e) => e.id).toSet();
      expect(edgeIds.length, equals(geometry.edges.length));

      final triIds = geometry.triangles.map((t) => t.id).toSet();
      expect(triIds.length, equals(geometry.triangles.length));
    });

    test('verifies every edge connects strictly adjacent nodes', () {
      final geometry = BoardGeometry(4);
      for (final edge in geometry.edges) {
        expect(edge.isAdjacent, isTrue);
      }
    });

    test('verifies each triangle is bounded by exactly 3 edges', () {
      final geometry = BoardGeometry(4);
      for (final tri in geometry.triangles) {
        expect(tri.edgeIds.length, equals(3));
        for (final edgeId in tri.edgeIds) {
          expect(geometry.containsEdge(edgeId), isTrue);
        }
      }
    });
  });
}
