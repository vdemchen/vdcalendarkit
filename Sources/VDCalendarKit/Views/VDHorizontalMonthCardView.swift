
//
//  VDHorizontalMonthCardView.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 17.09.2025.
//

import SwiftUI

// MARK: - VDHorizontalMonthCardView
struct VDHorizontalMonthCardView: View {
	@EnvironmentObject private var manager: VDCalendarManager
	@Environment(\.calendarStyle) private var calendarStyle
	@Binding var bundle: VDMonthBundle

	var body: some View {
		VStack(spacing: 16) {
			VDMonthHeaderView(monthDate: bundle.monthStart)

			VStack {
				VDWeekHeaderView(padding: .zero)
					.frame(maxWidth: .infinity)
				VDMonthView(month: $bundle.month)
			}
			Spacer()
		}
	}
}
