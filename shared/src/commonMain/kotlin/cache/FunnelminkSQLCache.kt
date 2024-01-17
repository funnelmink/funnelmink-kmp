package cache

import app.cash.sqldelight.db.SqlDriver

expect class FunnelminkSQLCache {
    fun createDriver(): SqlDriver
}