//
//  VDCalendarModels.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 03.09.2025.
//

import Foundation
import SwiftUI

// MARK: - VDScrollDirection
public enum VDScrollDirection {
	case vertical
	case horizontal
}

// MARK: - VDDateRestriction
public enum VDDateRestriction {
	case pastOnly
	case futureOnly
	case allAvailable

	var isFutureAvailable: Bool {
		self == .allAvailable || self == .futureOnly
	}

	var isPastAvailable: Bool {
		self == .allAvailable || self == .pastOnly 
	}
}

// MARK: - VDSelectionMode
public enum VDSelectionMode {
	case single
	case range

	var title: String {
		switch self {
		case .single:
			return "Дата"
		case .range:
			return "Період"
		}
	}
}

// MARK: - VDDayStyle
enum VDDayStyle {
	case unselected
	case selected
	case disabled
	case period
	case hidden

	var canSelect: Bool {
		!(self == .disabled || self == .hidden)
	}

	var isSelected: Bool {
		self == .selected
	}

	var isPeriod: Bool {
		self == .period
	}

	mutating func toggleSelection() {
		self = self == .unselected ? .selected : .unselected
	}
}

// MARK: - VDCalendarStyle
public struct VDCalendarStyle {
	let selectionGradient: GradientProtocol
	let periodColor: Color
	let accentColor: Color
	let controlButtonsColor: Color
	let descriptionFont: Font
	let descriptionColor: Color
	let dayFont: Font
	let dayUnavailableColor: Color
	let dotFont: Font
	let monthHeaderFont: Font
	let dividerColor: Color
	let weekDayColor: Color
	let weekDayFont: Font
	let actionButtonFont: Font
	let weekendColor: Color
	let weekendUnavailableColor: Color
	let todayFont: Font

	public init(
		selectionGradient: GradientProtocol, periodColor: Color, accentColor: Color,
		controlButtonsColor: Color, descriptionFont: Font, descriptionColor: Color, dayFont: Font,
		dayUnavailableColor: Color, dotFont: Font, monthHeaderFont: Font, dividerColor: Color,
		weekDayColor: Color, weekDayFont: Font, actionButtonFont: Font,
		weekendColor: Color, weekendUnavailableColor: Color, todayFont: Font
	) {
		self.selectionGradient = selectionGradient
		self.periodColor = periodColor
		self.accentColor = accentColor
		self.controlButtonsColor = controlButtonsColor
		self.descriptionFont = descriptionFont
		self.descriptionColor = descriptionColor
		self.dayFont = dayFont
		self.dayUnavailableColor = dayUnavailableColor
		self.dotFont = dotFont
		self.monthHeaderFont = monthHeaderFont
		self.dividerColor = dividerColor
		self.weekDayColor = weekDayColor
		self.weekDayFont = weekDayFont
		self.actionButtonFont = actionButtonFont
		self.weekendColor = weekendColor
		self.weekendUnavailableColor = weekendUnavailableColor
		self.todayFont = todayFont
	}

	public static var `default`: VDCalendarStyle {
		VDCalendarStyle(
			selectionGradient: CalendarGradient(start: .blue, end: .purple),
			periodColor: .blue.opacity(0.3),
			accentColor: .blue,
			controlButtonsColor: .blue,
			descriptionFont: .caption,
			descriptionColor: .gray,
			dayFont: .body,
			dayUnavailableColor: .gray.opacity(0.6),
			dotFont: .caption2,
			monthHeaderFont: .headline,
			dividerColor: .gray.opacity(0.3),
			weekDayColor: .gray,
			weekDayFont: .caption,
			actionButtonFont: .headline,
			weekendColor: .red,
			weekendUnavailableColor: .red.opacity(0.4),
			todayFont: .body.bold()
		)
	}
}

public struct CalendarGradient: GradientProtocol{
	let start: Color
	let end: Color

	public func linearGradient() -> LinearGradient {
		.init(colors: [start, end], startPoint: .leading, endPoint: .trailing)
	}
}

// MARK: - VDDay
struct VDDay: Hashable {
	let date: Date
	var type: VDDayStyle
	var count: Int?
}

// MARK: - VDWeek
struct VDWeek: Hashable {
	var days: [VDDay]
}

// MARK: - VDMonth
struct VDMonth: Hashable {
	var weeks: [VDWeek]
}

// MARK: - VDMonthBundle
public struct VDMonthBundle: Hashable {
	public let monthStart: Date
	var month: VDMonth
}

extension VDMonthBundle: Identifiable {
	public var id: String {
		ISO8601DateFormatter().string(from: monthStart)
	}
}

// MARK: - Extension Array VDMonthBundle
extension Array where Element == VDMonthBundle {
	func contains(id: String) -> Bool {
		contains(where: { $0.id == id })
	}

