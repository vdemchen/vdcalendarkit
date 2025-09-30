//
//  VDCalendarManager.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 08.09.2025.
//

import Foundation
import UIKit

// MARK: - Notification.Name
extension Notification.Name {
	static let calendarSetupPrevMonth = Notification.Name("calendarSetupPrevMonth")
}

// MARK: - VDCalendarManager
@MainActor public final class VDCalendarManager: ObservableObject {
	// MARK: - Published properties
	@Published var selectionMode: VDSelectionMode
	@Published public var startDate: Date?
	@Published public var endDate: Date?
	@Published var monthes = [VDMonthBundle]()
	@Published var previousMonthes = [VDMonthBundle]()
	@Published var currentMonthIndex = 1
	@Published var actionButtonTitle: String?

	// MARK: - Properties
	var scrollDirection: VDScrollDirection = .vertical
	var dateRestriction: VDDateRestriction = .allAvailable
	var availableDates: Set<Date>?

	// MARK: - Private properties
	private let builder: VDCalendarBuilder

	// MARK: - Computed properties
	public var isResetEnabled: Bool {
		startDate != nil
	}

	var calendar: Calendar {
		builder.calendar
	}

	var canNavigateToPrevious: Bool {
		guard let currentBundle = monthes.indices.contains(currentMonthIndex)
				? monthes[currentMonthIndex] : nil else { return false }

		if availableDates != nil {
			guard let prevMonthStart = calendar.date(byAdding: .month, value: -1, to: currentBundle.monthStart) else { return false }
			return hasAvailableDatesInMonth(prevMonthStart)
		}

		switch dateRestriction {
		case .futureOnly:
			let today = calendar.startOfDay(for: Date())
			let currentMonth = calendar.startOfDay(for: currentBundle.monthStart)
			return currentMonth > today
		default:
			return true
		}
	}

	var canNavigateToNext: Bool {
		guard monthes.indices.contains(currentMonthIndex) else { return false }
		let currentBundle = monthes[currentMonthIndex]

		let nextCalendarMonthStart: Date
		if currentMonthIndex + 1 < monthes.count {
			nextCalendarMonthStart = monthes[currentMonthIndex + 1].monthStart
		} else {
			guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentBundle.monthStart) else {
				return false
			}
			nextCalendarMonthStart = nextMonth
		}

		if availableDates != nil {
			return hasAvailableDatesInMonth(nextCalendarMonthStart)
		}

