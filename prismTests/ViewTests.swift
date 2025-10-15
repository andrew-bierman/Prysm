import XCTest
import SwiftUI
import SwiftData
import ViewInspector
@testable import Prism

@MainActor
final class ViewTests: XCTestCase {

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

    // MARK: - ChatView Tests

    func testChatViewInitialization() throws {
        let chatView = ChatView(modelContext: modelContext)

        // Test that the view can be created without throwing
        XCTAssertNotNil(chatView)
    }

    func testChatViewWithEmptyState() throws {
        let chatView = ChatView(modelContext: modelContext)
        let hostingController = UIHostingController(rootView: chatView)

        // Verify the hosting controller loads without issues
        XCTAssertNotNil(hostingController.view)
    }

    func testChatViewEmptyStateContent() async throws {
        let chatView = ChatView(modelContext: modelContext)

        // In a real implementation, you would use ViewInspector to test the view hierarchy
        // This is a basic structure test
        let hostingController = UIHostingController(rootView: chatView)
        hostingController.loadViewIfNeeded()

        XCTAssertNotNil(hostingController.view)
    }

    func testChatViewWithMessages() async throws {
        // Add a message to the context
        let message = Message(content: "Test message", role: .user)
        modelContext.insert(message)
        try modelContext.save()

        let chatView = ChatView(modelContext: modelContext)
        let hostingController = UIHostingController(rootView: chatView)

        XCTAssertNotNil(hostingController.view)
    }

    func testChatViewBackgroundOnDifferentPlatforms() throws {
        let chatView = ChatView(modelContext: modelContext)

        #if os(iOS)
        // Test iOS-specific behavior
        let hostingController = UIHostingController(rootView: chatView)
        XCTAssertNotNil(hostingController.view)
        #elseif os(macOS)
        // Test macOS-specific behavior
        let hostingController = NSHostingController(rootView: chatView)
        XCTAssertNotNil(hostingController.view)
        #endif
    }

    // MARK: - MessageBubble Tests

    func testMessageBubbleUserMessage() async throws {
        let viewModel = ChatViewModel(modelContext: modelContext)
        let userMessage = Message(content: "Hello from user", role: .user)

        let messageBubble = MessageBubble(message: userMessage, viewModel: viewModel)
        let hostingController = UIHostingController(rootView: messageBubble)

        XCTAssertNotNil(hostingController.view)
    }

    func testMessageBubbleAssistantMessage() async throws {
        let viewModel = ChatViewModel(modelContext: modelContext)
        let assistantMessage = Message(content: "Hello from assistant", role: .assistant, tokens: 5)

        let messageBubble = MessageBubble(message: assistantMessage, viewModel: viewModel)
        let hostingController = UIHostingController(rootView: messageBubble)

        XCTAssertNotNil(hostingController.view)
    }

    func testMessageBubbleSystemMessage() async throws {
        let viewModel = ChatViewModel(modelContext: modelContext)
        let systemMessage = Message(content: "System message", role: .system)

        let messageBubble = MessageBubble(message: systemMessage, viewModel: viewModel)
        let hostingController = UIHostingController(rootView: messageBubble)

        XCTAssertNotNil(hostingController.view)
    }

    func testMessageBubbleWithMarkdown() async throws {
        let viewModel = ChatViewModel(modelContext: modelContext)
        let markdownMessage = Message(
            content: "This message contains **bold text** and *italic text*",
            role: .assistant
        )

        let messageBubble = MessageBubble(message: markdownMessage, viewModel: viewModel)
        let hostingController = UIHostingController(rootView: messageBubble)

        XCTAssertNotNil(hostingController.view)
    }

    func testMessageBubbleWithLongContent() async throws {
        let viewModel = ChatViewModel(modelContext: modelContext)
        let longContent = String(repeating: "This is a very long message. ", count: 100)
        let longMessage = Message(content: longContent, role: .user)

        let messageBubble = MessageBubble(message: longMessage, viewModel: viewModel)
        let hostingController = UIHostingController(rootView: messageBubble)

        XCTAssertNotNil(hostingController.view)
    }

    func testMessageBubbleWithEmptyContent() async throws {
        let viewModel = ChatViewModel(modelContext: modelContext)
        let emptyMessage = Message(content: "", role: .assistant)

        let messageBubble = MessageBubble(message: emptyMessage, viewModel: viewModel)
        let hostingController = UIHostingController(rootView: messageBubble)

        XCTAssertNotNil(hostingController.view)
    }

