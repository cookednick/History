import Observable
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public class History {
	private var undos = [Action]()
	private var redos = [Action]()
	
	@Observable public var nextUndo: String?
	@Observable public var nextRedo: String?
	
	
	public func save(_ toast: Text, description: String, _ action: @escaping () -> Void, undo: @escaping () -> Void) {
		redos = []
		nextRedo = nil
		action()
		undos.append(Action(toast, description: description, action: action, undo: undo))
		nextUndo = "Undo " + description
	}
	
	@discardableResult
	public func undo() -> Bool {
		guard !undos.isEmpty else { return false }
		let action = undos.removeLast()
		action.undo()
		redos.append(action)
		
		if let next = undos.last {
			nextUndo = "Undo " + next.description
		} else {
			nextUndo = nil
		}
		
		nextRedo = "Redo " + action.description
		return true
	}
	
	@discardableResult
	public func redo() -> Bool {
		guard !redos.isEmpty else { return false }
		let action = redos.removeLast()
		action.redo()
		undos.append(action)
		nextUndo = "Undo " + action.description
		
		if let next = redos.last {
			nextRedo = "Redo " + next.description
		} else {
			nextRedo = nil
		}
		
		return true
	}
	
	
	private struct Action {
		let toast: Text
		let description: String
		let redo: () -> Void
		let undo: () -> Void
		
		
		init(_ toast: Text, description: String, action: @escaping () -> Void, undo: @escaping () -> Void) {
			self.toast = toast
			self.description = description
			self.redo = action
			self.undo = undo
		}
	}
}
