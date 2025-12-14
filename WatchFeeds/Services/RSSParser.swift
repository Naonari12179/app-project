import Foundation

final class RSSParser: NSObject, XMLParserDelegate {
    struct RSSItem {
        var title: String
        var link: String
        var pubDate: Date?
        var description: String?
    }

    private var currentElement: String = ""
    private var currentItem: RSSItem?
    private var foundCharacters = ""
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return formatter
    }()

    private(set) var items: [RSSItem] = []

    func parse(data: Data) -> [RSSItem] {
        items = []
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return items
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "item" || elementName == "entry" {
            currentItem = RSSItem(title: "", link: "", pubDate: nil, description: nil)
        }
        foundCharacters = ""
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        foundCharacters += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard var item = currentItem else { return }
        switch elementName {
        case "title":
            item.title += foundCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
        case "link":
            if item.link.isEmpty { item.link = foundCharacters.trimmingCharacters(in: .whitespacesAndNewlines) }
        case "pubDate", "updated":
            if let date = dateFormatter.date(from: foundCharacters.trimmingCharacters(in: .whitespacesAndNewlines)) {
                item.pubDate = date
            }
        case "description", "summary", "content":
            let content = foundCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
            item.description = (item.description ?? "") + content
        case "item", "entry":
            items.append(item)
            currentItem = nil
        default:
            break
        }
        foundCharacters = ""
    }
}
