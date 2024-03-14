//
//  beforeTheRainWidgetLiveActivity.swift
//  beforeTheRainWidget
//
//  Created by 정하랑 on 3/14/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct beforeTheRainWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct beforeTheRainWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: beforeTheRainWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension beforeTheRainWidgetAttributes {
    fileprivate static var preview: beforeTheRainWidgetAttributes {
        beforeTheRainWidgetAttributes(name: "World")
    }
}

extension beforeTheRainWidgetAttributes.ContentState {
    fileprivate static var smiley: beforeTheRainWidgetAttributes.ContentState {
        beforeTheRainWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: beforeTheRainWidgetAttributes.ContentState {
         beforeTheRainWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: beforeTheRainWidgetAttributes.preview) {
   beforeTheRainWidgetLiveActivity()
} contentStates: {
    beforeTheRainWidgetAttributes.ContentState.smiley
    beforeTheRainWidgetAttributes.ContentState.starEyes
}
