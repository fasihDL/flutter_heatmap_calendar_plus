import 'package:flutter/material.dart';
import './data/heatmap_color_mode.dart';
import './widget/heatmap_calendar_page.dart';
import './widget/heatmap_color_tip.dart';
import './util/date_util.dart';
import './util/widget_util.dart';

class HeatMapCalendar extends StatefulWidget {
  /// The datasets which fill blocks based on its value.
  final Map<DateTime, int>? datasets;

  /// The color value of every block's default color.
  final Color? defaultColor;

  /// The colorsets which give the color value for its thresholds key value.
  ///
  /// Be aware that first Color is the maximum value if [ColorMode] is [ColorMode.opacity].
  /// Also colorsets must have at least one color.
  // final Map<int, Color> colorsets;

  /// The double value of every block's borderRadius.
  final double? borderRadius;

  /// The date values of initial year and month.
  final DateTime? initDate;

  /// The double value of every block's size.
  final double? size;

  /// The text color value of every blocks.
  final Color? textColor;

  /// The double value of every block's fontSize.
  final double? fontSize;

  /// The double value of back arrow size.
  final double? backArrowSize;

  /// The double value of forward arrow size.
  final double? forwardArrowSize;

  /// The color value of back arrow.
  final Color? backArrowColor;

  /// The color value of forward arrow.
  final Color? forwardArrowColor;

  /// The double value of month label's fontSize.
  final double? monthFontSize;

  /// The text color value of month label.
  final Color? monthTextColor;

  /// The double value of week label's fontSize.
  final double? weekFontSize;

  /// The text color value of week labels.
  final Color? weekTextColor;

  /// Make block size flexible if value is true.
  ///
  /// Default value is false.
  final bool? flexible;

  /// The margin value for every block.
  final EdgeInsets? margin;

  /// ColorMode changes the color mode of blocks.
  ///
  /// [ColorMode.opacity] requires just one colorsets value and changes color
  /// dynamically based on hightest value of [datasets].
  /// [ColorMode.color] changes colors based on [colorsets] thresholds key value.
  ///
  /// Default value is [ColorMode.opacity].
  final ColorMode colorMode;

  /// The color value for opacity.
  final Color? opacityColor;

  /// Function that will be called when a block is clicked.
  ///
  /// Paratmeter gives clicked [DateTime] value.
  final Function(DateTime)? onClick;

  /// Function that will be called when month is changed.
  ///
  /// Paratmeter gives [DateTime] value of current month.
  final Function(DateTime)? onMonthChange;

  /// Show color tip which represents the color range at the below.
  ///
  /// Default value is true.
  final bool? showColorTip;

  /// Widgets which shown at left and right side of colorTip.
  ///
  /// First value is the left side widget and second value is the right side widget.
  /// Be aware that [colorTipHelper.length] have to greater or equal to 2.
  /// Give null value makes default 'less' and 'more' [Text].
  final List<Widget?>? colorTipHelper;

  /// The integer value which represents the number of [HeatMapColorTip]'s tip container.
  final int? colorTipCount;

