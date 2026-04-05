import SwiftUI
import PrintUI

@main
struct PrintUIApp: App {
    init() {
        registerLogProvider(InMemoryLogger.shared)
    }

    var body: some Scene {
        WindowGroup {
            LogDemoView()
        }
    }
}

// MARK: - In-Memory Provider (demo only)

@Observable
final class InMemoryLogger: LogProvider, @unchecked Sendable {
    static let shared = InMemoryLogger()

    let enabledLevels: Set<LogLevel> = Set(LogLevel.allCases)
    private let lock = NSLock()
    private(set) var events: [LogEvent] = []

    nonisolated func log(_ event: LogEvent) {
        lock.lock()
        events.append(event)
        lock.unlock()
    }

    func clear() {
        lock.lock()
        events.removeAll()
        lock.unlock()
    }
}

// MARK: - Demo View

struct LogDemoView: View {
    @State private var logger = InMemoryLogger.shared

    var body: some View {
        NavigationStack {
            List {
                Section("Emit Logs") {
                    Button("Debug – User tapped refresh") {
                        logDebug("User tapped refresh")
                    }
                    Button("Info – Sync completed") {
                        logInfo("Sync completed", metadata: ["count": "42"])
                    }
                    Button("Error – Network failure") {
                        logError("Network request failed", metadata: ["statusCode": "500"])
                    }
                    Button("Custom subsystem / category") {
                        logInfo(
                            "Payment processed",
                            subsystem: "Checkout",
                            category: "Payments"
                        )
                    }
                }

                Section("Captured Events (\(logger.events.count))") {
                    ForEach(Array(logger.events.enumerated()), id: \.offset) { _, event in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.level.rawValue.uppercased())
                                .font(.caption.bold())
                                .foregroundStyle(color(for: event.level))
                            Text(event.message)
                                .font(.body)
                            if !event.metadata.isEmpty {
                                Text(event.metadata.map { "\($0.key)=\($0.value)" }.joined(separator: " "))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("PrintUI Demo")
            .toolbar {
                Button("Clear") {
                    logger.clear()
                }
            }
        }
    }

    private func color(for level: LogLevel) -> Color {
        switch level {
        case .debug: .gray
        case .info: .blue
        case .error: .red
        }
    }
}
