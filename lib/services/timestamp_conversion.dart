String timestampToHrsMin(DateTime datetime) {
  String hrs = datetime.hour.toString();
  String mins = datetime.minute.toString();
  return "$hrs:$mins";
}
