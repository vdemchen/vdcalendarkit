//
//  VDMonthBundleView.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 17.09.2025.
//

import SwiftUI

// MARK: - VDMonthBundleView
struct VDMonthBundleView: View {
	@EnvironmentObject private var manager: VDCalendarManager
	@Binding var bundle: VDMonthBundle

	var body: some View {
		let value = $bundle.wrappedValue
		let content = VStack {
			VDMonthHeaderView(monthDate: value.monthStart)
			VDMonthView(month: $bundle.month)
		}
		.id(value.id)

		if manager.scrollDirection == .horizontal {
			content
				.frame(minWidth: 320)
		} else {
			content
		}
	}
}
