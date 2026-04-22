//
//  ElapsedTime.swift
//  WordGuesser
//
//  Created by dimss on 30/01/2026.
//

import SwiftUI

/// A view that formats the elapsed play time.
struct ElapsedTime: View {
    // MARK: Data In
    /// The start date of the active session.
    let startTime: Date?
    /// The end date of the last session.
    let endTime: Date?
    /// The accumulated play time before the current session.
    let elapsedTime: TimeInterval
    
    // MARK: - Body
    var body: some View {
        if let startTime {
            let correctedStart = startTime.addingTimeInterval(-elapsedTime)
            if let endTime {
                Text(endTime, format: .offset(to: correctedStart, allowedFields: [.minute, .second]))
            } else {
                let now = TimeDataSource<Date>.currentDate
                Text(now, format: .offset(to: correctedStart, allowedFields: [.minute, .second]))
            }
        } else {
            Text(Duration.seconds(elapsedTime), format: .time(pattern: .minuteSecond))
        }
    }
}

#Preview {
    ElapsedTime(startTime: Date.now, endTime: nil, elapsedTime: 0)
    ElapsedTime(startTime: nil, endTime: nil, elapsedTime: 100)
}
