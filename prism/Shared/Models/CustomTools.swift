import Foundation
import FoundationModels

// MARK: - Weather Tool

/// A tool that fetches current weather information for a specified location
struct WeatherTool: Tool, Sendable {
    var name: String { "get_weather" }
    var description: String { "Get current weather information for a specific location including temperature, conditions, and forecast" }

    /// Arguments for the weather tool
    @Generable
    struct Arguments: Sendable {
        @Guide(description: "The location to get weather for (city, state/country)")
        var location: String

        @Guide(description: "Temperature units: celsius or fahrenheit")
        var units: String?
    }

    /// Weather information response
    struct WeatherInfo: Sendable, Codable {
        let location: String
        let temperature: Double
        let condition: String
        let humidity: Int
        let windSpeed: Double
        let units: String
        let lastUpdated: Date
    }

    /// Errors that can occur during weather fetching
    enum WeatherError: Error, LocalizedError, Sendable {
        case invalidLocation
        case networkUnavailable
        case apiKeyMissing
        case invalidResponse
        case rateLimitExceeded

        var errorDescription: String? {
            switch self {
            case .invalidLocation:
                return "The specified location could not be found"
            case .networkUnavailable:
                return "Network connection is unavailable"
            case .apiKeyMissing:
                return "Weather API key is not configured"
            case .invalidResponse:
                return "Invalid response from weather service"
            case .rateLimitExceeded:
                return "Weather API rate limit exceeded"
            }
        }
    }

    func call(arguments: Arguments) async throws -> String {
        do {
            let weatherInfo = try await fetchWeatherData(
                location: arguments.location,
                units: arguments.units ?? "celsius"
            )

            let response = """
            Current weather for \(weatherInfo.location):
            Temperature: \(weatherInfo.temperature)°\(weatherInfo.units == "celsius" ? "C" : "F")
            Conditions: \(weatherInfo.condition)
            Humidity: \(weatherInfo.humidity)%
            Wind Speed: \(weatherInfo.windSpeed) \(weatherInfo.units == "celsius" ? "km/h" : "mph")
            Last Updated: \(DateFormatter.localizedString(from: weatherInfo.lastUpdated, dateStyle: .none, timeStyle: .short))
            """

            return response
        } catch {
            return "Error fetching weather data: \(error.localizedDescription)"
        }
    }

    /// Fetches weather data from a weather service
    private func fetchWeatherData(location: String, units: String) async throws -> WeatherInfo {
        // Simulate API call with realistic delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Validate location
        guard !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw WeatherError.invalidLocation
        }

        // Simulate different weather conditions based on location
        let mockWeatherData = generateMockWeatherData(for: location, units: units)
        return mockWeatherData
    }

    /// Generates mock weather data for demonstration purposes
    private func generateMockWeatherData(for location: String, units: String) -> WeatherInfo {
        let isCelsius = units.lowercased() == "celsius"

        // Generate temperature based on location hash for consistency
        let locationHash = abs(location.hashValue)
        let baseTemp = isCelsius ? (locationHash % 30) + 5 : (locationHash % 60) + 40

        let conditions = ["Sunny", "Partly Cloudy", "Cloudy", "Light Rain", "Clear"]
        let condition = conditions[locationHash % conditions.count]

        return WeatherInfo(
            location: location,
            temperature: Double(baseTemp),
            condition: condition,
            humidity: (locationHash % 40) + 30,
            windSpeed: Double((locationHash % 20) + 5),
            units: isCelsius ? "celsius" : "fahrenheit",
            lastUpdated: Date()
        )
    }
}

// MARK: - Calculator Tool

/// A tool that performs mathematical calculations and operations
struct CalculatorTool: Tool, Sendable {
    var name: String { "calculate" }
    var description: String { "Perform mathematical calculations including basic arithmetic, trigonometry, and advanced operations" }

    /// Arguments for the calculator tool
    @Generable
    struct Arguments: Sendable {
        @Guide(description: "Mathematical expression to evaluate (e.g., '2 + 3 * 4', 'sin(30)', 'sqrt(16)')")
        var expression: String

        @Guide(description: "Number of decimal places for the result (default: 2)")
        var precision: Int?
    }

    /// Calculator operation result
    struct CalculationResult: Sendable {
        let expression: String
        let result: Double
        let formattedResult: String
        let isValid: Bool
        let errorMessage: String?
    }

    /// Calculation errors
    enum CalculationError: Error, LocalizedError, Sendable {
        case invalidExpression
        case divisionByZero
        case domainError
        case overflow
        case invalidPrecision

