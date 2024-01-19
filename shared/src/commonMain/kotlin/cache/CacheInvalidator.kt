package cache

import kotlinx.datetime.Clock

class CacheInvalidator(private val threshold: Long) {
    
    private val timestamps = HashMap<String, Long>()

    fun isStale(key: String): Boolean {
        val lastUpdateTime = timestamps[key] ?: return true
        return now() - lastUpdateTime > threshold
    }
    
    fun updateTimestamp(key: String) {
        timestamps[key] = now()
    }
    
    private fun now(): Long {
        return Clock.System.now().epochSeconds
    }

    fun reset() {
        timestamps.clear()
    }
}