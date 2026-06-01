import XCTest
@testable import DreamRoom

final class ClippingServiceTests: XCTestCase {
    var service: ClippingService!
    
    override func setUp() {
        super.setUp()
        // Reset UserDefaults for a clean state
        UserDefaults.standard.removeObject(forKey: "dreamroom.clips")
        service = ClippingService.shared
        service.clips = []
    }
    
    func testAddClip() {
        let imageUrl = URL(string: "https://example.com/image.jpg")!
        let sourceUrl = URL(string: "https://example.com")!
        
        service.addClip(imageUrl: imageUrl, sourceUrl: sourceUrl)
        
        XCTAssertEqual(service.clips.count, 1)
        XCTAssertEqual(service.clips.first?.imageUrl, imageUrl)
        XCTAssertEqual(service.clips.first?.sourceUrl, sourceUrl)
    }
    
    func testRemoveClip() {
        let imageUrl = URL(string: "https://example.com/image.jpg")!
        service.addClip(imageUrl: imageUrl)
        let clipId = service.clips.first!.id
        
        service.removeClip(id: clipId)
        
        XCTAssertTrue(service.clips.isEmpty)
    }
    
    func testPersistence() {
        let imageUrl = URL(string: "https://example.com/image.jpg")!
        service.addClip(imageUrl: imageUrl)
        
        // Re-initialize service (or simulate reload)
        // In this mock environment, we just check if it's in UserDefaults
        let data = UserDefaults.standard.data(forKey: "dreamroom.clips")
        XCTAssertNotNil(data)
        
        let decoded = try? JSONDecoder().decode([Clip].self, from: data!)
        XCTAssertEqual(decoded?.count, 1)
        XCTAssertEqual(decoded?.first?.imageUrl, imageUrl)
    }
}
