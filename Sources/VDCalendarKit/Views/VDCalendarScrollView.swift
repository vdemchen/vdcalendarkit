//
//  VDCalendarScrollView.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 17.09.2025.
//

import SwiftUI

// MARK: - VDCalendarScrollView
struct VDCalendarScrollView: View {
	@EnvironmentObject private var manager: VDCalendarManager
	@State private var didInitialScroll = false

	var body: some View {
		ScrollViewReader { proxy in
			let scroll = ScrollView {
				VDCalendarListView()
			}
				.scrollIndicators(.hidden)
				.onAppear {
					guard !manager.monthes.isEmpty else { return }
					showCurrentMonth(manager.monthes, proxy: proxy)
				}
				.onChange(of: manager.monthes) { newValue in
					guard !didInitialScroll, newValue.count > 1 else { return }
					showCurrentMonth(newValue, proxy: proxy)
					didInitialScroll = true
				}

			if #available(iOS 17.0, *) {
				scroll
					.scrollTargetLayout()
					.scrollTargetBehavior(.viewAligned(limitBehavior: .always))
			} else {
				scroll
			}
		}
	}

	private func showCurrentMonth(_ bundles: [VDMonthBundle], proxy: ScrollViewProxy) {
		if let target = bundles.first(where: {
			manager.calendar.isDate($0.monthStart, equalTo: Date(), toGranularity: .month)
		}) {
			DispatchQueue.main.async {
				proxy.scrollTo(target.id, anchor: .top)
			}
		}
	}
}
