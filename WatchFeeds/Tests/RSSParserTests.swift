import XCTest
@testable import WatchFeeds

final class RSSParserTests: XCTestCase {
    func testParsesBasicRSS() {
        let xml = """
        <rss><channel>
            <item>
                <title>Example</title>
                <link>https://example.com</link>
                <pubDate>Mon, 01 Jan 2024 10:00:00 +0000</pubDate>
                <description>Hello world</description>
            </item>
        </channel></rss>
        """
        let data = xml.data(using: .utf8)!
        let parser = RSSParser()
        let items = parser.parse(data: data)
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.title, "Example")
        XCTAssertEqual(items.first?.link, "https://example.com")
    }
}
