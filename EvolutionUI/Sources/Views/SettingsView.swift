#if os(macOS)
import SwiftUI

/// Top-level settings interface presented on macOS builds.
public struct SettingsView: View {
    private enum Tabs: Hashable {
        case general, advanced
    }

    public init() {}

    public var body: some View {
        TabView {
            AcknowledgementsView()
                .tabItem {
                    Label("Acknowledgements", systemImage: "hands.clap.fill")
                }
                .tag(Tabs.general)
        }
    }
}

/// Displays acknowledgements for third-party libraries.
struct AcknowledgementsView: View {
    @State var selection = Acknowledgement.allItems.first
    @State var items = Acknowledgement.allItems

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            NavigationStack {
                List(selection: $selection) {
                    ForEach(items) { item in
                        NavigationLink(item.title, value: item)
                    }
                }
            }
            .frame(width: 200)

            if let selection {
                ScrollView {
                    Text(selection.text)
                        .lineLimit(nil)
                        .padding(.vertical)
                }
            }
            Spacer()
        }
        .padding(16)
        .frame(idealWidth: 800, idealHeight: 600)
    }
}

/// Model describing a single third-party acknowledgement entry.
struct Acknowledgement: Hashable, Identifiable {
    var id: String { title }
    /// Title of the acknowledged library.
    var title: String = ""
    /// Full acknowledgement text.
    var text: String = ""
}

extension Acknowledgement {
    static let allItems: [Self] = {
        func plist(name: String) -> [[String: Any]] {
            guard
                let settings = Bundle.main.url(forResource: "Settings", withExtension: "bundle"),
                let acknowledgements = Bundle(url: settings)?.url(forResource: name, withExtension: "plist"),
                let plist = try? NSDictionary(contentsOf: acknowledgements, error: ()),
                let preferences = plist["PreferenceSpecifiers"] as? [[String: Any]]
            else {
                return []
            }
            return preferences
        }
        var acknowledgements = [Acknowledgement]()
        for specification in plist(name: "Acknowledgements") {
            guard
                let title = specification["Title"] as? String,
                let file = specification["File"] as? String,
                let text =  plist(name: file).first?["FooterText"] as? String
            else {
                break
            }
            acknowledgements.append(.init(title: title, text: text))
        }
        return acknowledgements
    }()
}

#endif
