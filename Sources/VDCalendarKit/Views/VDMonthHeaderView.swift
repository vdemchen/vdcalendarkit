//
//  VDMonthHeaderView.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 03.09.2025.
//

import SwiftUI

// MARK: - VDMonthHeaderView
struct VDMonthHeaderView: View {
	// MARK: - Properties
	@EnvironmentObject private var manager: VDCalendarManager
	@Environment(\.calendarStyle) private var calendarStyle
	private(set) var monthDate: Date

	private var title: String {
		let number = manager.calendar.component(.month, from: monthDate)
		let monthName = manager.calendar.standaloneMonthSymbols[number - 1].capitalized
		let year = DateFormatter.yearFormatter.string(from: monthDate)
		return "\(monthName) \(year)"
	}

	// MARK: - View
	var body: some View {
		VStack(spacing: 8) {
			HStack {
				Text(title)
					.font(calendarStyle.monthHeaderFont)
					.lineSpacing(6)
				Spacer()
				if manager.scrollDirection == .horizontal {
					controlView
				}
			}
			Divider()
				.background(calendarStyle.dividerColor)
		}
    }

	private var controlView: some View {
		HStack(spacing: 16) {
			Button(action: {
				manager.navigateToPreviousMonth()
			}) {
				Image(systemName: "chevron.left")
					.font(.system(size: 16, weight: .medium))
					.foregroundColor(manager.canNavigateToPrevious ? calendarStyle.controlButtonsColor : calendarStyle.controlButtonsColor.opacity(0.3))
			}
			.disabled(!manager.canNavigateToPrevious)

			Button(action: {
				manager.navigateToNextMonth()
			}) {
				Image(systemName: "chevron.right")
					.font(.system(size: 16, weight: .medium))
					.foregroundColor(manager.canNavigateToNext ? calendarStyle.controlButtonsColor : calendarStyle.controlButtonsColor.opacity(0.3))
			}
			.disabled(!manager.canNavigateToNext)
			.onChange(of: manager.canNavigateToNext) { newValue in
				print(newValue)
			}
		}
	}
}

#if DEBUG
// MARK: - Preview
#Preview {
	VDMonthHeaderView(monthDate: .init())
		.environmentObject(VDCalendarManager())
}
#endif
