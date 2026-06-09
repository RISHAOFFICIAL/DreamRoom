import WidgetKit
import SwiftUI

struct VisionEntry: TimelineEntry {
    let date: Date
    let item: BoardItem?
    let progress: Double // 0.0 to 1.0
    let witnessCount: Int
    let boardTitle: String
    let recentThumbnails: [String] // URLs or identifiers
}

struct VisionTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> VisionEntry {
        VisionEntry(
            date: Date(),
            item: nil,
            progress: 0.7,
            witnessCount: 12,
            boardTitle: "The Sanctuary",
            recentThumbnails: []
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (VisionEntry) -> ()) {
        let entry = VisionEntry(
            date: Date(),
            item: nil,
            progress: 0.85,
            witnessCount: 24,
            boardTitle: "The Sanctuary",
            recentThumbnails: []
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VisionEntry>) -> ()) {
        var entries: [VisionEntry] = []
        
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            
            // Simulating dynamic data for the MVP
            let entry = VisionEntry(
                date: entryDate,
                item: BoardItem(text: "Luxury Travel"),
                progress: 0.4 + Double(hourOffset) * 0.1,
                witnessCount: 5 + hourOffset * 3,
                boardTitle: "The Sanctuary",
                recentThumbnails: ["thumb1", "thumb2", "thumb3"]
            )
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
