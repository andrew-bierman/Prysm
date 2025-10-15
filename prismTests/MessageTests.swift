import XCTest
import SwiftData
import FoundationModels
@testable import Prism

@MainActor
final class MessageTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        try await super.setUp()

        // Create in-memory model container for testing
        modelContainer = try ModelContainer(
            for: Message.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        modelContext = modelContainer.mainContext
    }

    override func tearDown() async throws {
        modelContext = nil
        modelContainer = nil
        try await super.tearDown()
    }

    // MARK: - Message Creation Tests

    func testMessageInitialization() {
        let content = "Hello, world!"
        let role = MessageRole.user
        let timestamp = Date()

        let message = Message(content: content, role: role, timestamp: timestamp)

        XCTAssertNotNil(message.id)
        XCTAssertEqual(message.content, content)
        XCTAssertEqual(message.role, role)
        XCTAssertEqual(message.timestamp, timestamp)
        XCTAssertNil(message.tokens)
    }

    func testMessageInitializationWithTokens() {
        let content = "Hello with tokens"
        let role = MessageRole.assistant
        let tokens = 42

        let message = Message(content: content, role: role, tokens: tokens)

        XCTAssertEqual(message.content, content)
        XCTAssertEqual(message.role, role)
        XCTAssertEqual(message.tokens, tokens)
    }

    func testMessageInitializationWithDefaultTimestamp() {
        let beforeCreation = Date()
        let message = Message(content: "Test", role: .user)
        let afterCreation = Date()

        XCTAssertGreaterThanOrEqual(message.timestamp, beforeCreation)
        XCTAssertLessThanOrEqual(message.timestamp, afterCreation)
    }

    func testUniqueMessageIDs() {
        let message1 = Message(content: "First", role: .user)
        let message2 = Message(content: "Second", role: .user)

        XCTAssertNotEqual(message1.id, message2.id)
    }

    // MARK: - MessageRole Tests

    func testMessageRoleDisplayNames() {
        XCTAssertEqual(MessageRole.user.displayName, "You")
        XCTAssertEqual(MessageRole.assistant.displayName, "Prism")
        XCTAssertEqual(MessageRole.system.displayName, "System")
    }

    func testMessageRoleIconNames() {
        XCTAssertEqual(MessageRole.user.iconName, "person.circle.fill")
        XCTAssertEqual(MessageRole.assistant.iconName, "sparkles")
        XCTAssertEqual(MessageRole.system.iconName, "gearshape.fill")
    }

    func testMessageRoleLanguageModelRoleConversion() {
        XCTAssertEqual(MessageRole.user.languageModelRole, LanguageModel.MessageRole.user)
        XCTAssertEqual(MessageRole.assistant.languageModelRole, LanguageModel.MessageRole.assistant)
        XCTAssertEqual(MessageRole.system.languageModelRole, LanguageModel.MessageRole.system)
    }

    func testMessageRoleRawValues() {
        XCTAssertEqual(MessageRole.user.rawValue, "user")
        XCTAssertEqual(MessageRole.assistant.rawValue, "assistant")
        XCTAssertEqual(MessageRole.system.rawValue, "system")
    }

    func testMessageRoleFromRawValue() {
        XCTAssertEqual(MessageRole(rawValue: "user"), .user)
        XCTAssertEqual(MessageRole(rawValue: "assistant"), .assistant)
        XCTAssertEqual(MessageRole(rawValue: "system"), .system)
        XCTAssertNil(MessageRole(rawValue: "invalid"))
    }

    func testMessageRoleAllCases() {
        let allRoles = MessageRole.allCases
        XCTAssertEqual(allRoles.count, 3)
        XCTAssertTrue(allRoles.contains(.user))
        XCTAssertTrue(allRoles.contains(.assistant))
        XCTAssertTrue(allRoles.contains(.system))
    }

    // MARK: - SwiftData Persistence Tests

    func testMessagePersistence() throws {
        let content = "Persistent message"
        let role = MessageRole.user
        let tokens = 10

        let message = Message(content: content, role: role, tokens: tokens)

        // Insert into context
        modelContext.insert(message)
        try modelContext.save()

        // Fetch from context
        let fetchDescriptor = FetchDescriptor<Message>()
        let fetchedMessages = try modelContext.fetch(fetchDescriptor)

        XCTAssertEqual(fetchedMessages.count, 1)
        let fetchedMessage = fetchedMessages.first!

        XCTAssertEqual(fetchedMessage.id, message.id)
        XCTAssertEqual(fetchedMessage.content, content)
        XCTAssertEqual(fetchedMessage.role, role)
        XCTAssertEqual(fetchedMessage.tokens, tokens)
    }

    func testMultipleMessagesPersistence() throws {
        let messages = [
            Message(content: "First message", role: .user),
            Message(content: "Second message", role: .assistant, tokens: 5),
            Message(content: "Third message", role: .system)
        ]

        // Insert all messages
        for message in messages {
            modelContext.insert(message)
        }
        try modelContext.save()

        // Fetch all messages
        let fetchDescriptor = FetchDescriptor<Message>()
        let fetchedMessages = try modelContext.fetch(fetchDescriptor)

        XCTAssertEqual(fetchedMessages.count, 3)

        // Verify content
        let contents = fetchedMessages.map { $0.content }.sorted()
        XCTAssertEqual(contents, ["First message", "Second message", "Third message"])
    }

    func testMessageUpdate() throws {
        let message = Message(content: "Original content", role: .user)

        modelContext.insert(message)
        try modelContext.save()

        // Update content
        message.content = "Updated content"
        try modelContext.save()

        // Fetch and verify
        let fetchDescriptor = FetchDescriptor<Message>()
        let fetchedMessages = try modelContext.fetch(fetchDescriptor)

        XCTAssertEqual(fetchedMessages.count, 1)
        XCTAssertEqual(fetchedMessages.first?.content, "Updated content")
    }

    func testMessageDeletion() throws {
        let message = Message(content: "To be deleted", role: .user)

        modelContext.insert(message)
        try modelContext.save()

        // Verify insertion
        var fetchDescriptor = FetchDescriptor<Message>()
        var fetchedMessages = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(fetchedMessages.count, 1)

        // Delete message
        modelContext.delete(message)
        try modelContext.save()

        // Verify deletion
        fetchDescriptor = FetchDescriptor<Message>()
        fetchedMessages = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(fetchedMessages.count, 0)
    }

    func testFetchWithPredicate() throws {
        let userMessage = Message(content: "User message", role: .user)
        let assistantMessage = Message(content: "Assistant message", role: .assistant)
        let systemMessage = Message(content: "System message", role: .system)

        modelContext.insert(userMessage)
        modelContext.insert(assistantMessage)
        modelContext.insert(systemMessage)
        try modelContext.save()

        // Fetch only user messages
        let userPredicate = #Predicate<Message> { message in
            message.role == MessageRole.user
        }
        let userDescriptor = FetchDescriptor(predicate: userPredicate)
        let userMessages = try modelContext.fetch(userDescriptor)

        XCTAssertEqual(userMessages.count, 1)
        XCTAssertEqual(userMessages.first?.content, "User message")
    }

    func testFetchWithSorting() throws {
        let now = Date()
        let message1 = Message(content: "First", role: .user, timestamp: now.addingTimeInterval(-60))
        let message2 = Message(content: "Second", role: .user, timestamp: now.addingTimeInterval(-30))
        let message3 = Message(content: "Third", role: .user, timestamp: now)

        modelContext.insert(message1)
        modelContext.insert(message2)
        modelContext.insert(message3)
        try modelContext.save()

        // Fetch sorted by timestamp
        let sortDescriptor = SortDescriptor<Message>(\.timestamp, order: .forward)
        let fetchDescriptor = FetchDescriptor<Message>(sortBy: [sortDescriptor])
        let sortedMessages = try modelContext.fetch(fetchDescriptor)

        XCTAssertEqual(sortedMessages.count, 3)
        XCTAssertEqual(sortedMessages[0].content, "First")
        XCTAssertEqual(sortedMessages[1].content, "Second")
        XCTAssertEqual(sortedMessages[2].content, "Third")
    }

    func testFetchWithLimit() throws {
        for i in 1...10 {
            let message = Message(content: "Message \(i)", role: .user)
            modelContext.insert(message)
        }
        try modelContext.save()

        // Fetch with limit
        var fetchDescriptor = FetchDescriptor<Message>()
        fetchDescriptor.fetchLimit = 5
        let limitedMessages = try modelContext.fetch(fetchDescriptor)

        XCTAssertEqual(limitedMessages.count, 5)
    }

    // MARK: - Message Content Tests

    func testEmptyMessageContent() {
        let message = Message(content: "", role: .user)
        XCTAssertEqual(message.content, "")
    }

    func testLongMessageContent() {
        let longContent = String(repeating: "A", count: 10000)
        let message = Message(content: longContent, role: .assistant)
        XCTAssertEqual(message.content.count, 10000)
    }

    func testMessageContentWithSpecialCharacters() {
        let specialContent = "Message with émojis 🎉 and spëcial characters: !@#$%^&*()_+{}|:<>?[]\\;'\",./"
        let message = Message(content: specialContent, role: .user)
        XCTAssertEqual(message.content, specialContent)
    }

    func testMessageContentWithNewlines() {
        let multilineContent = """
        This is a multiline message
        with several lines
        of content.
        """
        let message = Message(content: multilineContent, role: .assistant)
        XCTAssertEqual(message.content, multilineContent)
    }

    // MARK: - Message Tokens Tests

    func testMessageWithZeroTokens() {
        let message = Message(content: "Test", role: .user, tokens: 0)
        XCTAssertEqual(message.tokens, 0)
    }

    func testMessageWithNegativeTokens() {
        // While this shouldn't happen in practice, the model should handle it
        let message = Message(content: "Test", role: .user, tokens: -5)
        XCTAssertEqual(message.tokens, -5)
    }

    func testMessageWithLargeTokenCount() {
        let largeTokenCount = 1_000_000
        let message = Message(content: "Test", role: .assistant, tokens: largeTokenCount)
        XCTAssertEqual(message.tokens, largeTokenCount)
    }

    // MARK: - Message Timestamp Tests

    func testMessageTimestampPersistence() throws {
        let specificDate = Date(timeIntervalSince1970: 1640995200) // Jan 1, 2022
        let message = Message(content: "Timestamped message", role: .user, timestamp: specificDate)

        modelContext.insert(message)
        try modelContext.save()

        let fetchDescriptor = FetchDescriptor<Message>()
        let fetchedMessages = try modelContext.fetch(fetchDescriptor)

        XCTAssertEqual(fetchedMessages.count, 1)
        XCTAssertEqual(fetchedMessages.first?.timestamp, specificDate)
    }

    func testMessageTimestampOrdering() {
        let baseDate = Date()
        let message1 = Message(content: "First", role: .user, timestamp: baseDate)
        let message2 = Message(content: "Second", role: .user, timestamp: baseDate.addingTimeInterval(1))
        let message3 = Message(content: "Third", role: .user, timestamp: baseDate.addingTimeInterval(2))

        let messages = [message2, message1, message3] // Intentionally out of order
        let sortedMessages = messages.sorted { $0.timestamp < $1.timestamp }

        XCTAssertEqual(sortedMessages[0].content, "First")
        XCTAssertEqual(sortedMessages[1].content, "Second")
        XCTAssertEqual(sortedMessages[2].content, "Third")
    }

    // MARK: - Codable Tests

    func testMessageRoleCodable() throws {
        let roles: [MessageRole] = [.user, .assistant, .system]

        for role in roles {
            let encoded = try JSONEncoder().encode(role)
            let decoded = try JSONDecoder().decode(MessageRole.self, from: encoded)
            XCTAssertEqual(decoded, role)
        }
    }

    func testMessageRoleDecodingFromString() throws {
        let userJSON = "\"user\"".data(using: .utf8)!
        let assistantJSON = "\"assistant\"".data(using: .utf8)!
        let systemJSON = "\"system\"".data(using: .utf8)!

        let userRole = try JSONDecoder().decode(MessageRole.self, from: userJSON)
        let assistantRole = try JSONDecoder().decode(MessageRole.self, from: assistantJSON)
        let systemRole = try JSONDecoder().decode(MessageRole.self, from: systemJSON)

        XCTAssertEqual(userRole, .user)
        XCTAssertEqual(assistantRole, .assistant)
        XCTAssertEqual(systemRole, .system)
    }

    func testMessageRoleDecodingInvalidValue() {
        let invalidJSON = "\"invalid_role\"".data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(MessageRole.self, from: invalidJSON))
    }

    // MARK: - Performance Tests

    func testMessageCreationPerformance() {
        measure {
            for i in 0..<1000 {
                let _ = Message(content: "Performance test message \(i)", role: .user)
            }
        }
    }

    func testMessagePersistencePerformance() throws {
        let messages = (0..<100).map { i in
            Message(content: "Bulk message \(i)", role: i % 2 == 0 ? .user : .assistant)
        }

        measure {
            for message in messages {
                modelContext.insert(message)
            }
            try! modelContext.save()
        }
    }

    func testMessageFetchPerformance() throws {
        // Insert test data
        for i in 0..<500 {
            let message = Message(content: "Fetch test \(i)", role: .user)
            modelContext.insert(message)
        }
        try modelContext.save()

        measure {
            let fetchDescriptor = FetchDescriptor<Message>()
            let _ = try! modelContext.fetch(fetchDescriptor)
        }
    }

    // MARK: - Edge Cases

    func testMessageWithVeryLongContent() throws {
        // Test with very long content (1MB)
        let longContent = String(repeating: "Very long message content. ", count: 40000)
        let message = Message(content: longContent, role: .assistant)

        modelContext.insert(message)
        try modelContext.save()

        let fetchDescriptor = FetchDescriptor<Message>()
        let fetchedMessages = try modelContext.fetch(fetchDescriptor)

        XCTAssertEqual(fetchedMessages.count, 1)
        XCTAssertEqual(fetchedMessages.first?.content.count, longContent.count)
    }

    func testMessageWithUnicodeContent() throws {
        let unicodeContent = "🌍🚀👨‍💻 Unicode test with émojis and spëcial characters: 你好世界 🇺🇸🇫🇷🇯🇵"
        let message = Message(content: unicodeContent, role: .user)

        modelContext.insert(message)
        try modelContext.save()

        let fetchDescriptor = FetchDescriptor<Message>()
        let fetchedMessages = try modelContext.fetch(fetchDescriptor)

        XCTAssertEqual(fetchedMessages.count, 1)
        XCTAssertEqual(fetchedMessages.first?.content, unicodeContent)
    }

    func testConcurrentMessageOperations() throws {
        let expectation = XCTestExpectation(description: "Concurrent operations completed")
        let operationCount = 10
        var completedOperations = 0

        // Perform concurrent insertions
        for i in 0..<operationCount {
            DispatchQueue.global().async {
                let message = Message(content: "Concurrent message \(i)", role: .user)

                DispatchQueue.main.async {
                    self.modelContext.insert(message)

                    completedOperations += 1
                    if completedOperations == operationCount {
                        expectation.fulfill()
                    }
                }
            }
        }

        wait(for: [expectation], timeout: 5.0)
        try modelContext.save()

        let fetchDescriptor = FetchDescriptor<Message>()
        let fetchedMessages = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(fetchedMessages.count, operationCount)
    }
}

