//
//  ContentView.swift
//  Music Reborn
//
//  Created by llsc12 on 26/03/2022.
//

import SwiftUI
import Alamofire

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
                                    searchResults.append(
                                        Result(
                                            title: vid.title,
                                            vidId: vid.videoID,
                                            thumb: URL(string: vid.videoThumbnails[0].url)!
                                        )
                                    )
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
                
                Spacer()
                List(searchResults) { result in
                    NavigationLink {
                        PlayerView()
                            .navigationTitle("Player")

                    } label: {
                        HStack {
                            Text("\(result.title)")
                                .lineLimit(3)
                        }
                    }

                }
            }
            .navigationTitle("Music")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
