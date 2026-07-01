import 'package:flutter/material.dart';

import 'package:codequest/features/statistics/domain/xp_history_entry.dart';

/// Gráfico de linha da evolução de XP acumulado ao longo das semanas.
///
/// Desenhado com [CustomPainter] para não depender de bibliotecas externas.
class XpEvolutionChart extends StatelessWidget {
  const XpEvolutionChart({super.key, required this.entries});

  /// Entradas em qualquer ordem; o gráfico ordena por data crescente.
  final List<XpHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ordered = [...entries]
      ..sort((a, b) => a.weekStart.compareTo(b.weekStart));

    if (ordered.length < 2) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Histórico insuficiente para o gráfico.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: CustomPaint(
        painter: _XpChartPainter(
          entries: ordered,
          lineColor: theme.colorScheme.primary,
          fillColor: theme.colorScheme.primary.withValues(alpha: 0.15),
          gridColor: theme.colorScheme.outlineVariant,
          labelStyle: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ) ??
              const TextStyle(fontSize: 10),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _XpChartPainter extends CustomPainter {
  _XpChartPainter({
    required this.entries,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
    required this.labelStyle,
  });

  final List<XpHistoryEntry> entries;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;
  final TextStyle labelStyle;

  static const double _bottomPad = 22;
  static const double _topPad = 12;
  static const double _leftPad = 4;
  static const double _rightPad = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final values = entries.map((e) => e.xpTotal).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    // Faixa nunca zero para evitar divisão por zero quando tudo é igual.
    final range = (maxValue - minValue) == 0 ? 1 : (maxValue - minValue);

    final chartWidth = size.width - _leftPad - _rightPad;
    final chartHeight = size.height - _topPad - _bottomPad;

    Offset pointFor(int index) {
      final x = _leftPad + (chartWidth * index) / (entries.length - 1);
      final normalized = (entries[index].xpTotal - minValue) / range;
      final y = _topPad + chartHeight - (chartHeight * normalized);
      return Offset(x, y);
    }

    // Linha de base.
    final basePaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(_leftPad, _topPad + chartHeight),
      Offset(size.width - _rightPad, _topPad + chartHeight),
      basePaint,
    );

    final points = [for (var i = 0; i < entries.length; i++) pointFor(i)];

    // Área preenchida sob a linha.
    final fillPath = Path()..moveTo(points.first.dx, _topPad + chartHeight);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, _topPad + chartHeight);
    fillPath.close();
    canvas.drawPath(fillPath, Paint()..color = fillColor);

    // Linha.
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      linePath.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Pontos.
    final dotPaint = Paint()..color = lineColor;
    for (final p in points) {
      canvas.drawCircle(p, 3, dotPaint);
    }

    // Rótulos: primeira, do meio e última semana (evita poluição).
    final labelIndexes = {0, entries.length ~/ 2, entries.length - 1};
    for (final i in labelIndexes) {
      final label = _shortDate(entries[i].weekStart);
      final tp = TextPainter(
        text: TextSpan(text: label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      var dx = points[i].dx - tp.width / 2;
      dx = dx.clamp(0, size.width - tp.width);
      tp.paint(canvas, Offset(dx, size.height - tp.height));
    }
  }

  String _shortDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m';
  }

  @override
  bool shouldRepaint(covariant _XpChartPainter oldDelegate) {
    return oldDelegate.entries != entries || oldDelegate.lineColor != lineColor;
  }
}
