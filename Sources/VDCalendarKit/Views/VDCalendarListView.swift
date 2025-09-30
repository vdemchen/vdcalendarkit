//
//  VDCalendarListView.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 17.09.2025.
//

import SwiftUI

// MARK: - VDCalendarListView
struct VDCalendarListView: View {
	@EnvironmentObject private var manager: VDCalendarManager

	var body: some View {
		LazyVStack(spacing: 32) {
			VDLoadNextView {
				manager.setupPrevIfNeeded()
			}
			ForEach($manager.previousMonthes) { bundle in
				VDMonthBundleView(bundle: bundle)
					.onAppear {
						Task { await manager.fetchCountsForPrevious(for: [bundle.wrappedValue]) }
					}
			}
			ForEach($manager.monthes) { bundle in
				VDMonthBundleView(bundle: bundle)
					.onAppear {
						Task { await manager.fetchCountsForNext(for: [bundle.wrappedValue]) }
					}
			}
			VDLoadNextView {
				manager.setupNextIfNeeded()
			}
		}
		.padding(.horizontal, 16)
	}
}
