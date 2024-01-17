package cache

import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.driver.native.NativeSqliteDriver
import com.funnelmink.crm.FunnelminkCache

actual class FunnelminkSQLCache {
    actual fun createDriver(): SqlDriver {
        return NativeSqliteDriver(FunnelminkCache.Schema, "test.db")
    }
}