		switch dateRestriction {
		case .pastOnly:
			let today = calendar.startOfDay(for: Date())
			let nextCalendarMonth = calendar.startOfDay(for: nextCalendarMonthStart)
			let currentRealMonth = calendar.startOfMonth(for: today)
			return nextCalendarMonth <= currentRealMonth
		default:
			return true
		}
	}

	var isShowActionButton: Bool {
		if selectionMode == .range {
			return startDate != nil && totalSelectedCount > .zero
		}
		return false
	}

	var totalSelectedCount: Int {
		guard let startDate else { return .zero }

		var totalCount = 0
		let allBundles = previousMonthes + monthes

		for bundle in allBundles {
			for week in bundle.month.weeks {
				for day in week.days {
					let dayDate = calendar.startOfDay(for: day.date)
					let shouldInclude: Bool

					switch selectionMode {
					case .single:
						shouldInclude = calendar.isDate(dayDate, inSameDayAs: startDate)
					case .range:
						if let endDate {
							shouldInclude = calendar.isDate(dayDate, inSameDayAs: startDate) ||
											calendar.isDate(dayDate, inSameDayAs: endDate) ||
											calendar.isBetweenExclusive(dayDate, startDate, endDate)
						} else {
							shouldInclude = calendar.isDate(dayDate, inSameDayAs: startDate)
						}
					}

					if shouldInclude {
						totalCount += day.count ?? .zero
					}
				}
			}
		}

		return totalCount
	}

	var areSelectedDatesAdjacent: Bool {
		guard let startDate, let endDate else { return false }
		let start = calendar.dateInterval(of: .day, for: startDate)?.end
		let end = calendar.dateInterval(of: .day, for: endDate)?.start
		return start == end
	}

	// MARK: - Provider
	public weak var dataSource: VDCalendarCountsDataSource?

	// MARK: - Init
	public init(
		selectionMode: VDSelectionMode = .range, calendar: Calendar = .current,
		scrollDirection: VDScrollDirection = .vertical,
		availableDates: Set<Date>? = nil,
		dateRestriction: VDDateRestriction = .allAvailable
	) {
		self.selectionMode = selectionMode
		self.builder = VDCalendarBuilder(calendar: calendar)
		self.scrollDirection = scrollDirection
		self.dateRestriction = dateRestriction
		self.availableDates = availableDates?.map { calendar.startOfDay(for: $0) }.compactMap { $0 }
			.reduce(into: Set<Date>()) { result, date in
				result.insert(date)
			}
	}

	// MARK: - Public methods
	public func setup() {
		switch scrollDirection {
		case .vertical:
			setupVertical()
		case .horizontal:
			setupHorizontal()
		}
	}

	public func reset() {
		startDate = nil
		endDate = nil
		actionButtonTitle = nil
		applySelectionStyles()
	}

	// MARK: - Internal methods
	func fetchCountsForNext(for monthes: [VDMonthBundle]) async {
		let counts: [Date: Int] = await dataSource?.fetchCounts(for: monthes) ?? [:]
		self.monthes.apply(counts, calendar: calendar)
	}

	func fetchCountsForPrevious(for monthes: [VDMonthBundle]) async {
		let counts: [Date: Int] = await dataSource?.fetchCounts(for: monthes) ?? [:]
		previousMonthes.apply(counts, calendar: calendar)
	}

	func setupNextIfNeeded() {
		Task { @MainActor in
			guard let last = self.monthes.last, dateRestriction.isFutureAvailable else { return }

			let nextBundles = self.builder.appendNext(after: last, with: 1)
			if !self.monthes.contains(nextBundles) {
				self.monthes.append(contentsOf: nextBundles)
			}
		}
	}

	func setupPrevIfNeeded() {
		Task { @MainActor in
			guard let currentFirst = previousMonthes.first, dateRestriction.isPastAvailable else { return }

			let prevBundles = builder.prependPrevious(before: currentFirst, with: 1)
			if !previousMonthes.contains(prevBundles) {
				previousMonthes.insert(contentsOf: prevBundles.reversed(), at: .zero)
			}
		}
	}

	func navigateToPreviousMonth() {
		if currentMonthIndex > .zero {
			currentMonthIndex -= 1
		} else {
			guard let firstMonth = monthes.first else { return }
			let prevBundle = builder.prependPrevious(before: firstMonth)
			monthes.insert(prevBundle, at: .zero)

			if monthes.count > 5 {
				monthes.removeLast()
			}

			currentMonthIndex = .zero
		}
	}

	func navigateToNextMonth() {
		if currentMonthIndex < monthes.count - 1 {
			currentMonthIndex += 1
		} else {
			guard let lastMonth = monthes.last else { return }
			let nextBundle = builder.appendNext(after: lastMonth)
			monthes.append(nextBundle)

			if monthes.count > 5 {
				monthes.removeFirst()
				currentMonthIndex = monthes.count - 1
			} else {
				currentMonthIndex = monthes.count - 1
			}
		}
	}

	func navigateToDate(_ targetDate: Date) {
		let newMonthes = builder.monthsAround(targetDate)
		monthes = newMonthes
		currentMonthIndex = 1
	}

	func select(day: VDDay) {
		switch selectionMode {
		case .single:
			startDate = day.date
			Task {
				await loadAsyncActionButtonTitle()
			}
		case .range:
			handleRangeSelection(with: day.date)

			let count = totalSelectedCount
			actionButtonTitle = dataSource?.getActionButtonText(for: selectionMode, count: count)
		}

		applySelectionStyles()
	}

	func isDayLeftEdgeOfPeriod(_ day: VDDay) -> Bool {
		guard day.type.isPeriod else {
			return false
		}

		let weekday = calendar.component(.weekday, from: day.date)
		let first = calendar.firstWeekday

		if weekday == first {
			return true
		}
		return false
	}

	func isDayStartPeriod(_ day: VDDay) -> Bool {
		if day.type.isPeriod, let startDate,
			let prevDate = calendar.date(byAdding: .day, value: -1, to: day.date),
		   calendar.isDate(prevDate, inSameDayAs: startDate) {
			return true
		}
		return false
	}

	func isDayRightEdgeOfPeriod(_ day: VDDay) -> Bool {
		guard day.type.isPeriod else {
			return false
		}
		let weekday = calendar.component(.weekday, from: day.date)
		let first = calendar.firstWeekday

		let last = ((first + 5) % 7) + 1

		if weekday == last {
			return true
		}
		return false
	}

	func isDayEndPertiod(_ day: VDDay) -> Bool {
		if day.type.isPeriod, let endDate,
		   let nextDate = calendar.date(byAdding: .day, value: 1, to: day.date),
		   calendar.isDate(nextDate, inSameDayAs: endDate) {
			return true
		}
		return false
	}

	func isLastMonthDay(_ day: VDDay) -> Bool {
		guard let range = calendar.range(of: .day, in: .month, for: day.date) else { return false }
		let lastDay = range.count
		let dayComponent = calendar.component(.day, from: day.date)
		return dayComponent == lastDay
	}

	func isFirstMonthDay(_ day: VDDay) -> Bool {
		let dayComponent = calendar.component(.day, from: day.date)
		return dayComponent == 1
	}

	func isLastSelectedDay(_ day: VDDay) -> Bool {
		day.date == endDate
	}

	func isWeekend(_ day: VDDay) -> Bool {
		let weekday = calendar.component(.weekday, from: day.date)
		return weekday == 1 || weekday == 7 // Sunday = 1, Saturday = 7
	}

	func isToday(_ day: VDDay) -> Bool {
		calendar.isDateInToday(day.date)
	}

	func isDateAllowed(_ date: Date) -> Bool {
		let checkDate = calendar.startOfDay(for: date)

		if let availableDates = availableDates {
			return availableDates.contains(checkDate)
		}

		let today = calendar.startOfDay(for: Date())

		switch dateRestriction {
		case .pastOnly:
			return checkDate <= today
		case .futureOnly:
			return checkDate >= today
		case .allAvailable:
			return true
		}
	}

	func performActionButtonTap() {
		switch selectionMode {
		case .range:
			dataSource?.onActionButtonTap(startDate: startDate, endDate: endDate)
		case .single:
			dataSource?.onActionButtonTap(selectedDate: startDate)
		}
	}

	func loadAsyncActionButtonTitle() async {
		guard selectionMode == .single else {
			actionButtonTitle = nil
			return
		}

		let count = totalSelectedCount
		let title = await dataSource?.loadActionButtonText(for: selectionMode, and: startDate, count: count)
		actionButtonTitle = title
	}

	func applySelectionStyles() {
		paint(&previousMonthes)
		paint(&monthes)
	}

	// MARK: - Private methods
	private func setupVertical() {
		if monthes.isEmpty && previousMonthes.isEmpty {
			Task { @MainActor [weak self] in
				await self?.setupNextMonthes()
				await self?.setupPreviousMonthes()
			}
		}
	}

	private func setupHorizontal() {
		if monthes.isEmpty {
			Task {
				await setupNextMonthes()
				currentMonthIndex = 1
			}
		}
	}

	private func setupNextMonthes() async {
		var monthes = builder.monthsAround()
		self.monthes = monthes
	}

	private func setupPreviousMonthes() async {
		guard let first = monthes.first, dateRestriction.isPastAvailable else { return }

		var previousMonthes: [VDMonthBundle] = builder.prependPrevious(before: first, with: 2).reversed()
		self.previousMonthes = previousMonthes
	}

	private func handleRangeSelection(with date: Date) {
		if startDate != nil && endDate != nil {
			return
		}
		if startDate == nil || endDate != nil {
			startDate = date
			endDate = nil
		} else if let startDate {
			if calendar.isDate(date, inSameDayAs: startDate) {
				endDate = nil
			} else if calendar.compare(date, to: startDate, toGranularity: .day) == .orderedAscending {
				self.startDate = date
				endDate = nil
			} else {
				endDate = date
			}
		}
	}

	private func hasAvailableDatesInMonth(_ monthStart: Date) -> Bool {
		guard let availableDates = availableDates else { return true }

		let monthRange = calendar.range(of: .day, in: .month, for: monthStart)
		guard let daysInMonth = monthRange?.count else { return false }

		for day in 1...daysInMonth {
			if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart),
			   availableDates.contains(calendar.startOfDay(for: date)) {
				return true
			}
		}
		return false
	}

	private func styled(_ date: Date, original: VDDayStyle) -> VDDayStyle {
		guard original != .hidden else {
			return original
		}

		if !isDateAllowed(date) {
			return .disabled
		}

		if let startDate, let endDate {
			if calendar.isDate(date, inSameDayAs: startDate) || calendar.isDate(date, inSameDayAs: endDate) {
				return .selected
			}
			if calendar.isBetweenExclusive(date, startDate, endDate) {
				return .period
			}

			return .unselected
		} else if let startDate {
			return calendar.isDate(date, inSameDayAs: startDate) ? .selected : .unselected
		} else {
			return .unselected
		}
	}

	private func paint(_ bundles: inout [VDMonthBundle]) {
		for bundleIndex in bundles.indices {
			for weekIndex in bundles[bundleIndex].month.weeks.indices {
				for dayIndex in bundles[bundleIndex].month.weeks[weekIndex].days.indices {
					let date = bundles[bundleIndex].month.weeks[weekIndex].days[dayIndex].date
					let current = bundles[bundleIndex].month.weeks[weekIndex].days[dayIndex].type

					bundles[bundleIndex].month.weeks[weekIndex].days[dayIndex]
						.type = styled(date, original: current)
				}
			}
		}
	}
}
