import 'package:flutter/material.dart';

class PaddedRow extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final List<Widget> children;
  final double spacing;

  const PaddedRow({
    super.key,
    required this.padding,
    required this.children,
    this.spacing = 0.0,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Row(spacing: spacing, children: children),
  );
}

class PaddedColumn extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final List<Widget> children;
  final double spacing;

  const PaddedColumn({
    super.key,
    required this.padding,
    required this.children,
    this.spacing = 0.0,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Row(spacing: spacing, children: children),
  );
}
