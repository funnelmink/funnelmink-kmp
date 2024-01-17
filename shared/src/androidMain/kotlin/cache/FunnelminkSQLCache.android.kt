package cache

import android.content.Context
import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.driver.android.AndroidSqliteDriver
import com.funnelmink.crm.FunnelminkCache

actual class FunnelminkSQLCache(private val context: Context) {
    actual fun createDriver(): SqlDriver {
        return AndroidSqliteDriver(FunnelminkCache.Schema, context, "test.db")
    }

}