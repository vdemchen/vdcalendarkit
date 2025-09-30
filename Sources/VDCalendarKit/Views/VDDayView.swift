//
//  VDDayView.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 03.09.2025.
//

import SwiftUI

struct VDDayView: View {
	private enum Constants {
		static let gradientSize = 8.0
	}
	@Binding private(set) var day: VDDay

	@Environment(\.calendarStyle) private var calendarStyle
	@EnvironmentObject private var manager: VDCalendarManager

	var body: some View {
		ZStack {
			if day.type == .hidden {
				EmptyView()
			} else {
				dayView
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.aspectRatio(1, contentMode: .fit)
		.disabled(!day.type.canSelect)
		.onTapGesture {
			guard day.type.canSelect else { return }
			manager.select(day: day)
		}
		.zIndex(day.type.isSelected ? 2 : day.type.isPeriod ? 1 : 0)
	}

	private var textColor: Color {
		if day.type.isSelected {
			return .white
		}
		if manager.isToday(day) {
			return calendarStyle.accentColor
		}
		if !day.type.canSelect {
			return manager.isWeekend(day) ? calendarStyle.weekendUnavailableColor
			: calendarStyle.dayUnavailableColor
		}
		if manager.isWeekend(day) {
			return calendarStyle.weekendColor
		}
		return .black
	}

	private var textFont: Font {
		manager.isToday(day) ? calendarStyle.todayFont : calendarStyle.dayFont
	}

	private var dayView: some View {
		ZStack(alignment: .center) {
			background
			VStack(spacing: .zero) {
				Spacer(minLength: 4)
				Text(DateFormatter.dayFormatter.string(from: day.date))
					.foregroundStyle(textColor)
					.font(.init(textFont))
					.fontWeight(manager.isToday(day) ? .bold : .regular)
					.multilineTextAlignment(.center)
				Group {
					if day.type.canSelect, let count = day.count {
						VDDotView(count: count, type: $day.type)
					} else {
						Spacer()
					}
				}
				.frame(width: 16, height: 16)
				.padding(.bottom, 2)
			}
		}
	}

	private var background: some View {
		ZStack {
			if day.type.isSelected {
				if manager.isLastSelectedDay(day) && manager.areSelectedDatesAdjacent {
					GeometryReader { geo in
						calendarStyle.periodColor
							.offset(x: geo.size.width / -2)
					}
				}
				calendarStyle.selectionGradient.linearGradient()
					.cornerRadius(12)
					.padding(.horizontal, 4)
			}
			if day.type.isPeriod {
				let isDayLeftEdge = manager.isDayLeftEdgeOfPeriod(day)
				let isDayRightEdge = manager.isDayRightEdgeOfPeriod(day)
				let isDayStartPeriod = manager.isDayStartPeriod(day)
				let isDayEndPeriod = manager.isDayEndPertiod(day)
				let isFirstDayOfMonth = manager.isFirstMonthDay(day)
				let isLastDayOfMonth = manager.isLastMonthDay(day)

				calendarStyle.periodColor

				if isDayLeftEdge || isFirstDayOfMonth {
					leftGradient(with: Constants.gradientSize)
				}
				if isDayRightEdge || isLastDayOfMonth {
					rightGradient(with: Constants.gradientSize)
				}

				if isDayStartPeriod {
					GeometryReader { reader in
						leftGradient(with: reader.size.width / 2)
					}
				}
				if isDayEndPeriod {
					GeometryReader { reader in
						rightGradient(with: reader.size.width / 2)
					}
				}
			}
		}
	}

	private func leftGradient(with gradientSize: Double) -> some View {
		LinearGradient(
			colors: [.clear, calendarStyle.periodColor],
			startPoint: .leading,
			endPoint: .trailing
		)
		.frame(maxHeight: .infinity)
		.frame(width: gradientSize)
		.padding(.horizontal, -gradientSize)
		.frame(maxWidth: .infinity, alignment: .leading)
	}

	private func rightGradient(with gradientSize: Double) -> some View {
		LinearGradient(
			colors: [calendarStyle.periodColor, .clear],
			startPoint: .leading,
			endPoint: .trailing
		)
		.frame(maxHeight: .infinity)
		.frame(width: gradientSize)
		.padding(.horizontal, -gradientSize)
		.offset(x: gradientSize)
		.frame(maxWidth: .infinity, alignment: .trailing)
	}
}

#if DEBUG
#Preview {
	let calendar = Calendar.current
	let today = Date()
	let weekend = calendar.date(byAdding: .day, value: 1, to: today)! // Припускаємо, що наступний день - вихідний

	VStack {
		// Сьогоднішній день
		VDDayView(day: .constant(.init(date: today, type: .unselected, count: 2)))
			.frame(width: 40, height: 40)

		// Вихідний день
		VDDayView(day: .constant(.init(date: weekend, type: .disabled, count: nil)))
			.frame(width: 40, height: 40)

		// Обраний день
		VDDayView(day: .constant(.init(date: today, type: .selected, count: 3)))
			.frame(width: 40, height: 40)
	}
	.environmentObject(VDCalendarManager())
	.environment(\.calendarStyle, .default)
}
#endif
