import 'dart:convert';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:integration_test/integration_test_driver.dart';

/*
Adapted from flutter cookbook: https://docs.flutter.dev/cookbook/testing/integration/profiling
*/
Future<void> main() {
  writeJsonToFile(filename: 'test.json', data: {'xyz': 'Abc', 'xz': 123});
  return integrationDriver(
    responseDataCallback: (data) async {
      if (data != null) {
        final timeline = driver.Timeline.fromJson(data['performance_timeline']);

        // Convert the Timeline into a TimelineSummary that's easier to
        // read and understand.
        final summary = driver.TimelineSummary.summarize(timeline);

        await writeJsonToFile(
            filename: 'performance_summary.json', data: summary.customSummary);
      }
    },
  );
}

/*
Using the jsonSummary getter of TimelineSummary doesn't seem to work,
double.parse throws a FormatException when encountering a string "0,00000".
*/
extension CustomSummary on driver.TimelineSummary {
  Map<String, dynamic> get customSummary {
    return <String, dynamic>{
      'average_frame_build_time_millis': computeAverageFrameBuildTimeMillis(),
      '90th_percentile_frame_build_time_millis':
          computePercentileFrameBuildTimeMillis(90.0),
      '99th_percentile_frame_build_time_millis':
          computePercentileFrameBuildTimeMillis(99.0),
      'worst_frame_build_time_millis': computeWorstFrameBuildTimeMillis(),
      'missed_frame_build_budget_count': computeMissedFrameBuildBudgetCount(),
      'average_frame_rasterizer_time_millis':
          computeAverageFrameRasterizerTimeMillis(),
      '90th_percentile_frame_rasterizer_time_millis':
          computePercentileFrameRasterizerTimeMillis(90.0),
      '99th_percentile_frame_rasterizer_time_millis':
          computePercentileFrameRasterizerTimeMillis(99.0),
      'worst_frame_rasterizer_time_millis':
          computeWorstFrameRasterizerTimeMillis(),
      'missed_frame_rasterizer_budget_count':
          computeMissedFrameRasterizerBudgetCount(),
      'frame_count': countFrames(),
      'frame_rasterizer_count': countRasterizations(),
    };
  }
}

Future<void> writeJsonToFile(
    {required String filename, required Map<String, dynamic> data}) async {
  var jsonString = const JsonEncoder.withIndent('    ').convert(data);
  await File(filename).writeAsString(jsonString);
}
