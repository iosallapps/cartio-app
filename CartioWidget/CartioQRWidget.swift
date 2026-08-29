//
//  CartioQRWidget.swift
//  CartioWidget
//
//  Displays the default card's QR code + name/title.
//  Tapping opens the Share Hub in the main app.
//

import WidgetKit
import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - Timeline Entry

struct CardEntry: TimelineEntry {
    let date: Date
    let cardData: WidgetCardData?
    let qrImage: UIImage?
}

// MARK: - Timeline Provider

struct CartioTimelineProvider: TimelineProvider {

    func placeholder(in context: Context) -> CardEntry {
        CardEntry(
            date: .now,
            cardData: WidgetCardData(name: "John Doe", title: "Designer", company: "Acme Inc", shareURL: "https://cartio.me/johndoe"),
            qrImage: generateQR(from: "https://cartio.me/johndoe")
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CardEntry) -> Void) {
        let card = loadCard()
        completion(CardEntry(
            date: .now,
            cardData: card,
            qrImage: card.map { generateQR(from: $0.shareURL, colorHex: $0.qrColorHex) } ?? nil
        ))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CardEntry>) -> Void) {
        let card = loadCard()
        let entry = CardEntry(
            date: .now,
            cardData: card,
            qrImage: card.map { generateQR(from: $0.shareURL, colorHex: $0.qrColorHex) } ?? nil
        )
        // Refresh once per hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func loadCard() -> WidgetCardData? {
        guard let defaults = UserDefaults(suiteName: "group.com.cartio.app"),
              let data = defaults.data(forKey: "widgetDefaultCard") else { return nil }
        return try? JSONDecoder().decode(WidgetCardData.self, from: data)
    }

    private func parseHexColor(_ hex: String) -> CIColor {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        return CIColor(red: r, green: g, blue: b)
    }

    private func generateQR(from string: String, colorHex: String = "#0A7E8C") -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        guard let output = filter.outputImage else { return nil }

        let colorFilter = CIFilter.falseColor()
        colorFilter.inputImage = output
        let color = parseHexColor(colorHex)
        colorFilter.color0 = color
        colorFilter.color1 = CIColor.white

        guard let colored = colorFilter.outputImage else { return nil }

        let scale: CGFloat = 200 / colored.extent.width
        let scaled = colored.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Widget Definition

struct CartioQRWidget: Widget {
    let kind = "CartioQRWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CartioTimelineProvider()) { entry in
            CartioWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("My Card")
        .description("Quick access to your digital business card QR code.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

// MARK: - Entry View

struct CartioWidgetEntryView: View {
    let entry: CardEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .accessoryCircular:
            circularWidget
        case .accessoryRectangular:
            rectangularWidget
        default:
            smallWidget
        }
    }

    // MARK: - Circular (Lock Screen): Initials

    private var circularWidget: some View {
        ZStack {
            AccessoryWidgetBackground()
            if let card = entry.cardData {
                Text(initials(from: card.name))
                    .font(.system(size: 20, weight: .bold))
            } else {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 22))
            }
        }
        .widgetURL(URL(string: "cartio://share"))
    }

    // MARK: - Rectangular (Lock Screen): Name + Title

    private var rectangularWidget: some View {
        HStack(spacing: 6) {
            Image(systemName: "qrcode")
                .font(.system(size: 18))
            VStack(alignment: .leading, spacing: 2) {
                if let card = entry.cardData {
                    Text(card.name)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)
                    if !card.title.isEmpty {
                        Text(card.title)
                            .font(.system(size: 11))
                            .lineLimit(1)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("Set up Cartio")
                        .font(.system(size: 13, weight: .semibold))
                }
            }
        }
        .widgetURL(URL(string: "cartio://share"))
    }

    // MARK: - Helpers

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.count > 1 ? parts.last!.prefix(1) : ""
        return "\(first)\(last)".uppercased()
    }

    // MARK: - Small: QR only

    private var smallWidget: some View {
        VStack(spacing: 4) {
            if let qrImage = entry.qrImage {
                Image(uiImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .padding(4)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                placeholderView
            }

            if let name = entry.cardData?.name {
                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                    .lineLimit(1)
                    .foregroundStyle(.primary)
            }
        }
        .padding(8)
        .widgetURL(URL(string: "cartio://share"))
    }

    // MARK: - Medium: QR + details

    private var mediumWidget: some View {
        HStack(spacing: 12) {
            if let qrImage = entry.qrImage {
                Image(uiImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 120, maxHeight: 120)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                placeholderView
                    .frame(width: 120, height: 120)
            }

            if let card = entry.cardData {
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.name)
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(1)
                        .foregroundStyle(.primary)

                    if !card.title.isEmpty {
                        Text(card.title)
                            .font(.system(size: 13))
                            .lineLimit(1)
                            .foregroundStyle(.secondary)
                    }

                    if !card.company.isEmpty {
                        Text(card.company)
                            .font(.system(size: 12))
                            .lineLimit(1)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("Scan to connect")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color(red: 0.04, green: 0.49, blue: 0.55))
                }
                .padding(.vertical, 4)

                Spacer()
            }
        }
        .padding(12)
        .widgetURL(URL(string: "cartio://share"))
    }

    private var placeholderView: some View {
        VStack(spacing: 8) {
            Image(systemName: "qrcode")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            Text("Set up a card")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - WidgetCardData (duplicated for widget target)

struct WidgetCardData: Codable {
    let name: String
    let title: String
    let company: String
    let shareURL: String
    let qrColorHex: String

    init(name: String, title: String, company: String, shareURL: String, qrColorHex: String = "#000000") {
        self.name = name
        self.title = title
        self.company = company
        self.shareURL = shareURL
        self.qrColorHex = qrColorHex
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        title = try container.decode(String.self, forKey: .title)
        company = try container.decode(String.self, forKey: .company)
        shareURL = try container.decode(String.self, forKey: .shareURL)
        qrColorHex = try container.decodeIfPresent(String.self, forKey: .qrColorHex) ?? "#000000"
    }
}