        var errorDescription: String? {
            switch self {
            case .invalidExpression:
                return "Invalid mathematical expression"
            case .divisionByZero:
                return "Division by zero is not allowed"
            case .domainError:
                return "Mathematical domain error (e.g., sqrt of negative number)"
            case .overflow:
                return "Number too large to calculate"
            case .invalidPrecision:
                return "Invalid precision value"
            }
        }
    }

    func call(arguments: Arguments) async throws -> String {
        let precision = arguments.precision ?? 2

        guard precision >= 0 && precision <= 10 else {
            return "Error: Precision must be between 0 and 10"
        }

        do {
            let result = try await evaluateExpression(
                arguments.expression,
                precision: precision
            )

            if result.isValid {
                return "Calculation: \(result.expression) = \(result.formattedResult)"
            } else {
                return "Error: \(result.errorMessage ?? "Unknown calculation error")"
            }
        } catch {
            return "Calculation error: \(error.localizedDescription)"
        }
    }

    /// Evaluates a mathematical expression
    private func evaluateExpression(_ expression: String, precision: Int) async throws -> CalculationResult {
        let cleanExpression = expression.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            let result = try performCalculation(cleanExpression)

            guard result.isFinite else {
                throw CalculationError.overflow
            }

            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = precision
            formatter.minimumFractionDigits = 0

            let formattedResult = formatter.string(from: NSNumber(value: result)) ?? String(result)

            return CalculationResult(
                expression: cleanExpression,
                result: result,
                formattedResult: formattedResult,
                isValid: true,
                errorMessage: nil
            )
        } catch {
            return CalculationResult(
                expression: cleanExpression,
                result: 0,
                formattedResult: "0",
                isValid: false,
                errorMessage: error.localizedDescription
            )
        }
    }

    /// Performs the actual calculation using NSExpression
    private func performCalculation(_ expression: String) throws -> Double {
        // Replace common mathematical functions with NSExpression compatible syntax
        var processedExpression = expression
            .replacingOccurrences(of: "π", with: String(Double.pi))
            .replacingOccurrences(of: "pi", with: String(Double.pi))
            .replacingOccurrences(of: "e", with: String(M_E))
            .replacingOccurrences(of: "sqrt", with: "sqrt")
            .replacingOccurrences(of: "sin", with: "sin")
            .replacingOccurrences(of: "cos", with: "cos")
            .replacingOccurrences(of: "tan", with: "tan")
            .replacingOccurrences(of: "log", with: "log")
            .replacingOccurrences(of: "abs", with: "abs")

        // Handle basic arithmetic expressions
        if let result = try? evaluateBasicExpression(processedExpression) {
            return result
        }

        throw CalculationError.invalidExpression
    }

    /// Evaluates basic arithmetic expressions
    private func evaluateBasicExpression(_ expression: String) throws -> Double {
        guard let nsExpression = NSExpression(format: expression) else {
            throw CalculationError.invalidExpression
        }

        guard let result = nsExpression.expressionValue(with: nil, context: nil) as? NSNumber else {
            throw CalculationError.invalidExpression
        }

        let doubleResult = result.doubleValue

        guard doubleResult.isFinite else {
            if doubleResult.isInfinite {
                throw CalculationError.divisionByZero
            } else {
                throw CalculationError.domainError
            }
        }

        return doubleResult
    }
}

// MARK: - Web Search Tool

/// A tool that performs web searches and returns relevant results
struct WebSearchTool: Tool, Sendable {
    var name: String { "web_search" }
    var description: String { "Search the web for information on any topic and return relevant results with summaries" }

    /// Arguments for the web search tool
    @Generable
    struct Arguments: Sendable {
        @Guide(description: "Search query or keywords to find information about")
        var query: String

        @Guide(description: "Maximum number of results to return (default: 5, max: 10)")
        var maxResults: Int?

        @Guide(description: "Search category: general, news, images, videos, or academic")
        var category: String?
    }

    /// Web search result
    struct SearchResult: Sendable, Codable {
        let title: String
        let url: String
        let snippet: String
        let source: String
        let publishDate: Date?
        let relevanceScore: Double
    }

    /// Web search response
    struct SearchResponse: Sendable {
        let query: String
        let results: [SearchResult]
        let totalResults: Int
        let searchTime: TimeInterval
        let category: String
    }

    /// Search errors
    enum SearchError: Error, LocalizedError, Sendable {
        case emptyQuery
        case networkError
        case rateLimitExceeded
        case invalidCategory
        case noResults
        case serviceUnavailable

        var errorDescription: String? {
            switch self {
            case .emptyQuery:
                return "Search query cannot be empty"
            case .networkError:
                return "Network error occurred during search"
            case .rateLimitExceeded:
                return "Search rate limit exceeded"
            case .invalidCategory:
                return "Invalid search category specified"
            case .noResults:
                return "No search results found"
            case .serviceUnavailable:
                return "Search service is currently unavailable"
            }
        }
    }

