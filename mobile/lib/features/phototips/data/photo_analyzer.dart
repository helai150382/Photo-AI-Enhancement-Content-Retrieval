import 'dart:math' as math;
import 'dart:typed_data';

/// 指标健康等级：good 良好 / warn 注意 / bad 较差。
enum PhotoMetricLevel { good, warn, bad }

/// 单项照片指标（标签 + 数值 + 等级）。
class PhotoMetric {
  const PhotoMetric({
    required this.label,
    required this.value,
    required this.level,
  });

  final String label;
  final String value;
  final PhotoMetricLevel level;
}

/// 建议重要度。
enum SuggestionSeverity { info, warn }

/// 一条拍照建议。
class PhotoSuggestion {
  const PhotoSuggestion({
    required this.title,
    required this.advice,
    this.severity = SuggestionSeverity.info,
  });

  final String title;
  final String advice;
  final SuggestionSeverity severity;
}

/// 照片分析报告：指标 + 建议。
class PhotoAnalysisReport {
  const PhotoAnalysisReport({required this.metrics, required this.suggestions});

  final List<PhotoMetric> metrics;
  final List<PhotoSuggestion> suggestions;
}

/// 基于颜色统计的启发式拍照分析器。
///
/// 建议对缩略图（最长边 ≤ 256）调用 [analyze]，以免大图遍历过慢。
class PhotoAnalyzer {
  PhotoAnalysisReport analyze(Uint8List rgba, int w, int h) {
    if (w <= 0 || h <= 0 || rgba.length < w * h * 4) {
      return const PhotoAnalysisReport(metrics: [], suggestions: []);
    }

    // 隔点采样降低遍历开销。
    var n = 0, sumLum = 0.0, sumWarm = 0.0, sumSat = 0.0, sumSq = 0.0;
    var skinN = 0, skinX = 0.0, skinY = 0.0;

    for (var y = 0; y < h; y += 2) {
      for (var x = 0; x < w; x += 2) {
        final o = (y * w + x) * 4;
        final r = rgba[o].toDouble();
        final g = rgba[o + 1].toDouble();
        final b = rgba[o + 2].toDouble();
        final lum = 0.299 * r + 0.587 * g + 0.114 * b;
        final mx = r > g ? (r > b ? r : b) : (g > b ? g : b);
        final mn = r < g ? (r < b ? r : b) : (g < b ? g : b);
        n++;
        sumLum += lum;
        sumWarm += r - b;
        sumSat += mx - mn;
        sumSq += lum * lum;
        // Ta Yang 经典肤色判定规则。
        if (r > 95 && g > 40 && b > 20 && r > g && g > b && (mx - mn) > 30) {
          skinN++;
          skinX += x;
          skinY += y;
        }
      }
    }

    final metrics = <PhotoMetric>[];
    final suggestions = <PhotoSuggestion>[];
    if (n == 0) {
      return const PhotoAnalysisReport(metrics: [], suggestions: []);
    }

    final meanLum = sumLum / n;
    final brightness = meanLum / 255.0;
    final varLum =
        (sumSq / n - meanLum * meanLum).clamp(0.0, double.infinity);
    final contrast = math.sqrt(varLum) / 255.0 / 1.28;
    final warmth = sumWarm / n / 255.0;
    final saturation = sumSat / n / 255.0;
    final skinRatio = skinN / n;
    final skinCx = skinN == 0 ? null : (skinX / skinN) / w;
    final skinCy = skinN == 0 ? null : (skinY / skinN) / h;

    metrics.add(PhotoMetric(
      label: '亮度',
      value: _pct(brightness),
      level: brightness < 0.28 || brightness > 0.8
          ? PhotoMetricLevel.bad
          : (brightness < 0.4 || brightness > 0.7
              ? PhotoMetricLevel.warn
              : PhotoMetricLevel.good),
    ));
    metrics.add(PhotoMetric(
      label: '对比度',
      value: _pct(contrast),
      level: contrast < 0.18 ? PhotoMetricLevel.bad : PhotoMetricLevel.good,
    ));
    metrics.add(PhotoMetric(
      label: '饱和度',
      value: _pct(saturation),
      level:
          saturation < 0.15 ? PhotoMetricLevel.warn : PhotoMetricLevel.good,
    ));
    metrics.add(PhotoMetric(
      label: '色温',
      value: warmth.abs() < 0.06
          ? '中性'
          : (warmth > 0 ? '偏暖 +${_pct(warmth)}' : '偏冷 ${_pct(warmth)}'),
      level: warmth.abs() > 0.28 ? PhotoMetricLevel.warn : PhotoMetricLevel.good,
    ));
    metrics.add(PhotoMetric(
      label: '肤色占比',
      value: _pct(skinRatio),
      level: skinRatio > 0.20
          ? PhotoMetricLevel.good
          : (skinRatio > 0.05 ? PhotoMetricLevel.warn : PhotoMetricLevel.bad),
    ));

    if (brightness < 0.28) {
      suggestions.add(const PhotoSuggestion(
        title: '曝光不足',
        advice: '画面偏暗。建议提高曝光补一档，或让女孩朝向更亮的方向，避免脸上一片阴影。',
        severity: SuggestionSeverity.warn,
      ));
    } else if (brightness > 0.8) {
      suggestions.add(const PhotoSuggestion(
        title: '过曝',
        advice: '画面太亮、容易丢失细节。建议降低曝光，或用纱帘/树荫柔化强光。',
        severity: SuggestionSeverity.warn,
      ));
    }
    if (contrast < 0.18) {
      suggestions.add(PhotoSuggestion(
        title: '画面发灰',
        advice: '对比度较低，整体发灰。后期小幅增加对比度与清晰度，让照片更「干净」。',
        severity:
            contrast < 0.12 ? SuggestionSeverity.warn : SuggestionSeverity.info,
      ));
    }
    if (saturation < 0.15) {
      suggestions.add(const PhotoSuggestion(
        title: '色彩平淡',
        advice: '颜色偏灰淡。可让服装更鲜艳、背景更有色彩，或后期适度提高饱和度。',
      ));
    }
    if (warmth > 0.28) {
      suggestions.add(const PhotoSuggestion(
        title: '色温偏暖',
        advice: '整体偏黄偏暖。可在「白平衡」里向冷色方向微调，肤色会更白皙。',
      ));
    } else if (warmth < -0.28) {
      suggestions.add(const PhotoSuggestion(
        title: '色温偏冷',
        advice: '整体偏蓝调。可向暖色方向微调色温，让肤色更红润。',
      ));
    }
    _composeAdvice(suggestions, skinRatio, skinCx, skinCy);

    suggestions.add(const PhotoSuggestion(
      title: '通用加分项',
      advice: '保持光线均匀、背景干净，多拍连拍从中挑选表情自然的一张。',
    ));

    return PhotoAnalysisReport(metrics: metrics, suggestions: suggestions);
  }

  void _composeAdvice(
      List<PhotoSuggestion> out, double skinRatio, double? cx, double? cy) {
    if (skinRatio <= 0.05 || cx == null || cy == null) {
      out.add(const PhotoSuggestion(
        title: '构图参考',
        advice: '画面中未检测到明显的人像主体，尝试把人物放在画面 1/3 处让构图更耐看。',
      ));
      return;
    }
    final d2 = (cx - 0.5) * (cx - 0.5) + (cy - 0.5) * (cy - 0.5);
    final dist = math.sqrt(d2);
    if (cx < 0.15 || cx > 0.85 || dist > 0.5) {
      out.add(const PhotoSuggestion(
        title: '人物贴边',
        advice: '人脸/肤色区域过于贴近画面边缘或角落，可重新构图让人物位于三分之一处，避免照片失衡。',
        severity: SuggestionSeverity.warn,
      ));
      return;
    }
    out.add(const PhotoSuggestion(
      title: '构图不错',
      advice: '人物位置接近常见的三分法构图，保持这个节奏，注意给人物视线方向留出空间会更出片。',
    ));
  }

  /// 数值百分比展示（0.123 -> '12%'）。
  String _pct(double v) => '${(v * 100).toStringAsFixed(0)}%';
}
