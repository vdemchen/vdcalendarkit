//
//  VDCalendarSelectedDateView.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 17.09.2025.
//

import SwiftUI

// MARK: - VDCalendarSelectedDateView
struct VDCalendarSelectedDateView: View {
	@EnvironmentObject private var manager: VDCalendarManager
	@Environment(\.calendarStyle) private var calendarStyle

	var body: some View {
		Group {
			guard let startDate = manager.startDate, let endDate = manager.endDate else {
				return Text("Весь час")
			}
			let formatter = DateFormatter.dateFormatter
			return Text("\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))")
		}
		.font(.init(calendarStyle.descriptionFont))
		.foregroundStyle(calendarStyle.descriptionColor)
		.lineSpacing(4)
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding([.horizontal, .bottom], 16)
		.padding(.top, 4)
	}
}