// MARK: - Test Helpers and Extensions

extension MessageTests {

    /// Helper to create a message with specific content and role
    private func createTestMessage(content: String = "Test message",
                                   role: MessageRole = .user,
                                   tokens: Int? = nil) -> Message {
        return Message(content: content, role: role, tokens: tokens)
    }

    /// Helper to insert and save a message
    private func insertAndSave(_ message: Message) throws {
        modelContext.insert(message)
        try modelContext.save()
    }

    /// Helper to fetch all messages
    private func fetchAllMessages() throws -> [Message] {
        let fetchDescriptor = FetchDescriptor<Message>()
        return try modelContext.fetch(fetchDescriptor)
    }
}

// MARK: - Mock Data for Testing

extension Message {
    /// Factory method for creating test user messages
    static func testUser(_ content: String, tokens: Int? = nil) -> Message {
        return Message(content: content, role: .user, tokens: tokens)
    }

    /// Factory method for creating test assistant messages
    static func testAssistant(_ content: String, tokens: Int? = nil) -> Message {
        return Message(content: content, role: .assistant, tokens: tokens)
    }

    /// Factory method for creating test system messages
    static func testSystem(_ content: String) -> Message {
        return Message(content: content, role: .system)
    }
}

extension MessageRole {
    /// All roles for testing iteration
    static var testCases: [MessageRole] {
        return allCases
    }
}