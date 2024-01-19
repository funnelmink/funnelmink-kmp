package utilities

import kotlinx.datetime.Clock

enum class LogLevel { INFO, WARN, ERROR }

data class LogEntry(var timestamp: Long = 0, var level: LogLevel = LogLevel.INFO, var message: String = "")

class Logger(private val maxEntries: Int = 1000) {
    private val logEntries = mutableListOf<LogEntry>()

    fun log(level: LogLevel, message: String) {
        if (logEntries.size >= maxEntries) {
            // Remove the oldest 500 entries
            repeat(500) { logEntries.removeAt(0) }
        }
        logEntries.add(LogEntry(Clock.System.now().epochSeconds, level, message))

    }

    fun getLogs(): List<LogEntry> {
        return logEntries.toList()
    }
}
