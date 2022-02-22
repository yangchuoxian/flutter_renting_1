class Battery {
  String id;
  String batterySerialNo;
  String status;
  String soc;
  String totalVoltage;
  String temperature;
  String longitude;
  String latitude;

  Battery({
    this.id,
    this.batterySerialNo,
    this.status,
    this.soc,
    this.totalVoltage,
    this.temperature,
    this.longitude,
    this.latitude,
  });

  factory Battery.fromJson(Map<String, dynamic> json) {
    var b = Battery();
    if (json['batterySerialNo'] == null || json['batterySerialNo'] == '') {
      b.batterySerialNo = '-';
    } else {
      b.batterySerialNo = json['batterySerialNo'];
    }
    if (json['status'] == null || json['status'] == '') {
      b.status = '-';
    } else {
      b.status = json['status'];
    }
    if (json['soc'] == null || json['soc'] == '') {
      b.soc = '-';
    } else {
      b.soc = "${json['soc']}%";
    }
    if (json['totalVoltage'] == null || json['totalVoltage'] == '') {
      b.totalVoltage = '-';
    } else {
      b.totalVoltage = "${json['totalVoltage']}V";
    }
    if (json['temperature'] == null || json['temperature'] == '') {
      b.temperature = '-';
    } else {
      b.temperature = "${json['temperature']}℃";
    }
    if (json['location'] != null) {
      if (json['location']['coordinates'] != null) {
        if (json['location']['coordinates'][0] != null &&
            json['location']['coordinates'][1] != null) {
          b.longitude = json['location']['coordinates'][0];
          b.latitude = json['location']['coordinates'][1];
        }
      }
    }
    return b;
  }
}
