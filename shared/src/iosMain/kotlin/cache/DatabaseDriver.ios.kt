package cache

import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.driver.native.NativeSqliteDriver
import com.funnelmink.crm.FunnelminkCache

actual class DatabaseDriver {
    actual fun createDriver(): SqlDriver {
        return NativeSqliteDriver(FunnelminkCache.Schema, "test.db")
    }
}