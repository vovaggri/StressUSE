import AVFoundation
import Foundation

@MainActor
final class StressNoiseService {
    private let engine = AVAudioEngine()
    private var isConfigured = false

    func start() {
        configureIfNeeded()
        guard !engine.isRunning else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
        } catch {
            print("Stress noise failed to start: \(error.localizedDescription)")
        }
    }

    func stop() {
        engine.stop()
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }

    private func configureIfNeeded() {
        guard !isConfigured else { return }

        let format = engine.outputNode.inputFormat(forBus: 0)
        let source = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for frame in 0 ..< Int(frameCount) {
                let sample = Float.random(in: -0.18 ... 0.18)
                for buffer in ablPointer {
                    let ptr = buffer.mData?.assumingMemoryBound(to: Float.self)
                    ptr?[frame] = sample
                }
            }
            return noErr
        }

        engine.attach(source)
        engine.connect(source, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 0.16
        isConfigured = true
    }
}