    func call(arguments: Arguments) async throws -> String {
        let startTime = Date()

        do {
            let searchResponse = try await performWebSearch(
                query: arguments.query,
                maxResults: arguments.maxResults ?? 5,
                category: arguments.category ?? "general"
            )

            if searchResponse.results.isEmpty {
                return "No search results found for: \"\(searchResponse.query)\""
            }

            var output = "Search results for \"\(searchResponse.query)\" (\(searchResponse.totalResults) total results):\n\n"

            for (index, result) in searchResponse.results.enumerated() {
                output += "\(index + 1). \(result.title)\n"
                output += "   Source: \(result.source)\n"
                output += "   URL: \(result.url)\n"
                output += "   Summary: \(result.snippet)\n"
                if let publishDate = result.publishDate {
                    output += "   Published: \(DateFormatter.localizedString(from: publishDate, dateStyle: .medium, timeStyle: .none))\n"
                }
                output += "\n"
            }

            output += "Search completed in \(String(format: "%.2f", searchResponse.searchTime)) seconds"

            return output
        } catch {
            return "Search error: \(error.localizedDescription)"
        }
    }

    /// Performs the web search operation
    private func performWebSearch(query: String, maxResults: Int, category: String) async throws -> SearchResponse {
        let startTime = Date()

        // Validate inputs
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw SearchError.emptyQuery
        }

        guard maxResults > 0 && maxResults <= 10 else {
            throw SearchError.invalidCategory
        }

        let validCategories = ["general", "news", "images", "videos", "academic"]
        guard validCategories.contains(category.lowercased()) else {
            throw SearchError.invalidCategory
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Generate mock search results
        let results = generateMockSearchResults(for: query, maxResults: maxResults, category: category)
        let searchTime = Date().timeIntervalSince(startTime)

        return SearchResponse(
            query: query,
            results: results,
            totalResults: results.count * 10, // Simulate more total results
            searchTime: searchTime,
            category: category
        )
    }

    /// Generates mock search results for demonstration
    private func generateMockSearchResults(for query: String, maxResults: Int, category: String) -> [SearchResult] {
        let queryHash = abs(query.hashValue)
        var results: [SearchResult] = []

        let mockTitles = [
            "Understanding \(query): A Comprehensive Guide",
            "Latest News and Updates on \(query)",
            "Everything You Need to Know About \(query)",
            "Expert Analysis: The Impact of \(query)",
            "How \(query) is Changing the Industry",
            "Top 10 Facts About \(query)",
            "Research Findings on \(query)",
            "The Future of \(query): Trends and Predictions"
        ]

        let mockSources = ["TechCrunch", "The Guardian", "Wikipedia", "Medium", "BBC News", "Reuters", "Nature", "Scientific American"]
        let mockDomains = ["techcrunch.com", "theguardian.com", "wikipedia.org", "medium.com", "bbc.com", "reuters.com", "nature.com", "scientificamerican.com"]

        for i in 0..<min(maxResults, mockTitles.count) {
            let titleIndex = (queryHash + i) % mockTitles.count
            let sourceIndex = (queryHash + i) % mockSources.count

            let result = SearchResult(
                title: mockTitles[titleIndex],
                url: "https://\(mockDomains[sourceIndex])/article/\(query.lowercased().replacingOccurrences(of: " ", with: "-"))-\(i + 1)",
                snippet: "This article provides detailed information about \(query), covering key aspects and recent developments. Learn more about the impact and significance of \(query) in today's context.",
                source: mockSources[sourceIndex],
                publishDate: Calendar.current.date(byAdding: .day, value: -(i + 1), to: Date()),
                relevanceScore: Double(100 - i * 5) / 100.0
            )

            results.append(result)
        }

        return results
    }
}

// MARK: - Tool Collection

/// A collection of all available custom tools
struct CustomToolCollection: Sendable {
    /// All available custom tools
    static let allTools: [any Tool] = [
        WeatherTool(),
        CalculatorTool(),
        WebSearchTool()
    ]

    /// Get tools by category
    static func tools(for category: ToolCategory) -> [any Tool] {
        switch category {
        case .utility:
            return [CalculatorTool()]
        case .information:
            return [WeatherTool(), WebSearchTool()]
        case .all:
            return allTools
        }
    }
}

/// Tool categories for organization
enum ToolCategory: String, CaseIterable, Sendable {
    case utility = "Utility"
    case information = "Information"
    case all = "All"

    var description: String {
        switch self {
        case .utility:
            return "Tools for calculations and data processing"
        case .information:
            return "Tools for retrieving external information"
        case .all:
            return "All available tools"
        }
    }
}