package utilities

import kotlinx.datetime.Clock

enum class LogLevel { INFO, WARN, ERROR }

data class LogEntry(var timestamp: Long = 0, var level: LogLevel = LogLevel.INFO, var message: String = "")

class Logger(private val maxEntries: Int = 1000) {
    private var isLoggingEnabled = false
    private val logEntries = mutableListOf<LogEntry>()

    fun info(message: String) {
        log(LogLevel.INFO, message)
    }

    fun warn(message: String) {
        log(LogLevel.WARN, message)
    }

    fun error(message: String) {
        log(LogLevel.ERROR, message)
    }

    fun log(level: LogLevel = LogLevel.INFO, message: String) {
        println(message)
        if (!isLoggingEnabled) { return }
        if (logEntries.size >= maxEntries) {
            // Remove the oldest 500 entries
            repeat(500) { logEntries.removeAt(0) }
        }
        logEntries.add(LogEntry(Clock.System.now().epochSeconds, level, message))
    }

    fun getLogs(): List<LogEntry> {
        return logEntries.toList()
    }

    fun enableLogging() {
        isLoggingEnabled = true
    }
}
