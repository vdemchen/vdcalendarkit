//
//  VDHorizontalCalendarView.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 17.09.2025.
//

import SwiftUI

// MARK: - VDHorizontalCalendarView
struct VDHorizontalCalendarView: View {
	// MARK: - Properties
	@EnvironmentObject private var manager: VDCalendarManager

	// MARK: - Views
	var body: some View {
		VStack {
			if !manager.monthes.isEmpty && manager.currentMonthIndex < manager.monthes.count {
				let bundle = $manager.monthes[manager.currentMonthIndex]
				VDHorizontalMonthCardView(bundle: bundle)
					.frame(maxHeight: .infinity)
			}
		}
	}
}

#if DEBUG
#Preview {
	let testProvider = TestCountsProvider()
	Text("test").sheet(isPresented: .constant(true)) {
		var calendar = Calendar.current
		calendar.locale = Locale(identifier: "uk_UA")
		let manager = VDCalendarManager(calendar: calendar, scrollDirection: .horizontal)
		manager.dataSource = testProvider
		return VDHorizontalCalendarView()
			.environmentObject(manager)
	}
}
#endif
