import 'package:flutter/material.dart';

class CustomTable extends StatelessWidget {
  final List<CustomTableColumn> columns;
  final List<CustomTableRow> rows;
  final Color headerBackgroundColor;
  final Color borderColor;
  final double borderWidth;
  final bool showVerticalDividers;

  const CustomTable({
    super.key,
    required this.columns,
    required this.rows,
    this.headerBackgroundColor = const Color(0xFFF5F5F5),
    this.borderColor = Colors.grey,
    this.borderWidth = 1.0,
    this.showVerticalDividers = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            color: headerBackgroundColor,
            child: Row(
              children: columns.asMap().entries.map((entry) {
                final index = entry.key;
                final column = entry.value;
                return Expanded(
                  flex: column.flex,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: index < columns.length - 1 && showVerticalDividers
                          ? Border(
                              right: BorderSide(
                                color: borderColor,
                                width: borderWidth,
                              ),
                            )
                          : null,
                    ),
                    child: column.header,
                  ),
                );
              }).toList(),
            ),
          ),
          // Data Rows
          ...rows.map((row) {
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: borderColor, width: borderWidth),
                ),
              ),
              child: Row(
                children: row.cells.asMap().entries.map((entry) {
                  final index = entry.key;
                  final cell = entry.value;
                  return Expanded(
                    flex: columns[index].flex,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: index < columns.length - 1 && showVerticalDividers
                            ? Border(
                                right: BorderSide(
                                  color: borderColor,
                                  width: borderWidth,
                                ),
                              )
                            : null,
                      ),
                      child: cell.child,
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class CustomTableColumn {
  final Widget header;
  final int flex;

  const CustomTableColumn({
    required this.header,
    this.flex = 1,
  });
}

class CustomTableRow {
  final List<CustomTableCell> cells;

  const CustomTableRow({
    required this.cells,
  });
}

class CustomTableCell {
  final Widget child;

  const CustomTableCell({
    required this.child,
  });
}