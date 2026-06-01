import XCTest
import SwiftUI
@testable import DreamRoom

final class BoardViewModelTests: XCTestCase {
    var viewModel: BoardViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = BoardViewModel()
    }
    
    func testAddItem() {
        viewModel.addItem(text: "Test Item")
        
        XCTAssertEqual(viewModel.items.count, 1)
        XCTAssertEqual(viewModel.items.first?.text, "Test Item")
    }
    
    func testBringToFront() {
        viewModel.addItem(text: "Item 1")
        viewModel.addItem(text: "Item 2")
        
        let id1 = viewModel.items[0].id
        let id2 = viewModel.items[1].id
        
        // Initial z-index is 0
        XCTAssertEqual(viewModel.items[0].zIndex, 0)
        XCTAssertEqual(viewModel.items[1].zIndex, 0)
        
        viewModel.bringToFront(id: id1)
        
        XCTAssertGreaterThan(viewModel.items[0].zIndex, viewModel.items[1].zIndex)
        
        viewModel.bringToFront(id: id2)
        XCTAssertGreaterThan(viewModel.items[1].zIndex, viewModel.items[0].zIndex)
    }
    
    func testUpdatePosition() {
        viewModel.addItem(text: "Move me")
        let id = viewModel.items[0].id
        let newPos = CGPoint(x: 500, y: 500)
        
        viewModel.updatePosition(id: id, position: newPos)
        
        XCTAssertEqual(viewModel.items[0].position, newPos)
    }
    
    func testRemoveItem() {
        viewModel.addItem(text: "Delete me")
        let id = viewModel.items[0].id
        
        viewModel.removeItem(id: id)
        
        XCTAssertTrue(viewModel.items.isEmpty)
    }
}
