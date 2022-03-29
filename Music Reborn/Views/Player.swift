//
//  Player.swift
//  Music Reborn
//
//  Created by llsc12 on 28/03/2022.
//

import SwiftUI
import SDWebImageSwiftUI
import YouTubeKit
import AVKit
import AVFoundation

struct PlayerView: View {
    @State var thumb: URL
    @State var vidId: String
    @State var title: String
    @State var author: String
    @State var player = AVPlayer()

    @State var isPlaying: Bool = false
    
    var body: some View {
        ZStack {
            WebImage(url: thumb)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: 30)
                .frame(alignment:.center)

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
                WebImage(url: thumb)
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width - 40, alignment: .center)
                    .cornerRadius(15, antialiased: true)
                    .shadow(color: .black, radius: 10, x: 0, y: 0)
                Spacer()
                Spacer()
                VStack {
                    Slider(value: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant(10)/*@END_MENU_TOKEN@*/)
                    HStack(alignment: .center) {
                        Button {
                            isPlaying.toggle()
                            
                            switch isPlaying {
                            case true:
                                player.play()
                            case false:
                                player.pause()
                            }
                        } label: {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 75, alignment: .center)
                        }
                        .onAppear {
                            player = AVPlayer(url: URL(string: "https://invidious.osi.kr/latest_version?id=\(vidId)&itag=140")!)
                            player.play()
                            isPlaying = true
                            try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                            try? AVAudioSession.sharedInstance().setActive(true)
                        }
                        .onDisappear {
                            player.pause()
                            player = AVPlayer()
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
            thumb: URL(string: "https://vid.puffyan.us/vi/bYCUt4sPlKc/maxres.jpg")!,
            vidId: "bYCUt4sPlKc",
            title: "Ki Jor Gariban Da egg egg egg egg egg egg egg egg egg",
            author: "Josh Sidhu"
        )
    }
}
