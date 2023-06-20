//
//  StoryRow.swift
//  HN
//
//  Created by Mano Rajesh on 6/19/23.
//

import SwiftUI

struct Story: Decodable {
    let by: String
    let descendants: Int
    let id: Int
    let kids: [Int]?
    let score: Int?
    let text: String?
    let time: Int
    let title: String
    let url: String?
}

struct StoryRow: View {
    let from: Int
    let num: Int
    
    @State var story: Story?
    @State var timeAgo: String?
    
    var body: some View {
        VStack {
            if let story = story {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text("\(num+1).")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Text("\(story.title)")
                            .font(.body)
                        Spacer()
                    }
                    .padding(.bottom, 2)
                    Text("\(story.score!) points by \(story.by) \(timeAgo ?? "")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 25)
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            let url = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(from).json")!
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        story = try JSONDecoder().decode(Story.self, from: data)
                        timeAgo = getTimeAgo(time: story?.time ?? 0)
                    } catch {
                        print("Failed to decde JSON: \(error)")
                    }
                }
            }
            task.resume()
        }
    }
    
    func getTimeAgo(time: Int) -> String {
        let storyDate = Date(timeIntervalSince1970: TimeInterval(time))
        let timeDiff = Date().timeIntervalSince(storyDate)
        
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        dateFormatter.maximumUnitCount = 1
        dateFormatter.unitsStyle = .full
        
        return (dateFormatter.string(from: timeDiff) ?? "") + " ago"
    }
}

struct StoryRow_Previews: PreviewProvider {
    static var previews: some View {
        StoryRow(from: 36398418, num: 1)
    }
}
