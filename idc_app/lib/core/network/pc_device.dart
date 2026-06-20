class PcDevice {
  final String name;
  final String ip;
  final int wsPort;
  final String pcId;

  const PcDevice({
    required this.name,
    required this.ip,
    required this.wsPort,
    required this.pcId,
  });

  factory PcDevice.fromJson(Map<String, dynamic> json, String senderIp) {
    return PcDevice(
      name: json['name'] as String,
      ip: senderIp,
      wsPort: json['ws_port'] as int,
      pcId: json['pc_id'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'ip': ip,
        'ws_port': wsPort,
        'pc_id': pcId,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PcDevice && pcId == other.pcId;

  @override
  int get hashCode => pcId.hashCode;
}