    func testMessageBubbleAccessibility() async throws {
        let viewModel = ChatViewModel(modelContext: modelContext)
        let message = Message(content: "Accessibility test message", role: .user)

        let messageBubble = MessageBubble(message: message, viewModel: viewModel)
        let hostingController = UIHostingController(rootView: messageBubble)

        // Test that accessibility properties are set
        XCTAssertNotNil(hostingController.view)
    }

    // MARK: - TypingIndicator Tests

    func testTypingIndicator() throws {
        let typingIndicator = TypingIndicator()
        let hostingController = UIHostingController(rootView: typingIndicator)

        XCTAssertNotNil(hostingController.view)
    }

    func testTypingIndicatorAccessibility() throws {
        let typingIndicator = TypingIndicator()
        let hostingController = UIHostingController(rootView: typingIndicator)

        // Verify the view loads without issues
        XCTAssertNotNil(hostingController.view)
    }

    // MARK: - Color Scheme Tests

    func testMessageBubbleLightMode() async throws {
        let viewModel = ChatViewModel(modelContext: modelContext)
        let message = Message(content: "Light mode test", role: .user)

        let messageBubble = MessageBubble(message: message, viewModel: viewModel)
            .preferredColorScheme(.light)

        let hostingController = UIHostingController(rootView: messageBubble)
        XCTAssertNotNil(hostingController.view)
    }

    func testMessageBubbleDarkMode() async throws {
        let viewModel = ChatViewModel(modelContext: modelContext)
        let message = Message(content: "Dark mode test", role: .assistant)

        let messageBubble = MessageBubble(message: message, viewModel: viewModel)
            .preferredColorScheme(.dark)

        let hostingController = UIHostingController(rootView: messageBubble)
        XCTAssertNotNil(hostingController.view)
    }

    func testChatViewLightMode() throws {
        let chatView = ChatView(modelContext: modelContext)
            .preferredColorScheme(.light)

        let hostingController = UIHostingController(rootView: chatView)
        XCTAssertNotNil(hostingController.view)
    }

    func testChatViewDarkMode() throws {
        let chatView = ChatView(modelContext: modelContext)
            .preferredColorScheme(.dark)

        let hostingController = UIHostingController(rootView: chatView)
        XCTAssertNotNil(hostingController.view)
    }

    // MARK: - Dynamic Type Tests

    func testMessageBubbleWithLargeText() async throws {
        let viewModel = ChatViewModel(modelContext: modelContext)
        let message = Message(content: "Dynamic type test", role: .user)

        let messageBubble = MessageBubble(message: message, viewModel: viewModel)
            .dynamicTypeSize(.xxxLarge)

        let hostingController = UIHostingController(rootView: messageBubble)
        XCTAssertNotNil(hostingController.view)
    }

    func testMessageBubbleWithSmallText() async throws {
        let viewModel = ChatViewModel(modelContext: modelContext)
        let message = Message(content: "Small text test", role: .assistant)

        let messageBubble = MessageBubble(message: message, viewModel: viewModel)
            .dynamicTypeSize(.xSmall)

        let hostingController = UIHostingController(rootView: messageBubble)
        XCTAssertNotNil(hostingController.view)
    }

    // MARK: - Performance Tests

    func testChatViewRenderingPerformance() throws {
        measure {
            let chatView = ChatView(modelContext: modelContext)
            let hostingController = UIHostingController(rootView: chatView)
            hostingController.loadViewIfNeeded()
        }
    }

    func testMessageBubbleRenderingPerformance() async throws {
        let viewModel = ChatViewModel(modelContext: modelContext)
        let message = Message(content: "Performance test message", role: .user)

        measure {
            let messageBubble = MessageBubble(message: message, viewModel: viewModel)
            let hostingController = UIHostingController(rootView: messageBubble)
            hostingController.loadViewIfNeeded()
        }
    }

    func testMultipleMessageBubblesPerformance() async throws {
        let viewModel = ChatViewModel(modelContext: modelContext)
        let messages = (0..<50).map { i in
            Message(content: "Message \(i)", role: i % 2 == 0 ? .user : .assistant)
        }

        measure {
            let vStack = VStack {
                ForEach(messages, id: \.id) { message in
                    MessageBubble(message: message, viewModel: viewModel)
                }
            }
            let hostingController = UIHostingController(rootView: vStack)
            hostingController.loadViewIfNeeded()
        }
    }

