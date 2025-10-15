import XCTest
import FoundationModels
@testable import Prism

final class CustomToolsTests: XCTestCase {

    // MARK: - WeatherTool Tests

    func testWeatherToolProperties() {
        let weatherTool = WeatherTool()

        XCTAssertEqual(weatherTool.name, "get_weather")
        XCTAssertEqual(weatherTool.description, "Get current weather information for a specific location including temperature, conditions, and forecast")
    }

    func testWeatherToolWithValidLocation() async throws {
        let weatherTool = WeatherTool()
        let arguments = WeatherTool.Arguments()
        arguments.location = "New York"
        arguments.units = "celsius"

        let result = try await weatherTool.call(arguments: arguments)

        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.contains("Current weather for New York"))
        XCTAssertTrue(result.contains("Temperature:"))
        XCTAssertTrue(result.contains("°C"))
        XCTAssertTrue(result.contains("Conditions:"))
        XCTAssertTrue(result.contains("Humidity:"))
        XCTAssertTrue(result.contains("Wind Speed:"))
    }

    func testWeatherToolWithFahrenheit() async throws {
        let weatherTool = WeatherTool()
        let arguments = WeatherTool.Arguments()
        arguments.location = "Los Angeles"
        arguments.units = "fahrenheit"

        let result = try await weatherTool.call(arguments: arguments)

        XCTAssertTrue(result.contains("°F"))
        XCTAssertTrue(result.contains("mph"))
        XCTAssertFalse(result.contains("°C"))
        XCTAssertFalse(result.contains("km/h"))
    }

    func testWeatherToolDefaultUnits() async throws {
        let weatherTool = WeatherTool()
        let arguments = WeatherTool.Arguments()
        arguments.location = "London"
        // units is nil, should default to celsius

        let result = try await weatherTool.call(arguments: arguments)

        XCTAssertTrue(result.contains("°C"))
        XCTAssertTrue(result.contains("km/h"))
    }

    func testWeatherToolEmptyLocation() async throws {
        let weatherTool = WeatherTool()
        let arguments = WeatherTool.Arguments()
        arguments.location = ""

        let result = try await weatherTool.call(arguments: arguments)

        XCTAssertTrue(result.contains("Error fetching weather data"))
    }

    func testWeatherToolWhitespaceLocation() async throws {
        let weatherTool = WeatherTool()
        let arguments = WeatherTool.Arguments()
        arguments.location = "   \n\t   "

        let result = try await weatherTool.call(arguments: arguments)

        XCTAssertTrue(result.contains("Error fetching weather data"))
    }

    func testWeatherToolConsistentResults() async throws {
        let weatherTool = WeatherTool()
        let arguments = WeatherTool.Arguments()
        arguments.location = "Paris"
        arguments.units = "celsius"

        let result1 = try await weatherTool.call(arguments: arguments)
        let result2 = try await weatherTool.call(arguments: arguments)

        // Results should be consistent for the same location
        XCTAssertEqual(result1, result2)
    }

    func testWeatherToolDifferentLocations() async throws {
        let weatherTool = WeatherTool()

        let arguments1 = WeatherTool.Arguments()
        arguments1.location = "Tokyo"

        let arguments2 = WeatherTool.Arguments()
        arguments2.location = "Sydney"

        let result1 = try await weatherTool.call(arguments: arguments1)
        let result2 = try await weatherTool.call(arguments: arguments2)

        // Results should be different for different locations
        XCTAssertNotEqual(result1, result2)
        XCTAssertTrue(result1.contains("Tokyo"))
        XCTAssertTrue(result2.contains("Sydney"))
    }

    // MARK: - CalculatorTool Tests

    func testCalculatorToolProperties() {
        let calculator = CalculatorTool()

        XCTAssertEqual(calculator.name, "calculate")
        XCTAssertEqual(calculator.description, "Perform mathematical calculations including basic arithmetic, trigonometry, and advanced operations")
    }

    func testBasicArithmetic() async throws {
        let calculator = CalculatorTool()

        // Addition
        var arguments = CalculatorTool.Arguments()
        arguments.expression = "2 + 3"
        var result = try await calculator.call(arguments: arguments)
        XCTAssertTrue(result.contains("2 + 3 = 5"))

        // Subtraction
        arguments.expression = "10 - 4"
        result = try await calculator.call(arguments: arguments)
        XCTAssertTrue(result.contains("10 - 4 = 6"))

        // Multiplication
        arguments.expression = "6 * 7"
        result = try await calculator.call(arguments: arguments)
        XCTAssertTrue(result.contains("6 * 7 = 42"))

        // Division
        arguments.expression = "15 / 3"
        result = try await calculator.call(arguments: arguments)
        XCTAssertTrue(result.contains("15 / 3 = 5"))
    }

    func testComplexExpressions() async throws {
        let calculator = CalculatorTool()

        let testCases = [
            ("2 + 3 * 4", "14"), // Order of operations
            ("(2 + 3) * 4", "20"), // Parentheses
            ("10 - 2 * 3", "4"), // Order of operations
            ("(10 - 2) * 3", "24") // Parentheses
        ]

        for (expression, expectedResult) in testCases {
            let arguments = CalculatorTool.Arguments()
            arguments.expression = expression
            let result = try await calculator.call(arguments: arguments)
            XCTAssertTrue(result.contains(expectedResult), "Expected \(expectedResult) for \(expression), got: \(result)")
        }
    }

    func testDecimalCalculations() async throws {
        let calculator = CalculatorTool()

        let arguments = CalculatorTool.Arguments()
        arguments.expression = "3.14 * 2"
        arguments.precision = 2

        let result = try await calculator.call(arguments: arguments)
        XCTAssertTrue(result.contains("6.28"))
    }

    func testPrecisionControl() async throws {
        let calculator = CalculatorTool()

        // Test different precision levels
        let testCases = [
            (0, "7"), // 0 decimal places
            (1, "6.7"), // 1 decimal place
            (3, "6.667") // 3 decimal places
        ]

        for (precision, expected) in testCases {
            let arguments = CalculatorTool.Arguments()
            arguments.expression = "20 / 3"
            arguments.precision = precision

            let result = try await calculator.call(arguments: arguments)
            XCTAssertTrue(result.contains(expected), "Expected \(expected) with precision \(precision), got: \(result)")
        }
    }

    func testInvalidExpression() async throws {
        let calculator = CalculatorTool()

        let arguments = CalculatorTool.Arguments()
        arguments.expression = "invalid expression"

        let result = try await calculator.call(arguments: arguments)
        XCTAssertTrue(result.contains("Error:"))
    }

    func testDivisionByZero() async throws {
        let calculator = CalculatorTool()

        let arguments = CalculatorTool.Arguments()
        arguments.expression = "5 / 0"

        let result = try await calculator.call(arguments: arguments)
        XCTAssertTrue(result.contains("Error:"))
    }

    func testInvalidPrecision() async throws {
        let calculator = CalculatorTool()

        let arguments = CalculatorTool.Arguments()
        arguments.expression = "2 + 2"
        arguments.precision = 15 // Too high

        let result = try await calculator.call(arguments: arguments)
        XCTAssertTrue(result.contains("Error: Precision must be between 0 and 10"))
    }

    func testNegativePrecision() async throws {
        let calculator = CalculatorTool()

        let arguments = CalculatorTool.Arguments()
        arguments.expression = "2 + 2"
        arguments.precision = -1

        let result = try await calculator.call(arguments: arguments)
        XCTAssertTrue(result.contains("Error: Precision must be between 0 and 10"))
    }

    func testDefaultPrecision() async throws {
        let calculator = CalculatorTool()

        let arguments = CalculatorTool.Arguments()
        arguments.expression = "10 / 3"
        // precision is nil, should default to 2

        let result = try await calculator.call(arguments: arguments)
        XCTAssertTrue(result.contains("3.33"))
    }

    func testEmptyExpression() async throws {
        let calculator = CalculatorTool()

        let arguments = CalculatorTool.Arguments()
        arguments.expression = ""

        let result = try await calculator.call(arguments: arguments)
        XCTAssertTrue(result.contains("Error:"))
    }

    // MARK: - WebSearchTool Tests

    func testWebSearchToolProperties() {
        let webSearch = WebSearchTool()

        XCTAssertEqual(webSearch.name, "web_search")
        XCTAssertEqual(webSearch.description, "Search the web for information on any topic and return relevant results with summaries")
    }

    func testWebSearchBasicQuery() async throws {
        let webSearch = WebSearchTool()
        let arguments = WebSearchTool.Arguments()
        arguments.query = "artificial intelligence"

        let result = try await webSearch.call(arguments: arguments)

        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.contains("Search results for \"artificial intelligence\""))
        XCTAssertTrue(result.contains("1."))
        XCTAssertTrue(result.contains("Source:"))
        XCTAssertTrue(result.contains("URL:"))
        XCTAssertTrue(result.contains("Summary:"))
    }

    func testWebSearchWithMaxResults() async throws {
        let webSearch = WebSearchTool()
        let arguments = WebSearchTool.Arguments()
        arguments.query = "climate change"
        arguments.maxResults = 3

        let result = try await webSearch.call(arguments: arguments)

        // Should contain exactly 3 results
        let resultNumbers = ["1.", "2.", "3.", "4."]
        let foundNumbers = resultNumbers.filter { result.contains($0) }
        XCTAssertEqual(foundNumbers.count, 3)
    }

    func testWebSearchWithCategory() async throws {
        let webSearch = WebSearchTool()
        let arguments = WebSearchTool.Arguments()
        arguments.query = "latest technology"
        arguments.category = "news"

        let result = try await webSearch.call(arguments: arguments)

        XCTAssertTrue(result.contains("Search results"))
        XCTAssertTrue(result.contains("latest technology"))
    }

    func testWebSearchEmptyQuery() async throws {
        let webSearch = WebSearchTool()
        let arguments = WebSearchTool.Arguments()
        arguments.query = ""

        let result = try await webSearch.call(arguments: arguments)

        XCTAssertTrue(result.contains("Search error:"))
    }

    func testWebSearchWhitespaceQuery() async throws {
        let webSearch = WebSearchTool()
        let arguments = WebSearchTool.Arguments()
        arguments.query = "   \n\t   "

        let result = try await webSearch.call(arguments: arguments)

        XCTAssertTrue(result.contains("Search error:"))
    }

    func testWebSearchInvalidMaxResults() async throws {
        let webSearch = WebSearchTool()
        let arguments = WebSearchTool.Arguments()
        arguments.query = "test query"
        arguments.maxResults = 0

        let result = try await webSearch.call(arguments: arguments)

        XCTAssertTrue(result.contains("Search error:"))
    }

    func testWebSearchTooManyResults() async throws {
        let webSearch = WebSearchTool()
        let arguments = WebSearchTool.Arguments()
        arguments.query = "test query"
        arguments.maxResults = 15 // Exceeds limit

        let result = try await webSearch.call(arguments: arguments)

        XCTAssertTrue(result.contains("Search error:"))
    }

    func testWebSearchInvalidCategory() async throws {
        let webSearch = WebSearchTool()
        let arguments = WebSearchTool.Arguments()
        arguments.query = "test query"
        arguments.category = "invalid_category"

        let result = try await webSearch.call(arguments: arguments)

        XCTAssertTrue(result.contains("Search error:"))
    }

    func testWebSearchValidCategories() async throws {
        let webSearch = WebSearchTool()
        let validCategories = ["general", "news", "images", "videos", "academic"]

        for category in validCategories {
            let arguments = WebSearchTool.Arguments()
            arguments.query = "test"
            arguments.category = category

            let result = try await webSearch.call(arguments: arguments)

            XCTAssertFalse(result.contains("Search error:"), "Category \(category) should be valid")
            XCTAssertTrue(result.contains("Search results"))
        }
    }

    func testWebSearchDefaultParameters() async throws {
        let webSearch = WebSearchTool()
        let arguments = WebSearchTool.Arguments()
        arguments.query = "machine learning"
        // maxResults and category are nil, should use defaults

        let result = try await webSearch.call(arguments: arguments)

        XCTAssertTrue(result.contains("Search results"))
        // Should contain default 5 results
        let resultNumbers = ["1.", "2.", "3.", "4.", "5.", "6."]
        let foundNumbers = resultNumbers.filter { result.contains($0) }
        XCTAssertEqual(foundNumbers.count, 5)
    }

    func testWebSearchConsistentResults() async throws {
        let webSearch = WebSearchTool()
        let arguments = WebSearchTool.Arguments()
        arguments.query = "Swift programming"

        let result1 = try await webSearch.call(arguments: arguments)
        let result2 = try await webSearch.call(arguments: arguments)

        // Results should be consistent for the same query
        XCTAssertEqual(result1, result2)
    }

    func testWebSearchPerformance() async throws {
        let webSearch = WebSearchTool()
        let arguments = WebSearchTool.Arguments()
        arguments.query = "performance test"

        let startTime = Date()
        _ = try await webSearch.call(arguments: arguments)
        let duration = Date().timeIntervalSince(startTime)

        // Should complete within reasonable time (allowing for simulated delay)
        XCTAssertLessThan(duration, 2.0)
    }

    // MARK: - CustomToolCollection Tests

    func testToolCollectionContainsAllTools() {
        let allTools = CustomToolCollection.allTools

        XCTAssertEqual(allTools.count, 3)

        let toolNames = allTools.map { $0.name }
        XCTAssertTrue(toolNames.contains("get_weather"))
        XCTAssertTrue(toolNames.contains("calculate"))
        XCTAssertTrue(toolNames.contains("web_search"))
    }

    func testToolCollectionByCategory() {
        let utilityTools = CustomToolCollection.tools(for: .utility)
        XCTAssertEqual(utilityTools.count, 1)
        XCTAssertEqual(utilityTools.first?.name, "calculate")

        let informationTools = CustomToolCollection.tools(for: .information)
        XCTAssertEqual(informationTools.count, 2)
        let infoToolNames = informationTools.map { $0.name }
        XCTAssertTrue(infoToolNames.contains("get_weather"))
        XCTAssertTrue(infoToolNames.contains("web_search"))

        let allCategoryTools = CustomToolCollection.tools(for: .all)
        XCTAssertEqual(allCategoryTools.count, 3)
    }

    func testToolCategoryDescriptions() {
        XCTAssertEqual(ToolCategory.utility.description, "Tools for calculations and data processing")
        XCTAssertEqual(ToolCategory.information.description, "Tools for retrieving external information")
        XCTAssertEqual(ToolCategory.all.description, "All available tools")
    }

    func testToolCategoryAllCases() {
        let allCategories = ToolCategory.allCases
        XCTAssertEqual(allCategories.count, 3)
        XCTAssertTrue(allCategories.contains(.utility))
        XCTAssertTrue(allCategories.contains(.information))
        XCTAssertTrue(allCategories.contains(.all))
    }

    func testToolCategoryRawValues() {
        XCTAssertEqual(ToolCategory.utility.rawValue, "Utility")
        XCTAssertEqual(ToolCategory.information.rawValue, "Information")
        XCTAssertEqual(ToolCategory.all.rawValue, "All")
    }

    // MARK: - Error Handling Tests

    func testWeatherErrorDescriptions() {
        let errors: [WeatherTool.WeatherError] = [
            .invalidLocation,
            .networkUnavailable,
            .apiKeyMissing,
            .invalidResponse,
            .rateLimitExceeded
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }

    func testCalculatorErrorDescriptions() {
        let errors: [CalculatorTool.CalculationError] = [
            .invalidExpression,
            .divisionByZero,
            .domainError,
            .overflow,
            .invalidPrecision
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }

    func testWebSearchErrorDescriptions() {
        let errors: [WebSearchTool.SearchError] = [
            .emptyQuery,
            .networkError,
            .rateLimitExceeded,
            .invalidCategory,
            .noResults,
            .serviceUnavailable
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }

    // MARK: - Integration Tests

    func testToolChaining() async throws {
        // Test using calculator to calculate something, then searching for related info
        let calculator = CalculatorTool()
        let webSearch = WebSearchTool()

        // Calculate the answer to life, universe, and everything
        var calcArgs = CalculatorTool.Arguments()
        calcArgs.expression = "6 * 7"
        let calcResult = try await calculator.call(arguments: calcArgs)
        XCTAssertTrue(calcResult.contains("42"))

        // Search for information about the number 42
        var searchArgs = WebSearchTool.Arguments()
        searchArgs.query = "meaning of 42"
        searchArgs.maxResults = 2
        let searchResult = try await webSearch.call(arguments: searchArgs)
        XCTAssertTrue(searchResult.contains("Search results"))
    }

    func testToolConcurrency() async throws {
        let weatherTool = WeatherTool()
        let calculator = CalculatorTool()
        let webSearch = WebSearchTool()

        // Execute all tools concurrently
        async let weatherResult = weatherTool.call(arguments: {
            let args = WeatherTool.Arguments()
            args.location = "Berlin"
            return args
        }())

        async let calcResult = calculator.call(arguments: {
            let args = CalculatorTool.Arguments()
            args.expression = "100 / 4"
            return args
        }())

        async let searchResult = webSearch.call(arguments: {
            let args = WebSearchTool.Arguments()
            args.query = "concurrent testing"
            args.maxResults = 1
            return args
        }())

        let (weather, calc, search) = try await (weatherResult, calcResult, searchResult)

        XCTAssertTrue(weather.contains("Berlin"))
        XCTAssertTrue(calc.contains("25"))
        XCTAssertTrue(search.contains("Search results"))
    }

    // MARK: - Performance Tests

    func testWeatherToolPerformance() async throws {
        let weatherTool = WeatherTool()
        let arguments = WeatherTool.Arguments()
        arguments.location = "New York"

        measure {
            Task {
                _ = try! await weatherTool.call(arguments: arguments)
            }
        }
    }

    func testCalculatorToolPerformance() async throws {
        let calculator = CalculatorTool()

        measure {
            Task {
                for i in 1...100 {
                    let arguments = CalculatorTool.Arguments()
                    arguments.expression = "\(i) * \(i)"
                    _ = try! await calculator.call(arguments: arguments)
                }
            }
        }
    }

    func testWebSearchToolPerformance() async throws {
        let webSearch = WebSearchTool()
        let arguments = WebSearchTool.Arguments()
        arguments.query = "performance test"
        arguments.maxResults = 1

        measure {
            Task {
                _ = try! await webSearch.call(arguments: arguments)
            }
        }
    }
}