  /// The double value of [HeatMapColorTip]'s tip container's size.
  final double? colorTipSize;
  final Color? Function(int?) getMoodColor;
  const HeatMapCalendar({
    Key? key,
    // required this.colorsets,
    this.colorMode = ColorMode.opacity,
    this.defaultColor,
    this.datasets,
    this.initDate,
    this.size = 42,
    this.fontSize,
    this.backArrowSize,
    this.forwardArrowSize,
    this.monthFontSize,
    this.monthTextColor,
    this.backArrowColor,
    this.forwardArrowColor,
    this.textColor,
    this.opacityColor,
    this.weekFontSize,
    this.weekTextColor,
    this.borderRadius,
    this.flexible = false,
    this.margin,
    this.onClick,
    this.onMonthChange,
    this.showColorTip = true,
    this.colorTipHelper,
    this.colorTipCount,
    this.colorTipSize,
    required this.getMoodColor,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HeatMapCalendar();
}

class _HeatMapCalendar extends State<HeatMapCalendar> {
  // The DateTime value of first day of the current month.
  DateTime? _currentDate;

  @override
  void initState() {
    super.initState();
    setState(() {
      // Set _currentDate value to first day of initialized date or
      // today's month if widget.initDate is null.
      _currentDate =
          DateUtil.startDayOfMonth(widget.initDate ?? DateTime.now());
    });
  }

  void changeMonth(int direction) {
    setState(() {
      _currentDate =
          DateUtil.changeMonth(_currentDate ?? DateTime.now(), direction);
    });
    if (widget.onMonthChange != null) widget.onMonthChange!(_currentDate!);
  }
  Color? _getMoodColor(int? moodValue) {
    if (moodValue != null) {
      if (widget.colorMode == ColorMode.color) {
        // Customize colors based on mood values
        if (widget.colorsets.containsKey(moodValue)) {
          return widget.colorsets[moodValue];
        }
      } else if (widget.colorMode == ColorMode.opacity) {
        // Customize opacity color based on mood values
        double opacity = moodValue / widget.colorsets.keys.last.toDouble();
        return widget.opacityColor?.withOpacity(opacity);
      }
    }

    // Return a default color if moodValue is null or doesn't match any conditions
    return widget.defaultColor ?? Colors.grey;
  }
  /// Header widget which shows left, right buttons and year/month text.
  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Previous month button.
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: widget.backArrowSize ?? 14,
            color: widget.backArrowColor,
          ),
          onPressed: () => changeMonth(-1),
        ),

        // Text which shows the current year and month
        Text(
          DateUtil.MONTH_LABEL[_currentDate?.month ?? 0] +
              ' ' +
              (_currentDate?.year).toString(),
          style: TextStyle(
              fontSize: widget.monthFontSize ?? 12,
              color: widget.monthTextColor
          ),
        ),

        // Next month button.
        IconButton(
          icon: Icon(
            Icons.arrow_forward_ios,
            size: widget.forwardArrowSize ?? 14,
            color: widget.forwardArrowColor,
          ),
          onPressed: () => changeMonth(1),
        ),
      ],
    );
  }

  Widget _weekLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (String label in DateUtil.WEEK_LABEL.skip(1))
          WidgetUtil.flexibleContainer(
            widget.flexible ?? false,
            false,
            Container(
              margin: EdgeInsets.only(
                  left: widget.margin?.left ?? 2,
                  right: widget.margin?.right ?? 2),
              width: widget.size ?? 42,
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: widget.weekFontSize ?? 12,
                  color: widget.weekTextColor ?? const Color(0xFF758EA1),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Expand width dynamically if [flexible] is true.
  Widget _intrinsicWidth({
    required Widget child,
  }) =>
      (widget.flexible ?? false) ? child : IntrinsicWidth(child: child);

  @override
  Widget build(BuildContext context) {
    return _intrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _header(),
          _weekLabel(),
          HeatMapCalendarPage(
            baseDate: _currentDate ?? DateTime.now(),
            colorMode: widget.colorMode,
            flexible: widget.flexible,
            size: widget.size,
            opacityColor: widget.opacityColor,
            fontSize: widget.fontSize,
            defaultColor: widget.defaultColor,
            textColor: widget.textColor,
            margin: widget.margin,
            datasets: widget.datasets,
            colorsets: widget.colorsets,
            borderRadius: widget.borderRadius,
            onClick: widget.onClick,
            getMoodColor: _getMoodColor,
          ),
          if (widget.showColorTip == true)
            HeatMapColorTip(
              colorMode: widget.colorMode,
              colorsets: widget.colorsets,
              leftWidget: widget.colorTipHelper?[0],
              rightWidget: widget.colorTipHelper?[1],
              containerCount: widget.colorTipCount,
              size: widget.colorTipSize,
            ),
        ],
      ),
    );
  }
}
