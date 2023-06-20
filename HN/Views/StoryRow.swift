//
//  StoryRow.swift
//  HN
//
//  Created by Mano Rajesh on 6/19/23.
//

import SwiftUI

struct Story: Decodable {
    let by: String
    let descendants: Int?
    let id: Int
    let kids: [Int]?
    let score: Int?
    let text: String?
    let time: Int
    let title: String
    let url: String?
}

struct FavIcon {
    enum Size: Int, CaseIterable { case s = 16, m = 32, l = 64, xl = 128, xxl = 256, xxxl = 512 }
    private let domain: String
    init(_ domain: String) { self.domain = domain }
    subscript(_ size: Size) -> String {
        "https://www.google.com/s2/favicons?sz=\(size.rawValue)&domain=\(domain)"
    }
}

extension Image {
    func data(url: URL) -> AnyView {
        var image = AnyView(Image(systemName: "circle.fill")
            .resizable()
            .foregroundColor(.random())
            .aspectRatio(contentMode: .fit))
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                image = AnyView(Image(uiImage: UIImage(data: data)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit))
            }
        }
        task.resume()
        return image
    }
}

extension Color {
    public static func random() -> Self {
        return Color(
            red: .random(in: 0.1...1),
            green: .random(in: 0.1...1),
            blue: .random(in: 0.1...1)
        )
    }
}

struct StoryRow: View {
    let from: Int
    let num: Int
    
    @State var story: Story?
    @State var timeAgo: String?
    @State var imageLoaded = false
    
    var body: some View {
        VStack {
            if let story = story {
                ZStack {
                    if let url = story.url {
                        Image(systemName: "exclaimation")
                            .data(url: URL(string: FavIcon(url)[.xxl])!)
                            .blur(radius: 50.0)
                            .animation(.easeInOut(duration: 1.5), value: imageLoaded)
                                        .onAppear {
                                            self.imageLoaded = true
                                        }
                    } else {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .foregroundColor(.random())
                            .aspectRatio(contentMode: .fit)
                            .blur(radius: 50.0)
                    }
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            Text("\(num+1).")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            VStack(alignment: .leading) {
                                Text("\(story.title)")
                                    .font(.body)
                                    .padding(.bottom, 1)
                                Text("\(story.score!) points by \(story.by) \(timeAgo ?? "")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                }
            } else {
                ProgressView()
                    .progressViewStyle(.linear)
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
        StoryRow(from: 36398292, num: 5)
    }
}
