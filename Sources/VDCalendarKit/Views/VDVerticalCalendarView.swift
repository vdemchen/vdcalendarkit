//
//  VDVerticalCalendarView.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 17.09.2025.
//

import SwiftUI

// MARK: - VDVerticalCalendarView
public struct VDVerticalCalendarView: View {
	// MARK: - Properties
	@EnvironmentObject private var manager: VDCalendarManager
	@State private var isShowActionButton = false

	// MARK: - Views
	public var body: some View {
		ZStack {
			VStack {
				VDCalendarSelectedDateView()
				VDWeekHeaderView(padding: 16)
				VDCalendarScrollView()
			}

			VDActionButtonView(isShowActionButton: $isShowActionButton)
		}
		.onChange(of: manager.isShowActionButton) { newValue in
			isShowActionButton = newValue
		}
		.onChange(of: manager.actionButtonTitle) { newValue in
			isShowActionButton = newValue != nil
		}
	}
}

#if DEBUG
#Preview {
	let testProvider = TestCountsProvider()
	Text("test").sheet(isPresented: .constant(true)) {
		var calendar = Calendar.current
		calendar.locale = Locale(identifier: "uk_UA")
		let manager = VDCalendarManager(calendar: calendar)
		manager.dataSource = testProvider
		return VDVerticalCalendarView()
			.environmentObject(manager)
	}
}
#endif
