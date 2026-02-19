//
//  SwiftDataPreview.swift
//  CodeBreaker
//
//  Created by CS193p Instructor on 5/14/25.
//

import SwiftUI
import SwiftData

/// The preview modifier creates `ModelContainer` for SwiftData.
struct SwiftDataPreview: PreviewModifier {
    static func makeSharedContext() async throws -> ModelContainer {
        let container = try ModelContainer(
            for: WordGuesser.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

extension PreviewTrait<Preview.ViewTraits> {
    /// The preview trait for `SwiftDataPreview`.
    @MainActor static var swiftData: Self = .modifier(SwiftDataPreview())
}
