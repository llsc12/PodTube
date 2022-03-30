//
//  Player.swift
//  Music Reborn
//
//  Created by llsc12 on 28/03/2022.
//

import SwiftUI
import SDWebImageSwiftUI
import AVFoundation
import YouTubeKit
import Alamofire

class ViewModel: ObservableObject {
    var player = AVPlayer()
    var timeObserverToken: Any?
    var max: Int = 0
    var current: Int = 0
    var isPlaying: Bool = false
    var label = "00:00"
    
    func mainpart() {
        // the thing that periodically checks what subtitle should be displayed and changes subtitletext as needed
        let interval = CMTime(seconds: 0.2, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [self] time in
            let seconds: Double = CMTimeGetSeconds(time)
            current = Int(seconds.rounded())
            max = Int("\((Double((player.currentItem?.duration.seconds) ?? 0) / 2).rounded())".components(separatedBy: ".")[0]) ?? 0

            if ((player.rate != 0) && (player.error == nil)) {
                isPlaying = true
            } else {
                isPlaying = false
            }

            if current >= max + 1 {
                player.pause()
                let time = CMTime(seconds: Double(max), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                // Update Slider UI based on time value
                let rate = player.rate
                // Temporarily stop while changing time
                player.rate = 0
                player.seek(to: time) { completed in
                    if !completed { return }
                    // Play again when the changes are complete
                    self.player.rate = rate
                }
            } else {
                label = "\(makeTimestamp(t: current)) / \(makeTimestamp(t: max))"
            }
            objectWillChange.send()
        }
    }
}

struct PlayerView: View {
    @State var isDownloading = false
    @State var barprogress: Double = 0
    @State var thumb: URL
    @State var vidId: String
    @State var title: String
    @State var author: String
    @StateObject var vm = ViewModel()
    
    var timeObserverToken: Any?

    var body: some View {
        ZStack {
            WebImage(url: thumb)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: 30)
                .frame(alignment:.center)
                .brightness(-0.2)
            VStack {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 5, x: 0, y: 0)
                    .frame(width: UIScreen.main.bounds.width, alignment: .center)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                
                Text(author)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 5, x: 0, y: 0)
                    .frame(width: UIScreen.main.bounds.width, alignment: .center)

                Spacer()
                Button {
                    UIPasteboard.general.string = "https://youtu.be/\(vidId)"
                } label: {
                    WebImage(url: thumb)
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width - 40, alignment: .center)
                        .cornerRadius(15, antialiased: true)
                        .shadow(color: .black, radius: 10, x: 0, y: 0)
                }
                Spacer()
                
