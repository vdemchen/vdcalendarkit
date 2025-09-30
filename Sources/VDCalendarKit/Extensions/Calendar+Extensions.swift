//
//  Calendar+Extensions.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 16.09.2025.
//

import Foundation

extension Calendar {
	/// Returns the first moment of the month that contains `date`.
	func startOfMonth(for date: Date) -> Date {
		let comps = dateComponents([.year, .month], from: date)
		return self.date(from: comps)!
	}

	/// Returns the first moment of the next month after the month that contains `date`.
	func startOfNextMonth(for date: Date) -> Date {
		let start = startOfMonth(for: date)
		return self.date(byAdding: DateComponents(month: 1), to: start)!
	}

	/// Returns the first moment of the previous month before the month that contains `date`.
	func startOfPreviousMonth(for date: Date) -> Date {
		let start = startOfMonth(for: date)
		return self.date(byAdding: DateComponents(month: -1), to: start)!
	}

	/// Number of days in the month that contains `date`.
	func daysInMonth(for date: Date) -> Int {
		let range = range(of: .day, in: .month, for: date)!
		return range.count
	}

	/// Weekday index normalized to 0...6 relative to `firstWeekday`
	/// (0 == firstWeekday, 6 == the day before firstWeekday)
	func normalizedWeekdayIndex(for date: Date) -> Int {
		// Apple's `.weekday` is 1...7 where 1 == Sunday (Gregorian).
		let weekday = component(.weekday, from: date) // 1...7
		let first = firstWeekday // 1...7
		// Convert to 0...6 with respect to firstWeekday
		return (weekday - first + 7) % 7
	}

	func isBetweenExclusive(_ date: Date, _ start: Date, _ end: Date) -> Bool {
		compare(date, to: start, toGranularity: .day) == .orderedDescending
		&& compare(date, to: end, toGranularity: .day) == .orderedAscending
	}
}
