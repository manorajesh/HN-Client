//
//  ContentView.swift
//  HN
//
//  Created by Mano Rajesh on 6/19/23.
//

import SwiftUI

struct StoryID: Identifiable {
    let id: Int
    let storyID: Int
}

struct ContentView: View {
    @State var storyIDs: [StoryID]?
    var body: some View {
        NavigationView {
            Group {
                if let storyIDs = storyIDs  {
                    List(storyIDs) { storyID in
                        StoryRow(from: storyID.storyID, num: storyID.id)
                    }
                } else {
                    ProgressView()
                        .progressViewStyle(.linear)
                }
            }
            .navigationTitle("Hacker News")
            .onAppear {
                let url = URL(string: "https://hacker-news.firebaseio.com/v0/topstories.json")!
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data {
                        do {
                            let ids = try JSONDecoder().decode([Int].self, from: data)
                            self.storyIDs = ids.enumerated().map { StoryID(id: $0.offset, storyID: $0.element) }
                        } catch {
                            print("Failed to decode JSON: \(error)")
                        }
                    }
                }
                task.resume()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
