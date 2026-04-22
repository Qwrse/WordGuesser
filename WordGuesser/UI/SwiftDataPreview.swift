//
//  SwiftDataPreview.swift
//  CodeBreaker
//
//  Created by CS193p Instructor on 5/14/25.
//

import SwiftUI
import SwiftData

/// A preview modifier that injects an in-memory SwiftData container.
struct SwiftDataPreview: PreviewModifier {
    /// Creates the shared in-memory preview container.
    static func makeSharedContext() async throws -> ModelContainer {
        let container = try ModelContainer(
            for: WordGuesser.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return container
    }
    
    /// Wraps `content` in the preview model container.
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

extension PreviewTrait<Preview.ViewTraits> {
    /// A preview trait that installs `SwiftDataPreview`.
    @MainActor static var swiftData: Self = .modifier(SwiftDataPreview())
}