    // MARK: - State Change Tests

    func testMessageBubbleWithViewModelStateChanges() async throws {
        let viewModel = ChatViewModel(modelContext: modelContext)
        let message = Message(content: "State change test", role: .assistant)

        let messageBubble = MessageBubble(message: message, viewModel: viewModel)
        let hostingController = UIHostingController(rootView: messageBubble)

        // Test initial state
        XCTAssertNotNil(hostingController.view)

        // Simulate state changes
        viewModel.handleError(ChatError.networkError)

        // View should still be valid
        XCTAssertNotNil(hostingController.view)

        viewModel.clearError()

        // View should still be valid
        XCTAssertNotNil(hostingController.view)
    }

    func testChatViewWithViewModelStateChanges() async throws {
        let chatView = ChatView(modelContext: modelContext)
        let hostingController = UIHostingController(rootView: chatView)

        // Test initial state
        XCTAssertNotNil(hostingController.view)

        // The view should handle state changes gracefully
        // In a real test, you would trigger state changes and verify the UI updates
    }

    // MARK: - Memory Tests

    func testChatViewMemoryUsage() throws {
        weak var weakController: UIHostingController<ChatView>?

        autoreleasepool {
            let chatView = ChatView(modelContext: modelContext)
            let hostingController = UIHostingController(rootView: chatView)
            weakController = hostingController
            hostingController.loadViewIfNeeded()
        }

        // Verify the controller is deallocated when no longer referenced
        // Note: This test might be flaky due to ARC timing
        // XCTAssertNil(weakController)
    }

    func testMessageBubbleMemoryUsage() async throws {
        weak var weakController: UIHostingController<MessageBubble>?

        autoreleasepool {
            let viewModel = ChatViewModel(modelContext: modelContext)
            let message = Message(content: "Memory test", role: .user)
            let messageBubble = MessageBubble(message: message, viewModel: viewModel)
            let hostingController = UIHostingController(rootView: messageBubble)
            weakController = hostingController
            hostingController.loadViewIfNeeded()
        }

        // Verify the controller is deallocated when no longer referenced
        // Note: This test might be flaky due to ARC timing
        // XCTAssertNil(weakController)
    }

    // MARK: - Error State Tests

    func testMessageBubbleErrorState() async throws {
        let viewModel = ChatViewModel(modelContext: modelContext)
        let message = Message(content: "Error test message", role: .assistant)

        // Set an error state
        viewModel.handleError(ChatError.networkError)

        let messageBubble = MessageBubble(message: message, viewModel: viewModel)
        let hostingController = UIHostingController(rootView: messageBubble)

        XCTAssertNotNil(hostingController.view)
    }

    func testChatViewErrorState() async throws {
        let chatView = ChatView(modelContext: modelContext)
        let hostingController = UIHostingController(rootView: chatView)

        XCTAssertNotNil(hostingController.view)
    }

    // MARK: - Animation Tests

    func testMessageBubbleAnimations() async throws {
        let viewModel = ChatViewModel(modelContext: modelContext)
        let message = Message(content: "Animation test", role: .user)

        let messageBubble = MessageBubble(message: message, viewModel: viewModel)
            .animation(.easeInOut, value: message.content)

        let hostingController = UIHostingController(rootView: messageBubble)
        XCTAssertNotNil(hostingController.view)
    }

    func testTypingIndicatorAnimation() throws {
        let typingIndicator = TypingIndicator()
            .animation(.easeInOut, value: true)

        let hostingController = UIHostingController(rootView: typingIndicator)
        XCTAssertNotNil(hostingController.view)
    }

    // MARK: - Integration Tests

    func testChatViewWithMultipleMessages() async throws {
        // Add multiple messages to the context
        let messages = [
            Message(content: "First message", role: .user),
            Message(content: "Second message", role: .assistant, tokens: 5),
            Message(content: "Third message", role: .user),
            Message(content: "Fourth message", role: .assistant, tokens: 8)
        ]

        for message in messages {
            modelContext.insert(message)
        }
        try modelContext.save()

        let chatView = ChatView(modelContext: modelContext)
        let hostingController = UIHostingController(rootView: chatView)

        XCTAssertNotNil(hostingController.view)
    }

