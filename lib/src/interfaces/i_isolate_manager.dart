abstract class IIsolateManager {
  IIsolateManager({required this.enableDebugLogs});

  final bool enableDebugLogs;

  Future<void> initialize(void Function(List<dynamic>) processFunction);
  Future<void> sendMessage(List<dynamic> message);
}
