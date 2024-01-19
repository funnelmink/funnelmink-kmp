package utilities

import kotlinx.datetime.Clock

enum class LogLevel { INFO, WARN, ERROR, VIEW }

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

    fun view(message: String) {
        log(LogLevel.VIEW, message)
    }

    fun log(level: LogLevel = LogLevel.INFO, message: String) {
        println(message)
        if (!isLoggingEnabled) { return }
        if (logEntries.size >= maxEntries) {
            // Remove the oldest 500 entries
            repeat(500) { logEntries.removeAt(0) }
        }
        val entry = LogEntry(Clock.System.now().toEpochMilliseconds(), level, message)
        logEntries.add(entry)
    }

    fun getLogs(): List<LogEntry> {
        return logEntries.toList()
    }

    fun setIsLoggingEnabled(value: Boolean) {
        isLoggingEnabled = value
    }
}
