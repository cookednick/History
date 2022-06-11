import Observable
import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public class History {
	private var undos = [Action]()
	private var redos = [Action]()
	
	@Observable public var nextUndo: String?
	@Observable public var nextRedo: String?
	
	@Observable public var toast: Toast? {
		didSet {
			if toast != nil {
				toastTimer = .scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
					self?.toast = nil
				}
			} else {
				toastTimer = nil
			}
		}
	}
	private var toastTimer: Timer?
	
	
	public init() { }
	
	
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
		toast = Toast(Text("Undo \(action.toast)"))
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
		toast = Toast(Text("Redo \(action.toast)"))
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
	
	public struct Toast: Hashable {
		public let text: Text
		public let id: UUID
		
		
		public init(_ text: Text) {
			self.text = text
			id = UUID()
		}
		
		
		public func hash(into hasher: inout Hasher) {
			hasher.combine(id)
		}
		
		
		public static func ==(lhs: Toast, rhs: Toast) -> Bool {
			lhs.id == rhs.id
		}
	}
}
