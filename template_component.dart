import 'package:flutter/material.dart';

class StatelessWidgetTemplate extends StatelessWidget {
  const StatelessWidgetTemplate({super.key});

  @override
  Widget build(BuildContext context) => Column();
}

class StatefulWidgetTemplate extends StatefulWidget {
  const StatefulWidgetTemplate({super.key});

  @override
  State<StatefulWidget> createState() => _StatefulWidgetTemplateState();
}

class _StatefulWidgetTemplateState extends State<StatefulWidgetTemplate> {
  @override
  Widget build(BuildContext context) => Column();
}
