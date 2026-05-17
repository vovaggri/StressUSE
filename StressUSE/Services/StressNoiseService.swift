import AVFoundation
import Foundation

@MainActor
final class StressNoiseService {
    private let ambienceResourceName = "708407__group39__highschoolers-writing-test-in-classroom-ambience"
    private let customSoundPathKey = "stressuse.customStressSoundPath"
    private var player: AVAudioPlayer?

    func start() {
        configurePlayerIfNeeded()
        guard let player, !player.isPlaying else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            player.currentTime = 0
            player.play()
        } catch {
            print("Classroom ambience failed to start: \(error.localizedDescription)")
        }
    }

    func stop() {
        player?.stop()
        player?.currentTime = 0
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }

    private func configurePlayerIfNeeded() {
        guard player == nil else { return }
        guard let soundURL = classroomAmbienceURL() else {
            print("Classroom ambience sound file was not found in the app bundle.")
            return
        }

        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer.numberOfLoops = -1
            audioPlayer.volume = 0.28
            audioPlayer.prepareToPlay()
            player = audioPlayer
        } catch {
            print("Classroom ambience failed to load: \(error.localizedDescription)")
        }
    }

    private func classroomAmbienceURL() -> URL? {
        if let customURL = customStressSoundURL() {
            return customURL
        }

        let bundle = Bundle.main

        if let url = bundle.url(forResource: ambienceResourceName, withExtension: "wav") {
            return url
        }

        if let url = bundle.url(forResource: ambienceResourceName, withExtension: "wav", subdirectory: "Sounds") {
            return url
        }

        if let url = bundle.url(forResource: ambienceResourceName, withExtension: "wav", subdirectory: "Resources/Sounds") {
            return url
        }

        return nil
    }

    private func customStressSoundURL() -> URL? {
        let path = UserDefaults.standard.string(forKey: customSoundPathKey) ?? ""
        guard !path.isEmpty else { return nil }
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        return URL(fileURLWithPath: path)
    }
}
