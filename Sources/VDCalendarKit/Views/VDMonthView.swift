//
//  VDMonthView.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 03.09.2025.
//

import SwiftUI

struct VDMonthView: View {
	@Binding private(set) var month: VDMonth

	var body: some View {
		VStack(spacing: 8) {
			ForEach($month.weeks, id: \.self) { week in
				VDWeekView(week: week)
			}
		}
	}
}

#if DEBUG
#Preview {
	let builder = VDCalendarBuilder()
	var month = builder.monthsAround(Date())[1].month
	// Give all days a sample count value
	for week in month.weeks.indices {
		for day in month.weeks[week].days.indices {
			let number = Int.random(in: 0...6)
			month.weeks[week].days[day].count = number == 0 ? nil : number
		}
	}
	return VDMonthView(month: .constant(month))
}
#endif
