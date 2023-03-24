//
//  ViewModel.swift
//  Harrow Mosque
//
//  Created by Muhammad Shah on 12/08/2022.
//

import Foundation
import FeedKit

class FeedViewModel: ObservableObject {
    @Published var rssItems = RSSFeed()
    @Published var isLoading = false
    
    init() {
        self.fetchData()
    }

    func fetchData() {
        self.isLoading = true
        guard let feedURL = URL(string: "https://rss.app/feeds/gXqCbgAZMykAZE7J.xml") else {
            return
        }
        
        let feedParser = FeedParser(URL: feedURL)
        // Parse asynchronously, not to block the UI.
        feedParser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            // Do your thing, then back to the Main thread
            DispatchQueue.main.async {
                // ..and update the UI
                switch result {
                case .success(let feed):
                    // Grab the parsed feed directly as an optional rss, atom or json feed object
                    if let rssFeed = feed.rssFeed {
                        self.isLoading = false
                        self.rssItems = rssFeed
                    }
                    
                case .failure(let error):
                    print(error)
                }
                
                
            }
        }
    }
}
