import SwiftUI
import WidgetKit

/// Home screen widget: sync status and the most recent clips.
///
/// Every string it shows is written by the app, already translated — the app
/// owns twenty languages worth of strings and duplicating a subset of them into
/// a second string catalog here would only let the two drift apart.
struct PlokeeEntry: TimelineEntry {
    let date: Date
    let status: String
    let syncEnabled: Bool
    let clips: [Clip]

    struct Clip: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
    }

    static let placeholder = PlokeeEntry(
        date: Date(), status: "Plokee", syncEnabled: true, clips: [])
}

struct PlokeeProvider: TimelineProvider {
    func placeholder(in context: Context) -> PlokeeEntry { .placeholder }

    func getSnapshot(in context: Context,
                     completion: @escaping (PlokeeEntry) -> Void) {
        completion(read())
    }

    func getTimeline(in context: Context,
                     completion: @escaping (Timeline<PlokeeEntry>) -> Void) {
        // The app reloads the timeline whenever the state changes, so there is
        // nothing to schedule: .never avoids waking the widget up to re-read a
        // file that only the app can have changed.
        completion(Timeline(entries: [read()], policy: .never))
    }

    private func read() -> PlokeeEntry {
        let state = PlokeeShared.readState()
        let clips = (state["recent"] as? [[String: Any]] ?? []).prefix(4).map {
            PlokeeEntry.Clip(
                title: $0["title"] as? String ?? "",
                subtitle: $0["subtitle"] as? String ?? "")
        }
        return PlokeeEntry(
            date: Date(),
            status: state["status"] as? String ?? "Plokee",
            syncEnabled: state["syncEnabled"] as? Bool ?? true,
            clips: Array(clips))
    }
}

struct PlokeeWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: PlokeeEntry

    private var visibleClips: [PlokeeEntry.Clip] {
        switch family {
        case .systemLarge: return Array(entry.clips.prefix(4))
        case .systemMedium: return Array(entry.clips.prefix(2))
        default: return Array(entry.clips.prefix(1))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Circle()
                    .fill(entry.syncEnabled ? Color.green : Color.secondary)
                    .frame(width: 7, height: 7)
                Text(entry.status)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            if visibleClips.isEmpty {
                Spacer()
                Text("Plokee")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                ForEach(visibleClips) { clip in
                    VStack(alignment: .leading, spacing: 1) {
                        Text(clip.title)
                            .font(.footnote)
                            .fontWeight(.medium)
                            .lineLimit(family == .systemSmall ? 3 : 2)
                        if !clip.subtitle.isEmpty {
                            Text(clip.subtitle)
                                .font(.caption2)
                                .foregroundColor(Color.secondary.opacity(0.75))
                                .lineLimit(1)
                        }
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .modifier(WidgetBackground())
    }
}

/// iOS 17 insists a widget declare its own background; earlier versions insist
/// it does not have padding applied twice.
private struct WidgetBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            content.containerBackground(.fill.tertiary, for: .widget)
        } else {
            content.padding()
        }
    }
}

@main
struct PlokeeWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "PlokeeWidget", provider: PlokeeProvider()) {
            PlokeeWidgetView(entry: $0)
        }
        .configurationDisplayName("Plokee")
        .description("Clipboard sync status and recent clips.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
