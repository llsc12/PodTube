//
//  ContentView.swift
//  Music Reborn
//
//  Created by llsc12 on 26/03/2022.
//
import SwiftUI
import Alamofire
import SDWebImageSwiftUI
import AVFAudio

struct ContentView: View {
    @State private var term: String = ""
    @State private var searchResults: Array<Result> = []
    @State private var showSpinner: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField(
                        "Search YouTube",
                        text: $term
                    )
                    .onAppear(perform: {
                        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                        try? AVAudioSession.sharedInstance().setActive(false)
                    })
                    .onSubmit {
                        showSpinner = true
                        let path = "https://invidious.osi.kr/api/v1/search?q=\(term.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")&type=video"
                        AF.request(path).responseData { res in
                            switch res.result {
                            case .success(let data):
                                searchResults.removeAll()
                                showSpinner = false

                                let json = try? JSONDecoder().decode(Videos.self, from: data)
                                if json == nil {return}
                                for vid in json! {
                                    searchResults.append(
                                        Result(
                                            title: vid.title,
                                            vidId: vid.videoID,
                                            thumb: URL(string: vid.videoThumbnails[0].url)!,
                                            author: vid.author
                                        )
                                    )
                                }
                            case .failure(_):
                                showSpinner = false
                            }
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .cornerRadius(0)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding([.top, .leading, .trailing], 15.0)
                }
                if !searchResults.isEmpty {
                    List(searchResults) { result in
                        NavigationLink(
                            destination: PlayerView(thumb: result.thumb, vidId: result.vidId, title: result.title, author: result.author)
                        ) {
                            ZStack {
                                WebImage(url: result.thumb)
                                    .resizable()
                                    .scaledToFill()
                                    .ignoresSafeArea()
                                    .blur(radius: 30)
                                    .brightness(-0.2)
                                HStack {
                                    #if os(macOS)
                                    WebImage(url: result.thumb)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(3)
                                        .frame(width: UIScreen.main.bounds.width / 30, alignment: .leading)
                                    #else
                                    WebImage(url: result.thumb)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(3)
                                        .frame(width: UIScreen.main.bounds.width / 4, alignment: .leading)
                                    #endif
                                    VStack {
                                        Text("\(result.title)")
                                            .lineLimit(5)
                                            .foregroundColor(.white)
                                            .shadow(color: .black, radius: 2, x: 0, y: 0)
                                        Text("\(result.author)")
                                            .lineLimit(3)
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                            .shadow(color: .black, radius: 2, x: 0, y: 0)
                                    }
                                }
                            }
                            .frame(height: UIScreen.main.bounds.height / 6 ,alignment:.center)
                        }
                    }
                } else {
                    Spacer()
                    if showSpinner {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .padding(.trailing)
                    }
                    Spacer()
                }
            }
            .navigationTitle("PodTube")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