	mutating func apply(_ counts: [Date: Int], calendar: Calendar) {
		let normalizedCounts: [Date: Int] = Dictionary(
			uniqueKeysWithValues: counts.map { (calendar.startOfDay(for: $0.key), $0.value) })

		for bundleIndex in indices {
			for weekIndex in self[bundleIndex].month.weeks.indices {
				for dayIndex in self[bundleIndex].month.weeks[weekIndex].days.indices {
					let dayDate = calendar.startOfDay(
						for: self[bundleIndex].month.weeks[weekIndex].days[dayIndex].date
					)
					if let value = normalizedCounts[dayDate] {
						self[bundleIndex].month.weeks[weekIndex].days[dayIndex].count = value
					}
				}
			}
		}
	}
}

// MARK: - VDCalendarBuilder
struct VDCalendarBuilder {
	let calendar: Calendar

	init(calendar: Calendar = .current) {
		self.calendar = calendar
	}

	/// Builds a `VDMonth` for the month containing `date`.
	/// The month is split into weeks of 7 days. Days outside the target month
	/// are included as `.hidden` to keep full calendar rows.
	func makeMonth(for date: Date) -> VDMonth {
		let startOfMonth = calendar.startOfMonth(for: date)
		let daysInMonth = calendar.daysInMonth(for: startOfMonth)

		// Leading padding days from previous month
		let leading = calendar.normalizedWeekdayIndex(for: startOfMonth)

		// Collect all day cells (previous-month padding + current month + next-month padding)
		var cells: [VDDay] = []
		cells.reserveCapacity(42) // up to 6 weeks

		// Previous-month padding
		if leading > .zero {
			// Determine the last day number of previous month
			let prevStart = calendar.startOfPreviousMonth(for: startOfMonth)
			let prevDays = calendar.daysInMonth(for: prevStart)
			let startDay = prevDays - leading + 1
			for day in startDay...prevDays {
				let date = calendar.date(byAdding: .day, value: day - 1, to: prevStart)!
				cells.append(VDDay(date: date, type: .hidden, count: nil))
			}
		}

		// Current month days
		for day in 1...daysInMonth {
			let date = calendar.date(byAdding: DateComponents(day: day - 1), to: startOfMonth)!
			cells.append(VDDay(date: date, type: .unselected, count: nil))
		}

		// Trailing padding to complete the last week
		let remainder = cells.count % 7
		let trailing = remainder == .zero ? .zero : (7 - remainder)
		if trailing > .zero {
			let nextStart = calendar.startOfNextMonth(for: startOfMonth)
			for day in .zero..<trailing {
				let date = calendar.date(byAdding: .day, value: day, to: nextStart)!
				cells.append(VDDay(date: date, type: .hidden, count: nil))
			}
		}

		// Split into weeks
		var weeks: [VDWeek] = []
		weeks.reserveCapacity((cells.count + 6) / 7)
		for idx in stride(from: .zero, to: cells.count, by: 7) {
			let slice = Array(cells[idx..<min(idx + 7, cells.count)])
			weeks.append(VDWeek(days: slice))
		}

		return VDMonth(weeks: weeks)
	}

	func monthsAround(_ date: Date = .init()) -> [VDMonthBundle] {
		let currentStart = calendar.startOfMonth(for: date)
		let previousStart = calendar.startOfPreviousMonth(for: currentStart)
		let nextStart = calendar.startOfNextMonth(for: currentStart)
		return [
			VDMonthBundle(monthStart: previousStart, month: makeMonth(for: previousStart)),
			VDMonthBundle(monthStart: currentStart, month: makeMonth(for: currentStart)),
			VDMonthBundle(monthStart: nextStart, month: makeMonth(for: nextStart))
		]
	}

	/// Appends the next month after the last bundle's `monthStart`.
	func appendNext(after last: VDMonthBundle) -> VDMonthBundle {
		let nextStart = calendar.startOfNextMonth(for: last.monthStart)
		return VDMonthBundle(monthStart: nextStart, month: makeMonth(for: nextStart))
	}

	func appendNext(after last: VDMonthBundle, with offset: Int) -> [VDMonthBundle] {
		(1..<offset + 1).compactMap { offset in
			if let month = calendar.date(byAdding: .month, value: offset, to: last.monthStart) {
				return VDMonthBundle(monthStart: month, month: makeMonth(for: month))
			}
			return nil
		}
	}

	/// Prepends the previous month before the first bundle's `monthStart`.
	func prependPrevious(before first: VDMonthBundle) -> VDMonthBundle {
		let prevStart = calendar.startOfPreviousMonth(for: first.monthStart)
		return VDMonthBundle(monthStart: prevStart, month: makeMonth(for: prevStart))
	}

	func prependPrevious(before first: VDMonthBundle, with offset: Int) -> [VDMonthBundle] {
		(1..<offset + 1).compactMap { offset in
			if let month = calendar.date(byAdding: .month, value: -offset, to: first.monthStart) {
				return VDMonthBundle(monthStart: month, month: makeMonth(for: month))
			}
			return nil
		}
	}

	func bundle(for date: Date) -> VDMonthBundle {
		let start = calendar.startOfMonth(for: date)
		return VDMonthBundle(monthStart: start, month: makeMonth(for: start))
	}
}