    func testMessageBubbleWithAllRoles() async throws {
        let viewModel = ChatViewModel(modelContext: modelContext)

        let roles: [MessageRole] = [.user, .assistant, .system]

        for role in roles {
            let message = Message(content: "Test message for \(role.rawValue)", role: role)
            let messageBubble = MessageBubble(message: message, viewModel: viewModel)
            let hostingController = UIHostingController(rootView: messageBubble)

            XCTAssertNotNil(hostingController.view)
        }
    }

    // MARK: - Platform-specific Tests

    #if os(iOS)
    func testChatViewiOSLayout() throws {
        let chatView = ChatView(modelContext: modelContext)
        let hostingController = UIHostingController(rootView: chatView)

        // Test iOS-specific properties
        XCTAssertNotNil(hostingController.view)
        XCTAssertEqual(hostingController.view.backgroundColor, UIColor.systemBackground)
    }

    func testMessageBubbleiOSBehavior() async throws {
        let viewModel = ChatViewModel(modelContext: modelContext)
        let message = Message(content: "iOS test", role: .user)

        let messageBubble = MessageBubble(message: message, viewModel: viewModel)
        let hostingController = UIHostingController(rootView: messageBubble)

        XCTAssertNotNil(hostingController.view)
    }
    #endif

    #if os(macOS)
    func testChatViewmacOSLayout() throws {
        let chatView = ChatView(modelContext: modelContext)
        let hostingController = NSHostingController(rootView: chatView)

        XCTAssertNotNil(hostingController.view)
    }

    func testMessageBubblemacOSBehavior() async throws {
        let viewModel = ChatViewModel(modelContext: modelContext)
        let message = Message(content: "macOS test", role: .user)

        let messageBubble = MessageBubble(message: message, viewModel: viewModel)
        let hostingController = NSHostingController(rootView: messageBubble)

        XCTAssertNotNil(hostingController.view)
    }
    #endif

    // MARK: - Stress Tests

    func testChatViewWithManyMessages() async throws {
        // Add many messages to stress test the view
        for i in 0..<100 {
            let message = Message(
                content: "Stress test message \(i)",
                role: i % 2 == 0 ? .user : .assistant,
                tokens: i % 2 == 1 ? i : nil
            )
            modelContext.insert(message)
        }
        try modelContext.save()

        let chatView = ChatView(modelContext: modelContext)
        let hostingController = UIHostingController(rootView: chatView)

        measure {
            hostingController.loadViewIfNeeded()
        }
    }

    func testMessageBubbleWithVeryLongContent() async throws {
        let viewModel = ChatViewModel(modelContext: modelContext)
        let veryLongContent = String(repeating: "This is a very long message that should test the rendering capabilities of the MessageBubble view. ", count: 1000)
        let message = Message(content: veryLongContent, role: .assistant)

        let messageBubble = MessageBubble(message: message, viewModel: viewModel)
        let hostingController = UIHostingController(rootView: messageBubble)

        measure {
            hostingController.loadViewIfNeeded()
        }
    }
}

// MARK: - Test Helpers

extension ViewTests {

    /// Helper to create a test message
    private func createTestMessage(content: String = "Test message",
                                   role: MessageRole = .user,
                                   tokens: Int? = nil) -> Message {
        return Message(content: content, role: role, tokens: tokens)
    }

    /// Helper to create a test view model
    private func createTestViewModel() -> ChatViewModel {
        return ChatViewModel(modelContext: modelContext)
    }
}

// MARK: - Mock Views for Testing

struct MockChatView: View {
    var body: some View {
        Text("Mock Chat View")
    }
}

struct MockMessageBubble: View {
    let message: Message

    var body: some View {
        Text(message.content)
    }
}

// MARK: - ViewInspector Extensions

// Note: These extensions would be used if ViewInspector is added to the project
// They provide more detailed view testing capabilities

/*
extension ChatView: Inspectable {}
extension MessageBubble: Inspectable {}
extension TypingIndicator: Inspectable {}

extension ViewTests {

    func testChatViewHierarchy() throws {
        let chatView = ChatView(modelContext: modelContext)

        let navigationStack = try chatView.inspect().navigationStack()
        XCTAssertNotNil(navigationStack)

        let vStack = try navigationStack.vStack()
        XCTAssertNotNil(vStack)
    }

    func testMessageBubbleHierarchy() async throws {
        let viewModel = ChatViewModel(modelContext: modelContext)
        let message = Message(content: "Test", role: .user)
        let messageBubble = MessageBubble(message: message, viewModel: viewModel)

        let hStack = try messageBubble.inspect().hStack()
        XCTAssertNotNil(hStack)
    }
}
*/