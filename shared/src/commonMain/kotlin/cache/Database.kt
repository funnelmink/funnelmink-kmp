package cache

import com.funnelmink.crm.FunnelminkCache
import models.Contact
import models.User


internal class Database(databaseDriverFactory: DatabaseDriver) {
    private val database = FunnelminkCache(databaseDriverFactory.createDriver())
    private val contactDB = database.contactQueries
    private val taskDB = database.scheduleTaskQueries
    private val userDB = database.userQueries
    private val workspaceDB = database.workspaceQueries
    private val workspaceMemberDB = database.workspaceMemberQueries


    // ------------------------------------------------------------------------
    // Contacts
    // ------------------------------------------------------------------------

    fun insertContact(contact: Contact) {
        contactDB.insertContact(
            contact.id,
            contact.firstName,
            contact.lastName,
            contact.emails.joinToString(separator = ","),
            contact.phoneNumbers.joinToString(separator = ","),
            contact.companyName
        )
    }

    

    // ------------------------------------------------------------------------
    // Tasks
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // Users
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // Workspaces
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // Workspace Members
    // ------------------------------------------------------------------------
    
    internal fun clearDatabase() {
        userDB.transaction {
            userDB.removeAllUsers()
        }
    }
    
    private fun createUser(user: User) {
        // TODO: implement the full database for all types!
    }
    
    internal fun insertUser(user: User) {
        userDB.insertUser(user.id, user.email, user.username)
    }
    
    private fun mapUser(id: String, email: String, username: String): User {
        return User(id, username, email)
    }
}