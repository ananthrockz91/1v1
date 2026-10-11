import 'dart:convert';
import 'dart:io';

/// 1v1 Platform Release Validation Gate Runner.
///
/// Orchestrates complete release verification across all 5 monorepo tiers:
/// 1. Code Formatting Gate
/// 2. Static Analysis Gate
/// 3. Pure Deterministic Rules Engine Suite (Unit, Invariant, Simulation, Exhaustive)
/// 4. Serverpod Backend Integration Suite (Endpoints, Optimistic Concurrency, Scheduled Job)
/// 5. Flutter Client Widget Suite (Lattice Board, Interactions, Screens)
///
/// Produces a human-readable colorized console report and machine-readable JSON artifact.
void main(List<String> args) async {
  final startTime = DateTime.now();
  final projectRoot = Directory.current.path;

  stdout.writeln(
    '================================================================',
  );
  stdout.writeln('  1v1 MULTIPLAYER GAMING PLATFORM — RELEASE QUALITY GATES');
  stdout.writeln('  Timestamp: ${startTime.toUtc().toIso8601String()}');
  stdout.writeln('  Workspace Root: $projectRoot');
  stdout.writeln(
    '================================================================\n',
  );

  final results = <GateResult>[];

  // Gate 1: Code Formatting
  results.add(
    await _runGate(
      name: 'Gate 1: Code Formatting',
      description: 'Verify all Dart source files conform to dart format',
      executable: 'dart',
      arguments: ['format', '--output=none', '--set-exit-if-changed', '.'],
      workingDirectory: projectRoot,
    ),
  );

  // Gate 2: Monorepo Static Analysis
  results.add(
    await _runGate(
      name: 'Gate 2: Monorepo Static Analysis',
      description:
          'Analyze all 5 packages in monorepo with zero warnings/errors',
      executable: 'dart',
      arguments: ['analyze', '.'],
      workingDirectory: projectRoot,
    ),
  );

  // Gate 3: Pure Game Core Rules Engine Suite (Suites A & B)
  results.add(
    await _runGate(
      name: 'Gate 3: Game Core Pure Engine Tests',
      description:
          'Mathematical geometry, invariant validator, 50 random simulations, exhaustive size-2 exploration',
      executable: 'dart',
      arguments: ['test'],
      workingDirectory: '$projectRoot/packages/game_core',
    ),
  );

  // Gate 4: Serverpod Backend Integration Tests (Suites C, F, G)
  results.add(
    await _runGate(
      name: 'Gate 4: Serverpod Backend Integration Tests',
      description:
          'Match lifecycle, optimistic locking, streaming events, daily 1:00 AM IST maintenance idempotency',
      executable: 'dart',
      arguments: ['test'],
      workingDirectory: '$projectRoot/one_v_one_server',
    ),
  );

  // Gate 5: Flutter Client Widget & UI Tests (Suites D & E)
  results.add(
    await _runGate(
      name: 'Gate 5: Flutter Client Widget Tests',
      description:
          'TriangleTacticsBoard CustomPainter, peg selection, tap-to-move, catalogue, navigation',
      executable: 'flutter',
      arguments: ['test'],
      workingDirectory: '$projectRoot/one_v_one_flutter',
    ),
  );

  final totalDuration = DateTime.now().difference(startTime);
  final allPassed = results.every((r) => r.passed);

  // Print Summary Table
  stdout.writeln(
    '\n================================================================',
  );
  stdout.writeln('                    RELEASE VALIDATION SUMMARY');
  stdout.writeln(
    '================================================================',
  );
  stdout.writeln('%-36s | %-8s | %-10s'.padRight(64));
  stdout.writeln(
    '----------------------------------------------------------------',
  );

  for (final res in results) {
    final statusStr = res.passed
        ? '\x1B[32m[PASS]\x1B[0m'
        : '\x1B[31m[FAIL]\x1B[0m';
    final durStr =
        '${(res.duration.inMilliseconds / 1000).toStringAsFixed(2)}s';
    final namePadded = res.name.padRight(40);
    stdout.writeln('$namePadded $statusStr  ($durStr)');
  }
  stdout.writeln(
    '================================================================',
  );
  stdout.writeln(
    'Total Execution Time: ${(totalDuration.inMilliseconds / 1000).toStringAsFixed(2)}s',
  );

  // Generate JSON Report Artifact
  final reportData = {
    'platform': '1v1 Multiplayer Platform',
    'timestamp': startTime.toUtc().toIso8601String(),
    'overallStatus': allPassed ? 'PASSED' : 'FAILED',
    'totalDurationMs': totalDuration.inMilliseconds,
    'gates': results
        .map(
          (r) => {
            'name': r.name,
            'description': r.description,
            'passed': r.passed,
            'exitCode': r.exitCode,
            'durationMs': r.duration.inMilliseconds,
          },
        )
        .toList(),
  };

  final reportFile = File('$projectRoot/tool/release_check_report.json');
  await reportFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(reportData),
  );
  stdout.writeln('Report written to: ${reportFile.path}');

  if (allPassed) {
    stdout.writeln(
      '\n\x1B[32m>>> ALL QUALITY GATES PASSED! SYSTEM IS READY FOR RELEASE. <<<\x1B[0m\n',
    );
    exit(0);
  } else {
    stdout.writeln(
      '\n\x1B[31m>>> RELEASE QUALITY GATES FAILED. INSPECT LOGS ABOVE. <<<\x1B[0m\n',
    );
    exit(1);
  }
}

class GateResult {
  final String name;
  final String description;
  final bool passed;
  final int exitCode;
  final Duration duration;
  final String output;

  GateResult({
    required this.name,
    required this.description,
    required this.passed,
    required this.exitCode,
    required this.duration,
    required this.output,
  });
}

Future<GateResult> _runGate({
  required String name,
  required String description,
  required String executable,
  required List<String> arguments,
  required String workingDirectory,
}) async {
  stdout.writeln('--> Running $name...');
  stdout.writeln('    $description');
  final start = DateTime.now();

  try {
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
    );

    final outBuffer = StringBuffer();
    final errBuffer = StringBuffer();

    process.stdout.transform(utf8.decoder).listen((data) {
      outBuffer.write(data);
    });

    process.stderr.transform(utf8.decoder).listen((data) {
      errBuffer.write(data);
    });

    final exitCode = await process.exitCode;
    final dur = DateTime.now().difference(start);
    final output = '$outBuffer\n$errBuffer';

    final passed = exitCode == 0;
    if (passed) {
      stdout.writeln(
        '    \x1B[32m✓ Passed\x1B[0m in ${(dur.inMilliseconds / 1000).toStringAsFixed(2)}s\n',
      );
    } else {
      stdout.writeln(
        '    \x1B[31m✗ Failed (exit code $exitCode)\x1B[0m in ${(dur.inMilliseconds / 1000).toStringAsFixed(2)}s',
      );
      stdout.writeln('--- Process Output ---');
      stdout.writeln(output.trim());
      stdout.writeln('----------------------\n');
    }

    return GateResult(
      name: name,
      description: description,
      passed: passed,
      exitCode: exitCode,
      duration: dur,
      output: output,
    );
  } catch (e) {
    final dur = DateTime.now().difference(start);
    stdout.writeln('    \x1B[31m✗ Error executing process: $e\x1B[0m\n');
    return GateResult(
      name: name,
      description: description,
      passed: false,
      exitCode: -1,
      duration: dur,
      output: e.toString(),
    );
  }
}
