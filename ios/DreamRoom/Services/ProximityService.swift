import Foundation
import CoreBluetooth
import Combine

/**
 * ProximityService uses Bluetooth LE to detect nearby devices running the DreamRoom app.
 * It broadcasts a specific Service UUID and scans for the same UUID.
 * This is used to supplement WiFi-based Golden Hour detection.
 */
class ProximityService: NSObject, ObservableObject {
    static let shared = ProximityService()
    
    @Published var nearbyDevicesCount: Int = 0
    
    private var centralManager: CBCentralManager?
    private var peripheralManager: CBPeripheralManager?
    
    // Unique UUID for DreamRoom proximity detection
    private let serviceUUID = CBUUID(string: "D7E1A123-1234-4A21-8B21-3E2C7305F3C0")
    
    private var discoveredDevices: [UUID: Date] = [:]
    private var timer: Timer?
    
    private override init() {
        super.init()
        // Initialize managers
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        // Cleanup old devices every 10 seconds to ensure count is accurate
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.cleanupOldDevices()
        }
    }
    
    func start() {
        print("[ProximityService] Starting proximity detection...")
    }
    
    private func cleanupOldDevices() {
        let now = Date()
        let timeout: TimeInterval = 30.0 // Devices not seen for 30s are considered "gone"
        
        let initialCount = discoveredDevices.count
        discoveredDevices = discoveredDevices.filter { now.timeIntervalSince($0.value) < timeout }
        
        if discoveredDevices.count != initialCount {
            updateNearbyCount()
        }
    }
    
    private func updateNearbyCount() {
        DispatchQueue.main.async {
            self.nearbyDevicesCount = self.discoveredDevices.count
            print("[ProximityService] Nearby DreamRoom devices: \(self.nearbyDevicesCount)")
        }
    }
}

extension ProximityService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("[ProximityService] Central powered on, scanning for services: \(serviceUUID)")
            central.scanForPeripherals(withServices: [serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        case .poweredOff:
            print("[ProximityService] Bluetooth is powered off.")
        case .unauthorized:
            print("[ProximityService] Bluetooth is unauthorized.")
        case .unsupported:
            print("[ProximityService] Bluetooth is unsupported on this device.")
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Record the device and current timestamp
        discoveredDevices[peripheral.identifier] = Date()
        updateNearbyCount()
    }
}

extension ProximityService: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            print("[ProximityService] Peripheral powered on, broadcasting service: \(serviceUUID)")
            let service = CBMutableService(type: serviceUUID, primary: true)
            peripheral.add(service)
            
            peripheral.startAdvertising([
                CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
                CBAdvertisementDataLocalNameKey: "DreamRoom-Client"
            ])
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            print("[ProximityService] Error adding service: \(error.localizedDescription)")
        }
    }
}
