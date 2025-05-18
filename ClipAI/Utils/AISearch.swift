import Foundation
import NaturalLanguage

struct AISearch {
    static func search(query: String, items: [ClipboardItem]) -> [ClipboardItem] {
        guard !query.isEmpty else { return items }
        
        let embedding = NLEmbedding.wordEmbedding(for: .english)
        guard let queryVector = embedding?.vector(for: query.lowercased()) else { return [] }

        // Step 1: Compute similarity scores for each item
        typealias ItemScore = (item: ClipboardItem, score: Double)
        let itemScores: [ItemScore] = items.compactMap { item in
            guard !item.content.isEmpty,
                  let itemVector = embedding?.vector(for: item.content.lowercased()) else {
                return nil
            }
            let similarity = cosineSimilarity(queryVector, itemVector)
            return (item, similarity)
        }

        // Step 2: Filter items with sufficient relevance
        let filteredScores = itemScores.filter { $0.score > 0.2 }

        // Step 3: Sort by score and extract items
        let sortedItems = filteredScores
            .sorted { $0.score > $1.score }
            .map { $0.item }

        return sortedItems
    }

    private static func cosineSimilarity(_ vectorA: [Double], _ vectorB: [Double]) -> Double {
        guard vectorA.count == vectorB.count else { return 0.0 }
        let dotProduct = zip(vectorA, vectorB).map(*).reduce(0, +)
        let magnitudeA = sqrt(vectorA.map { $0 * $0 }.reduce(0, +))
        let magnitudeB = sqrt(vectorB.map { $0 * $0 }.reduce(0, +))
        guard magnitudeA > 0, magnitudeB > 0 else { return 0.0 }
        return dotProduct / (magnitudeA * magnitudeB)
    }
}
