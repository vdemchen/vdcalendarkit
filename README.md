# VDCalendarKit

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)](https://www.apple.com/ios/)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**VDCalendarKit** is a powerful and flexible SwiftUI calendar component library designed for iOS 16+ applications. It provides both horizontal and vertical calendar layouts with extensive customization options, multiple selection modes, date restrictions, and action button support.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
  - [Basic Setup](#basic-setup)
  - [Selection Modes](#selection-modes)
  - [Scroll Directions](#scroll-directions)
  - [Date Restrictions](#date-restrictions)
  - [Data Source Integration](#data-source-integration)
  - [Custom Styling](#custom-styling)
- [API Documentation](#api-documentation)
  - [VDCalendarManager](#vdcalendar-manager)
  - [VDCalendarView](#vdcalendar-view)
  - [VDCalendarCountsDataSource](#vdcalendar-counts-data-source)
  - [VDCalendarStyle](#vdcalendar-style)
- [Architecture](#architecture)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)
- [Author](#author)

## Features

- **Multiple Layout Modes**: Horizontal and vertical calendar layouts with smooth scrolling
- **Selection Modes**: Single date or date range selection with visual feedback
- **Date Restrictions**: Support for past-only, future-only, or all available dates
- **Custom Available Dates**: Specify exactly which dates are selectable using a Set
- **Action Button**: Customizable action button with automatic count calculation and async loading
- **Count Display**: Show custom counts for specific dates with dot indicators
- **Infinite Scrolling**: Seamless navigation through months with dynamic loading
- **Styling System**: Comprehensive styling with colors, fonts, and gradients
- **Period Visualization**: Beautiful period selection with gradient edges
- **Weekend Highlighting**: Automatic weekend detection and custom styling
- **Today Indicator**: Visual highlight for the current date
- **Calendar Localization**: Full support for different locales and calendar systems
- **SwiftUI Native**: Built entirely with SwiftUI for modern iOS development
- **Accessibility**: Proper accessibility support built-in
- **Performance Optimized**: Efficient rendering and memory management

## Requirements

- iOS 16.0+
- Swift 5.0+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add VDCalendarKit to your project via Swift Package Manager. In Xcode, go to **File → Add Package Dependencies** and enter:

```
https://github.com/vdemchen/VDCalendarKit.git
```

Or add it to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/vdemchen/VDCalendarKit.git", from: "1.0.0")
]
```

## Quick Start

```swift
import SwiftUI
import VDCalendarKit

struct ContentView: View {
    var body: some View {
        let manager = VDCalendarManager(
            selectionMode: .range,
            scrollDirection: .vertical
        )

        VDCalendarView(manager: manager)
    }
}
```

## Usage

### Basic Setup

Create a calendar with default settings:

```swift
import VDCalendarKit

// Vertical calendar with range selection
let manager = VDCalendarManager(
    selectionMode: .range,
    scrollDirection: .vertical
)

VDCalendarView(manager: manager)
```

### Selection Modes

VDCalendarKit supports two selection modes:

#### Single Date Selection

```swift
let manager = VDCalendarManager(
    selectionMode: .single,
    scrollDirection: .vertical
)

// Access selected date
if let selectedDate = manager.startDate {
    print("Selected: \(selectedDate)")
}
```

#### Date Range Selection

```swift
let manager = VDCalendarManager(
    selectionMode: .range,
    scrollDirection: .vertical
)

// Access selected range
if let start = manager.startDate, let end = manager.endDate {
    print("Range: \(start) to \(end)")
}
```

### Scroll Directions

#### Vertical Layout

Best for date range selection with action buttons:

```swift
let manager = VDCalendarManager(
    selectionMode: .range,
    scrollDirection: .vertical
)
```

#### Horizontal Layout

Best for single date selection with month-by-month navigation:

```swift
let manager = VDCalendarManager(
    selectionMode: .single,
    scrollDirection: .horizontal
)
```

### Date Restrictions

Control which dates are selectable:

#### Past Only

Only allow selection of dates up to today:

```swift
let manager = VDCalendarManager(
    dateRestriction: .pastOnly
)
```

#### Future Only

Only allow selection of dates from today onwards:

```swift
let manager = VDCalendarManager(
    dateRestriction: .futureOnly
)
```

#### All Dates Available

No restrictions (default):

```swift
let manager = VDCalendarManager(
    dateRestriction: .allAvailable
)
```

#### Custom Available Dates

Specify exact dates that should be selectable:

```swift
let calendar = Calendar.current
let availableDates: Set<Date> = [
    Date(),
    calendar.date(byAdding: .day, value: 1, to: Date())!,
    calendar.date(byAdding: .day, value: 3, to: Date())!,
    calendar.date(byAdding: .day, value: 5, to: Date())!
]

let manager = VDCalendarManager(
    availableDates: availableDates
)
```

### Data Source Integration

Implement the `VDCalendarCountsDataSource` protocol to provide count data and handle actions:

```swift
class CalendarDataSource: VDCalendarCountsDataSource {
    // Provide count data for calendar days
    func fetchCounts(for monthes: [VDMonthBundle]) async -> [Date: Int] {
        // Fetch from API or local database
        return [
            Date(): 10,
            Calendar.current.date(byAdding: .day, value: 1, to: Date())!: 5,
            Calendar.current.date(byAdding: .day, value: 2, to: Date())!: 3
        ]
    }

    // Provide action button text for range selection
    func getActionButtonText(for selectionMode: VDSelectionMode, count: Int) -> String? {
        switch selectionMode {
        case .range:
            return "Select Period (\(count) items)"
        case .single:
            return nil
        }
    }

    // Load action button text asynchronously for single selection
    func loadActionButtonText(
        for selectionMode: VDSelectionMode,
        and selectedDate: Date?,
        count: Int
    ) async -> String? {
        guard selectionMode == .single else { return nil }

        // Perform async operation (e.g., API call)
        try? await Task.sleep(nanoseconds: 100_000_000)
        return "Confirm (\(count) items)"
    }

    // Handle action button tap for range selection
    func onActionButtonTap(startDate: Date?, endDate: Date?) {
        print("Range selected: \(startDate) to \(endDate)")
        // Handle the selection
    }

    // Handle action button tap for single selection
    func onActionButtonTap(selectedDate: Date?) {
        print("Date selected: \(selectedDate)")
        // Handle the selection
    }
}

// Usage
let manager = VDCalendarManager()
manager.dataSource = CalendarDataSource()
```

### Custom Styling

Customize the calendar appearance using `VDCalendarStyle`:

```swift
let customStyle = VDCalendarStyle(
    selectionGradient: CalendarGradient(start: .blue, end: .purple),
    periodColor: .blue.opacity(0.2),
    accentColor: .blue,
    controlButtonsColor: .gray,
    descriptionFont: .system(size: 16, weight: .medium),
    descriptionColor: .gray,
    dayFont: .system(size: 18, weight: .medium),
    dayUnavailableColor: .gray.opacity(0.3),
    dotFont: .system(size: 11, weight: .semibold),
    monthHeaderFont: .system(size: 18, weight: .bold),
    dividerColor: .gray,
    weekDayColor: .gray,
    weekDayFont: .system(size: 16, weight: .semibold),
    actionButtonFont: .system(size: 18, weight: .medium),
    weekendColor: .red,
    weekendUnavailableColor: .red.opacity(0.5),
    todayFont: .body.bold()
)

VDCalendarView(manager: manager)
    .environment(\.calendarStyle, customStyle)
```

Or use the default style:

```swift
VDCalendarView(manager: manager)
    .environment(\.calendarStyle, .default)
```

## API Documentation

### VDCalendarManager

The main controller managing calendar state and logic.

#### Initialization

```swift
public init(
    selectionMode: VDSelectionMode = .range,
    calendar: Calendar = .current,
    scrollDirection: VDScrollDirection = .vertical,
    availableDates: Set<Date>? = nil,
    dateRestriction: VDDateRestriction = .allAvailable
)
```

#### Properties

- `selectionMode: VDSelectionMode` - Single or range selection mode
- `startDate: Date?` - The selected start date (or single selected date)
- `endDate: Date?` - The selected end date (only for range mode)
- `scrollDirection: VDScrollDirection` - Vertical or horizontal layout
- `dateRestriction: VDDateRestriction` - Date restriction rules
- `availableDates: Set<Date>?` - Set of explicitly available dates
- `dataSource: VDCalendarCountsDataSource?` - Data source for counts and actions
- `isResetEnabled: Bool` - Whether the reset button should be enabled
- `totalSelectedCount: Int` - Total count of items in selected date range

#### Methods

- `setup()` - Initialize the calendar with months
- `reset()` - Reset selection and clear dates
- `select(day: VDDay)` - Handle day selection
- `navigateToPreviousMonth()` - Navigate to previous month (horizontal mode)
- `navigateToNextMonth()` - Navigate to next month (horizontal mode)
- `navigateToDate(_ targetDate: Date)` - Jump to a specific date

### VDCalendarView

The main SwiftUI view component.

```swift
public struct VDCalendarView: View {
    public init(manager: VDCalendarManager)
}
```

Usage:

```swift
let manager = VDCalendarManager()
VDCalendarView(manager: manager)
    .environment(\.calendarStyle, .default)
```

### VDCalendarCountsDataSource

Protocol for providing count data and handling actions.

```swift
public protocol VDCalendarCountsDataSource: AnyObject {
    // Fetch count data for displayed months
    func fetchCounts(for monthes: [VDMonthBundle]) async -> [Date: Int]

    // Get action button text for range mode (synchronous)
    func getActionButtonText(for selectionMode: VDSelectionMode, count: Int) -> String?

    // Load action button text for single mode (asynchronous)
    func loadActionButtonText(
        for selectionMode: VDSelectionMode,
        and selectedDate: Date?,
        count: Int
    ) async -> String?

    // Handle action button tap for range mode
    func onActionButtonTap(startDate: Date?, endDate: Date?)

    // Handle action button tap for single mode
    func onActionButtonTap(selectedDate: Date?)
}
```

All methods have default implementations and are optional to implement.

### VDCalendarStyle

Comprehensive styling configuration.

```swift
public struct VDCalendarStyle {
    let selectionGradient: GradientProtocol    // Gradient for selected dates
    let periodColor: Color                      // Background color for period range
    let accentColor: Color                      // Accent color for highlights
    let controlButtonsColor: Color              // Color for navigation buttons
    let descriptionFont: Font                   // Font for descriptions
    let descriptionColor: Color                 // Color for descriptions
    let dayFont: Font                           // Font for day numbers
    let dayUnavailableColor: Color             // Color for unavailable days
    let dotFont: Font                           // Font for count dots
    let monthHeaderFont: Font                   // Font for month headers
    let dividerColor: Color                     // Color for dividers
    let weekDayColor: Color                     // Color for weekday labels
    let weekDayFont: Font                       // Font for weekday labels
    let actionButtonFont: Font                  // Font for action button
    let weekendColor: Color                     // Color for weekend days
    let weekendUnavailableColor: Color         // Color for unavailable weekends
    let todayFont: Font                         // Font for today's date

    public static var `default`: VDCalendarStyle
}
```

### Enums

#### VDSelectionMode

```swift
public enum VDSelectionMode {
    case single   // Single date selection
    case range    // Date range selection
}
```

#### VDScrollDirection

```swift
public enum VDScrollDirection {
    case vertical    // Vertical scrolling layout
    case horizontal  // Horizontal month-by-month layout
}
```

#### VDDateRestriction

```swift
public enum VDDateRestriction {
    case pastOnly      // Only past and today
    case futureOnly    // Only today and future
    case allAvailable  // All dates available
}
```

## Architecture

VDCalendarKit follows a clean, modular architecture:

### Core Components

```
VDCalendarView (SwiftUI Entry Point)
    ├── VDVerticalCalendarView (Vertical Layout)
    │   ├── VDCalendarSelectedDateView (Selection Display)
    │   ├── VDWeekHeaderView (Weekday Labels)
    │   ├── VDCalendarScrollView (Scrollable Content)
    │   │   └── VDMonthBundleView (Month Container)
    │   │       └── VDMonthView (Month Grid)
    │   │           └── VDWeekView (Week Row)
    │   │               └── VDDayView (Day Cell)
    │   └── VDActionButtonView (Action Button)
    │
    └── VDHorizontalCalendarView (Horizontal Layout)
        └── VDHorizontalMonthCardView (Month Card)
            ├── VDMonthHeaderView (Navigation Controls)
            └── VDMonthView (Month Grid)
```

### State Management

- **VDCalendarManager**: Central state management using `@ObservableObject`
- **Published Properties**: Drive UI updates reactively
- **Environment Injection**: Manager and style injected via SwiftUI environment

### Data Flow

1. **Initialization**: Manager creates initial month bundles using `VDCalendarBuilder`
2. **Selection**: User taps day → Manager updates `startDate`/`endDate` → UI updates
3. **Data Loading**: Manager requests counts from `dataSource` → Updates models
4. **Styling**: Manager applies selection styles → Views reflect changes
5. **Infinite Scrolling**: Scroll detection → Load more months → Update display

### Key Patterns

- **Builder Pattern**: `VDCalendarBuilder` constructs month structures
- **Protocol-based Design**: Flexible data provider through `VDCalendarCountsDataSource`
- **Environment-based Configuration**: Styling via SwiftUI environment
- **Declarative UI**: SwiftUI views respond to published state changes
- **Async/Await**: Modern concurrency for data fetching

### File Organization

```
Sources/VDCalendarKit/
├── Views/                      # SwiftUI view components
│   ├── VDCalendarView.swift    # Main entry point
│   ├── VDVerticalCalendarView.swift
│   ├── VDHorizontalCalendarView.swift
│   ├── VDDayView.swift         # Day cell with selection UI
│   ├── VDWeekView.swift        # Week row
│   ├── VDMonthView.swift       # Month grid
│   └── ...
├── Helpers/                    # Core logic
│   ├── VDCalendarManager.swift # State management
│   ├── VDCalendarModels.swift  # Data models
│   ├── VDCalendarProtocol.swift # Data source protocol
│   └── VDCalendarEnvironmentKeys.swift
└── Extensions/                 # Utility extensions
    ├── Calendar+Extensions.swift
    ├── DateFormatter+Extensions.swift
    └── View+Extensions.swift
```

## Examples

### Healthcare Appointment Calendar

Single date selection for booking appointments, only future dates:

```swift
class AppointmentDataSource: VDCalendarCountsDataSource {
    func fetchCounts(for monthes: [VDMonthBundle]) async -> [Date: Int] {
        // Fetch available slots from API
        return await fetchAvailableSlots(for: monthes)
    }

    func loadActionButtonText(
        for selectionMode: VDSelectionMode,
        and selectedDate: Date?,
        count: Int
    ) async -> String? {
        guard let date = selectedDate else { return nil }
        return "Book Appointment (\(count) slots available)"
    }

    func onActionButtonTap(selectedDate: Date?) {
        guard let date = selectedDate else { return }
        bookAppointment(for: date)
    }
}

let manager = VDCalendarManager(
    selectionMode: .single,
    scrollDirection: .horizontal,
    dateRestriction: .futureOnly
)
manager.dataSource = AppointmentDataSource()

VDCalendarView(manager: manager)
```

### Event Range Selector

Select a date range for creating events:

```swift
class EventDataSource: VDCalendarCountsDataSource {
    func getActionButtonText(for selectionMode: VDSelectionMode, count: Int) -> String? {
        return "Create Event"
    }

    func onActionButtonTap(startDate: Date?, endDate: Date?) {
        guard let start = startDate, let end = endDate else { return }
        createEvent(from: start, to: end)
    }
}

let manager = VDCalendarManager(
    selectionMode: .range,
    scrollDirection: .vertical
)
manager.dataSource = EventDataSource()

VDCalendarView(manager: manager)
```

### Availability Calendar

Show specific available dates only:

```swift
let calendar = Calendar.current
let availableDates: Set<Date> = [
    calendar.date(byAdding: .day, value: 1, to: Date())!,
    calendar.date(byAdding: .day, value: 3, to: Date())!,
    calendar.date(byAdding: .day, value: 7, to: Date())!,
    calendar.date(byAdding: .day, value: 10, to: Date())!
]

let manager = VDCalendarManager(
    selectionMode: .single,
    availableDates: availableDates
)

VDCalendarView(manager: manager)
```

### Localized Calendar

Support different locales and calendar systems:

```swift
var calendar = Calendar.current
calendar.locale = Locale(identifier: "uk_UA") // Ukrainian

let manager = VDCalendarManager(
    calendar: calendar,
    scrollDirection: .vertical
)

VDCalendarView(manager: manager)
```

### Custom Branded Calendar

Apply custom brand colors and styling:

```swift
let brandStyle = VDCalendarStyle(
    selectionGradient: CalendarGradient(
        start: Color(hex: "FF6B6B"),
        end: Color(hex: "FF8787")
    ),
    periodColor: Color(hex: "FFE5E5"),
    accentColor: Color(hex: "FF6B6B"),
    controlButtonsColor: Color(hex: "4ECDC4"),
    descriptionFont: .system(size: 14),
    descriptionColor: .secondary,
    dayFont: .system(size: 16, weight: .medium),
    dayUnavailableColor: .gray.opacity(0.3),
    dotFont: .system(size: 10, weight: .bold),
    monthHeaderFont: .system(size: 20, weight: .bold),
    dividerColor: .gray.opacity(0.2),
    weekDayColor: .secondary,
    weekDayFont: .system(size: 14, weight: .semibold),
    actionButtonFont: .system(size: 16, weight: .semibold),
    weekendColor: Color(hex: "FF6B6B"),
    weekendUnavailableColor: Color(hex: "FF6B6B").opacity(0.4),
    todayFont: .system(size: 16, weight: .bold)
)

let manager = VDCalendarManager()

VDCalendarView(manager: manager)
    .environment(\.calendarStyle, brandStyle)
```

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Development Setup

```bash
# Clone the repository
git clone https://github.com/vdemchen/VDCalendarKit.git
cd VDCalendarKit

# Build the package
swift build

# Run tests
swift test
```

### Coding Standards

- Follow Swift API Design Guidelines
- Write clear, self-documenting code
- Add inline comments for complex logic
- Update documentation for public APIs
- Include unit tests for new features

## License

VDCalendarKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

```
MIT License

Copyright (c) 2025 Vladyslav Demchenko

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Author

**Vladyslav Demchenko**

- GitHub: [@vdemchen](https://github.com/vdemchen)
- Email: vdemchen@gmail.com

## Support

If you find VDCalendarKit useful, please consider:

- Starring the repository on GitHub
- Reporting issues and feature requests
- Contributing improvements
- Sharing with other developers

## Acknowledgments

Special thanks to all contributors and the Swift community for their support and feedback.

---

Made with ❤️ using SwiftUI
