//
//  VDCalendarProtocol.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 15.09.2025.
//

import Foundation
import SwiftUI

// MARK: - VDCalendarCountsProvider
public protocol VDCalendarCountsDataSource: AnyObject {
	func fetchCounts(for monthes: [VDMonthBundle]) async -> [Date: Int]
	func getActionButtonText(for selectionMode: VDSelectionMode, count: Int) -> String?
	func loadActionButtonText(
		for selectionMode: VDSelectionMode, and selectedDate: Date?, count: Int) async -> String?
	func onActionButtonTap(startDate: Date?, endDate: Date?)
	func onActionButtonTap(selectedDate: Date?)
}

public extension VDCalendarCountsDataSource {
	func fetchCounts(for monthes: [VDMonthBundle]) async -> [Date: Int] { [:] }
	func getActionButtonText(for selectionMode: VDSelectionMode, count: Int) -> String? { nil }
	func loadActionButtonText(
		for selectionMode: VDSelectionMode, and selectedDate: Date?, count: Int) async -> String? { nil }
	func onActionButtonTap(startDate: Date?, endDate: Date?) { }
	func onActionButtonTap(selectedDate: Date?) {  }
}

// MARK: - Gradient Protocol
public protocol GradientProtocol {
	func linearGradient() -> LinearGradient
}

// MARK: - TestCountsProvider
final class TestCountsProvider: VDCalendarCountsDataSource {
	func getActionButtonText(for selectionMode: VDSelectionMode, count: Int) -> String? {
		if selectionMode == .range {
			return "Test Range \(count)"
		}
		return nil
	}

	func loadActionButtonText(
		for selectionMode: VDSelectionMode, and selectedDate: Date?, count: Int
	) async -> String? {
		if selectionMode == .single {
			try? await Task.sleep(nanoseconds: 100_000_000)
			return "Test Single \(count)"
		}

		return nil
	}

	func onActionButtonTap(startDate: Date?, endDate: Date?) {
		print("Range tap:", startDate, endDate)
	}

	func onActionButtonTap(selectedDate: Date?) {
		print("Single tap:", selectedDate)
	}

	func fetchCounts(for monthes: [VDMonthBundle]) async -> [Date: Int] {
		[
			Date(): 10,
			Calendar.current.date(byAdding: .day, value: 1, to: Date())!: 1,
			Calendar.current.date(byAdding: .day, value: 2, to: Date())!: 2,
			Calendar.current.date(byAdding: .day, value: 3, to: Date())!: 3
		]
	}
}


