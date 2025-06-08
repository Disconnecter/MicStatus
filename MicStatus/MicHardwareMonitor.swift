import Foundation
import CoreAudio

final class MicHardwareMonitor {
    private var deviceID: AudioObjectID = AudioObjectID(kAudioObjectUnknown)
    private var queue = DispatchQueue(label: "MicHardwareMonitor")
    private var address: AudioObjectPropertyAddress

    var onChange: ((Bool) -> Void)?

    init(onChange: @escaping (Bool) -> Void) {
        self.onChange = onChange
        address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )
        deviceID = Self.defaultInputDevice()
        start()
        notify()
    }

    deinit {
        stop()
    }

    func stop() {
        AudioObjectRemovePropertyListenerBlock(deviceID, &address, queue) { [weak self] _, _ in
            self?.notify()
        }
    }

    private func start() {
        AudioObjectAddPropertyListenerBlock(deviceID, &address, queue) { [weak self] _, _ in
            self?.notify()
        }
    }

    private func notify() {
        var volume: Float32 = 0
        var size = UInt32(MemoryLayout<Float32>.size)
        var addr = address
        if AudioObjectGetPropertyData(deviceID, &addr, 0, nil, &size, &volume) == noErr {
            onChange?(volume > 0)
        }
    }

    private static func defaultInputDevice() -> AudioObjectID {
        var id = AudioObjectID(kAudioObjectUnknown)
        var size = UInt32(MemoryLayout<AudioObjectID>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &id) == noErr else {
            return AudioObjectID(kAudioObjectUnknown)
        }
        return id
    }
}
