import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "dream_engine_ai/hardware", binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        if call.method == "getHardwareStats" {
          var stats = [String: Any]()
          
          // Total RAM (bytes)
          let totalRam = ProcessInfo.processInfo.physicalMemory
          stats["totalRam"] = Int64(totalRam)
          
          // Available RAM (bytes) using host VM stats
          var pagesize: vm_size_t = 0
          let host_port: mach_port_t = mach_host_self()
          var host_size: mach_msg_type_number_t = mach_msg_type_number_t(MemoryLayout<vm_statistics_data_t>.stride / MemoryLayout<integer_t>.stride)
          var vm_stat = vm_statistics_data_t()
          
          let kerr: kern_return_t = withUnsafeMutablePointer(to: &vm_stat) {
              $0.withMemoryRebound(to: integer_t.self, capacity: Int(host_size)) {
                  host_statistics(host_port, HOST_VM_INFO, $0, &host_size)
              }
          }
          
          if kerr == KERN_SUCCESS {
              host_page_size(host_port, &pagesize)
              let freeRam = UInt64(vm_stat.free_count) * UInt64(pagesize)
              let inactiveRam = UInt64(vm_stat.inactive_count) * UInt64(pagesize)
              stats["availRam"] = Int64(freeRam + inactiveRam)
          } else {
              stats["availRam"] = Int64(totalRam / 2) // fallback
          }
          
          // Temperature (thermalState proxy)
          let thermalState = ProcessInfo.processInfo.thermalState
          var temp: Double = 30.0
          switch thermalState {
          case .nominal:
              temp = 28.0
          case .fair:
              temp = 35.0
          case .serious:
              temp = 42.0
          case .critical:
              temp = 48.0
          @unknown default:
              temp = 30.0
          }
          stats["temperature"] = temp
          
          result(stats)
        } else {
          result(FlutterMethodNotImplemented)
        }
      })
    }
    
    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
