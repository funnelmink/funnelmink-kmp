package cache

import com.funnelmink.crm.FunnelminkCache
import models.User


internal class Database(databaseDriverFactory: DatabaseDriver) {
    private val database = FunnelminkCache(databaseDriverFactory.createDriver())
    private val dbQuery = database.userQueries
    
    internal fun clearDatabase() {
        dbQuery.transaction {
            dbQuery.removeAllUsers()
        }
    }
    
    private fun createUser(user: User) {
        // TODO: implement the full database for all types!
    }
    
    internal fun insertUser(user: User) {
        dbQuery.insertUser(user.id, user.email, user.username)
    }
    
    private fun mapUser(id: String, email: String, username: String): User {
        return User(id, username, email)
    }
}