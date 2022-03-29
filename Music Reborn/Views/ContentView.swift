//
//  ContentView.swift
//  Music Reborn
//
//  Created by llsc12 on 26/03/2022.
//

import SwiftUI
import Alamofire
import SDWebImageSwiftUI
import YouTubeKit

struct ContentView: View {
    @State private var term: String = ""
    @State private var searchResults: Array<Result> = []
    @State private var showSpinner: Bool = false
    @State private var selection: Int? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField(
                        "Search YouTube",
                        text: $term
                    )
                    .textFieldStyle(.roundedBorder)
                    .cornerRadius(3)
                    .onSubmit {
                        showSpinner = true
                        let path = "https://vid.puffyan.us/api/v1/search?q=\(term.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")&type=video"
                        AF.request(path).responseData { res in
                            switch res.result {
                            case .success(let data):
                                searchResults.removeAll()
                                showSpinner = false

                                let json = try? JSONDecoder().decode(Videos.self, from: data)
                                if json == nil {return}
                                for vid in json! {
                                    Task{
                                        searchResults.append(
                                            Result(
                                                title: vid.title,
                                                vidId: vid.videoID,
                                                thumb: URL(string: vid.videoThumbnails[0].url)!,
                                                author: vid.author,
                                                src: URL(string: "egg")
                                            )
                                        )
                                    }
                                }
                            case .failure(_):
                                showSpinner = false
                            }
                        }
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .border(.secondary)
                    .padding([.top, .leading, .trailing], 15.0)

                    if showSpinner {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .padding(.trailing)
                    }

                }
                if !searchResults.isEmpty {
                    List(searchResults) { result in
                        NavigationLink(
                            destination: PlayerView(thumb: result.thumb, vidId: result.vidId, title: result.title, author: result.author),
                            tag: 1,
                            selection: $selection
                        ) {
                            Button(action: {
                                UserDefaults.standard.set(result.vidId, forKey: "id")
                                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                                    self.selection = 1
                                }
                            }) {
                                HStack {
                                    WebImage(url: result.thumb)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(3)
                                    VStack {
                                        Text("\(result.title)")
                                            .lineLimit(5)
                                        Text("\(result.author)")
                                            .lineLimit(3)
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .accentColor(Color.black)
                            .padding()
                            .cornerRadius(4.0)
                            .padding(Edge.Set.vertical, 20)
                        }
                    }
                } else {
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