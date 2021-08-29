//
//  Extensions.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/23/21.
//

import Foundation

// MARK: - Date
extension Date {
    var startOfWeek: Date {
        let gregorian = Calendar(identifier: .gregorian)
        let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
        return gregorian.date(byAdding: .day, value: 0, to: sunday!)!
    }
    
    var endOfWeek: Date {
        let gregorian = Calendar(identifier: .gregorian)
        let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
        return gregorian.date(byAdding: .day, value: 7, to: sunday!)!
    }
    
    var startDateOfMonth: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    var endDateOfMonth: Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startDateOfMonth)!
    }
    
    var endInSixMonths: Date {
        return Calendar.current.date(byAdding: DateComponents(month: 6), to: Date().endDateOfMonth)!
    }
    
    var threeYearsLater: Date {
        return Calendar.current.date(byAdding: DateComponents(year: 3), to: Date().endDateOfMonth)!
    }
    
    enum DateFormatType: String {
        case full = "EEEE, MMM d, yyyy"
        case fullNumeric = "MM/dd/yyyy"
        case fullNumericTimestamp = "yyyy-MM-dd HH:mm"
        case monthDayTimestamp = "MMM d, h:mm a"
        case monthYear = "MMMM yyyy"
        case monthDayYear = "MMMM dd, yyyy"
        case monthDayYearShort = "MMM dd, yyyy"
        case fullWithTimezone = "E, d MMM yyyy HH:mm:ss Z"
        case fullNumericWithTimezone = "yyyy-MM-dd'T'HH:mm:ssZ"
        case short = "dd.MM.yy"
        case timestamp = "HH:mm:ss.SSS"
        case onlyDate = "dd"
    }
    
    func dateToString(format: DateFormatType) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }
    
    func getRepeatedDatesForSixMonths() -> [Date] {
        var nReturnDates: [Date] = []
        for index in 0...5 {
            if let nextMonth = Calendar.current.date(byAdding: .month, value: index, to: self) {
            nReturnDates.append(nextMonth)
            }
        }
        print("=================== getRepeatedDatesForSixMonths\(nReturnDates) ==> count : \(nReturnDates.count) ======================")
        return nReturnDates
    }
    
    func getRepeatedDatesForAYear() -> [Date] {
        var nReturnDates: [Date] = []
        for index in 0...11 {
            if let nextMonth = Calendar.current.date(byAdding: .month, value: index, to: self) {
            nReturnDates.append(nextMonth)
            }
        }
        print("=================== getRepeatedDatesForAYear\(nReturnDates) ==> count : \(nReturnDates.count) ======================")
        return nReturnDates
    }
    
    func getRepeatedDatesForTwoYears() -> [Date] {
        var nReturnDates: [Date] = []
        for index in 0...23 {
            if let nextMonth = Calendar.current.date(byAdding: .month, value: index, to: self) {
            nReturnDates.append(nextMonth)
            }
        }
        print("=================== getRepeatedDatesForTwoYears\(nReturnDates) ==> count : \(nReturnDates.count)======================")
        return nReturnDates
    }
    
    func getUpdateRepeatedDatesForSixMonths() -> [Date] {
        var nReturnDates: [Date] = []
        for index in 1...5 {
            if let nextMonth = Calendar.current.date(byAdding: .month, value: index, to: self) {
            nReturnDates.append(nextMonth)
            }
        }
        print("=================== getUpdateRepeatedDatesForSixMonths\(nReturnDates) ==> count : \(nReturnDates.count)======================")
        return nReturnDates
    }
    
    func getUpdateRepeatedDatesForAYear() -> [Date] {
        var nReturnDates: [Date] = []
        for index in 1...11 {
            if let nextMonth = Calendar.current.date(byAdding: .month, value: index, to: self) {
            nReturnDates.append(nextMonth)
            }
        }
        print("=================== getUpdateRepeatedDatesForAYear\(nReturnDates) ==> count : \(nReturnDates.count)======================")

        return nReturnDates
    }
    
    func getUpdateRepeatedDatesForTwoYears() -> [Date] {
        var nReturnDates: [Date] = []
        for index in 1...23 {
            if let nextMonth = Calendar.current.date(byAdding: .month, value: index, to: self) {
            nReturnDates.append(nextMonth)
            }
        }
        print("=================== getUpdateRepeatedDatesForTwoYears\(nReturnDates) ==> count : \(nReturnDates.count)======================")
        return nReturnDates
    }
}

// MARK: - Array
extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        return result
    }
}

extension BidirectionalCollection where Iterator.Element: Equatable {
    typealias Element = Self.Iterator.Element
    func after(_ item: Element, loop: Bool = false) -> Element? {
        if let itemIndex = self.firstIndex(of: item) {
            let lastItem: Bool = (index(after:itemIndex) == endIndex)
            if loop && lastItem {
                return self.first
            } else if lastItem {
                return nil
            } else {
                return self[index(after:itemIndex)]
            }
        }
        return nil
    }
    
    func before(_ item: Element, loop: Bool = false) -> Element? {
        if let itemIndex = self.firstIndex(of: item) {
            let firstItem: Bool = (itemIndex == startIndex)
            if loop && firstItem {
                return self.last
            } else if firstItem {
                return nil
            } else {
                return self[index(before:itemIndex)]
            }
        }
        return nil
    }
}

extension Array {
    public func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key:Element] {
        var dict = [Key:Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}

// MARK: - Double
extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

// MARK: - Character
extension Character {
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }
    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }
    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}

// MARK: - String
extension String {
    var isSingleEmoji: Bool { count == 1 && containsEmoji }
    var containsEmoji: Bool { contains { $0.isEmoji } }
    var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }
    var emojiString: String { emojis.map { String($0) }.reduce("", +) }
    var emojis: [Character] { filter { $0.isEmoji } }
    var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
    var firstCharacterAsString : String {
        return self.startIndex == self.endIndex
            ? ""
            : String(self[self.startIndex])
    }
    
    func lastCharacterAsString() -> String {
        guard let lastChar = self.last else {
            return ""
        }
        return String(lastChar)
    }
    
    var isnumberordouble: Bool { return Double(self.trimmingCharacters(in: .whitespaces)) != nil }
    
    func toDate(withFormat format: String = "yyyy-MM-dd HH:mm:ss")-> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tehran")
        dateFormatter.locale = Locale(identifier: "fa-IR")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        return date
    }
    
    var stringByRemovingWhitespaces: String {
            return components(separatedBy: .whitespaces).joined()
    }
}

// MARK: - UserDefaults
extension UserDefaults {
    static func isFirstLaunch() -> Bool {
        let hasBeenLaunchedBeforeFlag = "hasBeenLaunchedBeforeFlag"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunchedBeforeFlag)
        if (isFirstLaunch) {
            UserDefaults.standard.set(true, forKey: hasBeenLaunchedBeforeFlag)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
}
