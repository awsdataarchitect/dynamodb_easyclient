import 'package:dynamodb_easyclient/pages/homepage/dashboard/dashboard_table.dart';
import 'package:dynamodb_easyclient/shared_files/data/constant_data.dart';
import 'package:flutter/material.dart';

class RegionTableTile extends StatefulWidget {
  final Function onTap;
  final Function onTapDelete;
  final bool isSelectedTable;
  final String tableName;
  final bool showDeleteIcon;

  const RegionTableTile({
    Key key,
    this.onTapDelete,
    this.showDeleteIcon,
    this.isSelectedTable,
    this.onTap,
    this.tableName,
  }) : super(key: key);

  @override
  _RegionTableTileState createState() => _RegionTableTileState();
}

class _RegionTableTileState extends State<RegionTableTile> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextButton(
          onPressed: () {
            widget.onTap();
          },
          style: TextButton.styleFrom(
            backgroundColor: widget.isSelectedTable ? dyc1 : Colors.white,
          ),
          child: SizedBox(
            width: sideMenuWidth - 60,
            // height: 40,
            child: Center(
              child: Text(widget.tableName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black)),
            ),
          ),
        ),
        if (widget.showDeleteIcon)
          Positioned(
              right: 0,
              child: IconButton(
                  onPressed: () {
                    widget.onTapDelete();
                  },
                  icon: Icon(
                    Icons.delete,
                    size: 20,
                    color: Colors.red[900],
                  )))
      ],
    );
  }
}
