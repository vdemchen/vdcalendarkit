//
//  VDWeekHeaderView.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 15.09.2025.
//

import SwiftUI

struct VDWeekHeaderView: View {
	@EnvironmentObject private var manager: VDCalendarManager
	@Environment(\.calendarStyle) private var calendarStyle
	private(set) var padding: CGFloat = 24

    var body: some View {
		if manager.scrollDirection == .horizontal {
			weekView
		} else {
			VStack {
				Divider()
					.background(calendarStyle.dividerColor)
				weekView
				Divider()
					.background(calendarStyle.dividerColor)
			}
		}
    }

	private var weekView: some View {
		HStack(alignment: .center, spacing: .zero) {
			ForEach(manager.calendar.shortWeekdaySymbols.map(\.capitalized), id: \.self) { weekday in
				Text(weekday)
					.font(calendarStyle.weekDayFont)
					.foregroundColor(calendarStyle.weekDayColor)
					.frame(maxWidth: .infinity)
					.multilineTextAlignment(.center)
			}
		}
		.padding(.horizontal, padding)
	}
}

#if DEBUG
#Preview {
	var calendar = Calendar.current
	calendar.locale = Locale(identifier: "uk_UA")
	return VDWeekHeaderView(padding: .zero)
		.environmentObject(VDCalendarManager(calendar: calendar))
}
#endif