                if isDownloading == false {
                    if vm.max == 0 {
                        ProgressView()
                        .frame(width: UIScreen.main.bounds.width - 50)
                        .shadow(color: .black, radius: 15, x: 0, y: 0)
                    } else {
                        ProgressView(value: Double(vm.current), total: Double(vm.max)) {
                            Text("")
                        } currentValueLabel: {
                            Text(vm.label)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 10, x: 0, y: 0)
                        }
                        .frame(width: UIScreen.main.bounds.width - 50)
                        .shadow(color: .black, radius: 15, x: 0, y: 0)
                    }
                } else {
                    ProgressView(value: barprogress, total: 1) {
                        Text("Loading...")
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 10, x: 0, y: 0)
                    } currentValueLabel: {
                        Text("\(barprogress.rounded() * 100)")
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 10, x: 0, y: 0)
                    }
                    .frame(width: UIScreen.main.bounds.width - 50)
                    .shadow(color: .black, radius: 15, x: 0, y: 0)
                }
                Spacer()
                VStack {

                    HStack(alignment: .center) {
                        Button {
                            let time = CMTime(seconds: vm.player.currentTime().seconds - 5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                            // Update Slider UI based on time value
                            let rate = vm.player.rate
                            // Temporarily stop while changing time
                            vm.player.rate = 0
                            vm.player.seek(to: time) { completed in
                                if !completed { return }
                                // Play again when the changes are complete
                                vm.player.rate = rate
                            }
                            
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            
                        } label: {
                            Image(systemName: "gobackward.5")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 50, alignment: .center)
                                .shadow(color: .black, radius: 10, x: 0, y: 0)
                        }
                        Button { // play pause
                            switch vm.isPlaying {
                            case true:
                                vm.player.pause()
                            case false:
                                vm.player.play()
                            }
                            
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            
                        } label: {
                            Image(systemName: vm.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 75, alignment: .center)
                                .shadow(color: .black, radius: 10, x: 0, y: 0)
                        }
                        .padding(.horizontal, UIScreen.main.bounds.width / 10)
                        .onAppear {
                            Task {
                                var audioFileUrl: URL!
                                if FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/\(vidId).mp4") {
                                    let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                                    audioFileUrl = dir!.appendingPathComponent(vidId+".mp4")
                                    
                                    vm.player = AVPlayer(url: URL(fileURLWithPath: audioFileUrl.absoluteString))
                                    vm.mainpart()
                                    vm.player.play()
                                } else {
                                    isDownloading = true
                                    let ytVideo = YouTube(videoID: vidId)
                                    let streams = try await ytVideo.streams
                                    var stream: YouTubeKit.Stream!
                                    
                                    //get the necessary stream
                                    let audioStreams = streams.filterAudioOnly()
                                    stream = audioStreams.filter { $0.subtype == "mp4" }
                                    .highestAudioBitrateStream()
                                    let src = (stream.url.absoluteString)
                                    let destination: DownloadRequest.Destination = { _, _ in
                                        let fileURL = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/"+vidId+".mp4")
                                        audioFileUrl = fileURL
                                        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                                    }
                                    AF.download(src, to: destination).response { res in
                                        isDownloading = false

                                        if res.value != nil {
                                            // video's audio is available
                                            
                                        }
                                    }.downloadProgress { progress in
                                        print(barprogress)
                                        barprogress = progress.fractionCompleted
                                    }
                                }
//                                vm.player = AVPlayer(url: URL(string: stream.url.absoluteString)!)
//                                vm.mainpart()
//                                vm.player.play()
                                try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                                try? AVAudioSession.sharedInstance().setActive(true)
                            }
                        }
                        .onDisappear {
                            vm.player.pause()
                            vm.player = AVPlayer()
                        }
                        Button {
                            let time = CMTime(seconds: vm.player.currentTime().seconds + 5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                            // Update Slider UI based on time value
                            let rate = vm.player.rate
                            // Temporarily stop while changing time
                            vm.player.rate = 0
                            vm.player.seek(to: time) { completed in
                                if !completed { return }
                                // Play again when the changes are complete
                                vm.player.rate = rate
                            }
                            
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            
                        } label: {
                            Image(systemName: "goforward.5")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 50, alignment: .center)
                                .shadow(color: .black, radius: 10, x: 0, y: 0)
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 1.0)
        }
    }
}

struct Player_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(
            thumb: URL(string: "https://vid.puffyan.us/vi/mMSBnt25tr0/maxresdefault.jpg")!,
            vidId: "mMSBnt25tr0",
            title: "Hyperspeed",
            author: "Eveningland - Topic"
        )
    }
}

func makeTimestamp(t: Int) -> String {
    let secs = t % 60
    let mins = Int(Double(t / 60).rounded(.down))
    let hours = Int(Double(t / 3600).rounded(.down))
    var strSecs: String = "\(secs)"
    var strMins: String = "\(mins)"
    var strHours: String = "\(hours)"
    
    if String(secs).count == 1 {
        strSecs = "0\(secs)"
    }
    if String(mins).count == 1 {
        strMins = "0\(mins)"
    }
    if String(hours).count == 1 {
        strHours = "0\(hours)"
    }
    
    if hours == 0 {
        return "\(strMins):\(strSecs)"
    } else {
        return "\(strHours):\(strMins):\(strSecs)"
    }
}
