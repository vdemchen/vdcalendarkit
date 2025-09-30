//
//  VDCalendarView.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 03.09.2025.
//

import SwiftUI

// MARK: - VDCalendarView
public struct VDCalendarView: View {
	// MARK: - Properties
	@Environment(\.calendarStyle) private var calendarStyle
	@StateObject public var manager: VDCalendarManager

	public init(manager: VDCalendarManager) {
		self._manager = StateObject(wrappedValue: manager)
	}

	// MARK: - Views
	public var body: some View {
		VStack(spacing: .zero) {
			switch manager.scrollDirection {
			case .horizontal:
				VDHorizontalCalendarView()
			case .vertical:
				FakeView().fixedSize()
				VDVerticalCalendarView()
			}
		}
		.padding(manager.scrollDirection == .vertical ? .zero : 16)
		.environmentObject(manager)
		.onChange(of: manager.monthes) { _ in
			manager.applySelectionStyles()
		}
	}
}

#if DEBUG
#Preview {
	let testProvider = TestCountsProvider()
	Text("test").sheet(isPresented: .constant(true)) {
		var calendar = Calendar.current
		calendar.locale = Locale(identifier: "uk_UA")
		let manager = VDCalendarManager(calendar: calendar, scrollDirection: .vertical)
		manager.dataSource = testProvider
		return NavigationStack {
			VDCalendarView(manager: manager)
		}
	}
}
#endif
