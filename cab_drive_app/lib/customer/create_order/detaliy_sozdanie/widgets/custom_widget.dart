import 'package:flutter/material.dart';

class ExpandableWidget extends StatefulWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double containerWidth;
  final Function(bool)? ifExpanded;
  final IconData Function(bool)? iconBuilder;
  const ExpandableWidget({
    Key? key,
    required this.children,
    this.padding = const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 8),
    this.containerWidth = double.infinity, this.iconBuilder, this.ifExpanded,
  }) : super(key: key);

  @override
  _ExpandableWidgetState createState() => _ExpandableWidgetState();
}

class _ExpandableWidgetState extends State<ExpandableWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(

      width: widget.containerWidth,
      decoration: BoxDecoration(
        color: Colors.white, // Example background color
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Padding(

        padding: widget.padding,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
                widget.ifExpanded?.call(_isExpanded);
              },
              child: AnimatedSize(
                alignment: Alignment.topCenter,
                duration: const Duration(milliseconds: 180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _isExpanded ? [
                    Row(
                      children: [
                        Expanded(child: widget.children.firstOrNull ?? Container()),
                        Icon(
                          (widget.iconBuilder?.call(_isExpanded) ?? (_isExpanded ? Icons.expand_less : Icons.expand_more)),
                        ),
                      ],
                    ),
                    ...widget.children.sublist(1)] : [Row(
                    children: [

                      Expanded(child: widget.children.firstOrNull ?? Container()),
                      Icon(
                        (widget.iconBuilder?.call(_isExpanded) ?? (_isExpanded ? Icons.expand_less : Icons.expand_more)),
                      ),
                    ],
                  )],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}