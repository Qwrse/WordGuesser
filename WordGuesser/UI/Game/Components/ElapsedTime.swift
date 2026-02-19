//
//  ElapsedTime.swift
//  WordGuesser
//
//  Created by dimss on 30/01/2026.
//

import SwiftUI

/// The `View` draws total time user has played the game.
struct ElapsedTime: View {
    // MARK: Data In
    /// The start time of last session.
    let startTime: Date?
    /// The end time of last session.
    let endTime: Date?
    /// The summary of time user played the game excluding last session.
    let timeSpent: TimeInterval
    
    // MARK: - Body
    var body: some View {
        if let startTime {
            let correctedStart = startTime.addingTimeInterval(-timeSpent)
            if let endTime {
                Text(endTime, format: .offset(to: correctedStart, allowedFields: [.minute, .second]))
            } else {
                let now = TimeDataSource<Date>.currentDate
                Text(now, format: .offset(to: correctedStart, allowedFields: [.minute, .second]))
            }
        } else {
            Text(Duration.seconds(timeSpent), format: .time(pattern: .minuteSecond))
        }
    }
}

#Preview {
    ElapsedTime(startTime: Date.now, endTime: nil, timeSpent: 0)
    ElapsedTime(startTime: nil, endTime: nil, timeSpent: 100)
}
