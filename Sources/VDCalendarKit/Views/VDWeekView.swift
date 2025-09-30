//
//  VDWeekView.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 03.09.2025.
//

import SwiftUI

struct VDWeekView: View {
	@Binding private(set) var week: VDWeek
	@Environment(\.calendarStyle) private var calendarStyle

	private(set) var didTapDay: ((VDDay) -> Void)?

	var body: some View {
		HStack(spacing: .zero) {
			ForEach($week.days, id: \.self) { day in
				VDDayView(day: day)
			}
		}
	}
}

#if DEBUG
#Preview {
	let week: VDWeek = {
		let builder = VDCalendarBuilder()
		var week = builder.monthsAround(Date())[1].month.weeks[0]
		for day in week.days.indices {
			week.days[day].count = 2
		}
		return week
	}()
	return VDWeekView(week: .constant(week))
		.frame(height: 48)
}
#endif
