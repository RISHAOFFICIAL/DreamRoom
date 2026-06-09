import WidgetKit
import SwiftUI

@main
struct DreamRoomWidget: Widget {
    let kind: String = "DreamRoomWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VisionTimelineProvider()) { entry in
            VisionWidgetView(entry: entry)
        }
        .configurationDisplayName("Dream Vision")
        .description("Keep your aspirations on your lock screen.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .systemSmall])
    }
}
