import XCTest
import SwiftUI
@testable import History

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class HistoryTests: XCTestCase {
	private let history = History()
	private var value = 0
	
    func undoAndRedo() throws {
		history.save(Text("Set Value to 1"), description: "Set Value to 1") { [unowned self] in
			self.value = 1
		} undo: { [unowned self] in
			self.value = 0
		}

        XCTAssertEqual(value, 1)
		XCTAssertEqual(history.nextUndo, "Undo Set Value to 1")
		XCTAssertEqual(history.nextRedo, nil)
		
		history.undo()
		
		XCTAssertEqual(value, 0)
		XCTAssertEqual(history.nextUndo, nil)
		XCTAssertEqual(history.nextRedo, "Redo Set Value to 1")
		
		history.redo()
		
		XCTAssertEqual(value, 1)
		XCTAssertEqual(history.nextUndo, "Undo Set Value to 1")
		XCTAssertEqual(history.nextRedo, nil)
    }
}
