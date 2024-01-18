package cache

import com.funnelmink.crm.FunnelminkCache
import models.Contact
import models.ScheduleTask
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

    fun selectContact(id: String): Contact? {
        val cached = contactDB.selectContactById(id).executeAsOneOrNull() ?: return null
        return mapContact(
            cached.id,
            cached.firstName,
            cached.lastName,
            cached.emails,
            cached.phoneNumbers,
            cached.companyName
        )
    }

    fun selectAllContacts(): List<Contact> {
        return contactDB.selectAllContactsInfo(::mapContact).executeAsList()
    }

    fun updateContact(contact: Contact) {
        contactDB.updateContact(
            contact.firstName,
            contact.lastName,
            contact.emails.joinToString(separator = ","),
            contact.phoneNumbers.joinToString(separator = ","),
            contact.companyName,
            contact.id
        )
    }

    fun deleteAllContacts() {
        contactDB.removeAllContacts()
    }

    private fun mapContact(
        id: String,
        firstName: String,
        lastName: String?,
        emails: String,
        phoneNumbers: String,
        companyName: String?
    ): Contact {
        return Contact(
            id,
            firstName,
            lastName,
            emails.takeIf { it.isNotBlank() }?.split(",") ?: emptyList(),
            phoneNumbers.takeIf { it.isNotBlank() }?.split(",") ?: emptyList(),
            companyName
        )
    }

    // ------------------------------------------------------------------------
    // Tasks
    // ------------------------------------------------------------------------

    fun replaceAllTasks(tasks: List<ScheduleTask>) {
        deleteAllTasks()
        tasks.forEach(::insertTask)
    }

    fun insertTask(task: ScheduleTask) {
        taskDB.insertScheduleTask(
            task.id,
            task.title,
            task.body,
            task.priority.toLong(),
            if (task.isComplete) 1 else 0,
            task.scheduledDate
        )
    }

    fun selectTask(id: String): ScheduleTask? {
        val cached = taskDB.selectScheduleTaskById(id).executeAsOneOrNull() ?: return null

        return mapTask(
            id = cached.id,
            title = cached.title,
            body = cached.body,
            priority = cached.priority,
            isComplete = cached.isComplete,
            scheduledDate = cached.scheduledDate
        )
    }

    fun selectAllTasks(): List<ScheduleTask> {
        return taskDB.selectAllScheduleTasksInfo(::mapTask).executeAsList()
    }

    fun updateTask(task: ScheduleTask) {
        taskDB.updateScheduleTask(
            task.title,
            task.body,
            task.priority.toLong(),
            if (task.isComplete) 1 else 0, // Convert Boolean to Long
            task.scheduledDate,
            task.id
        )
    }

    fun deleteTask(id: String) {
        taskDB.removeTask(id)
    }

    fun deleteAllTasks() {
        taskDB.removeAllScheduleTasks()
    }

    private fun mapTask(
        id: String,
        title: String,
        body: String?,
        priority: Long,
        isComplete: Long,
        scheduledDate: String?
    ): ScheduleTask {
        return ScheduleTask(
            id,
            title,
            body,
            priority.toInt(),
            isComplete != 0L, // Convert Long to Boolean
            scheduledDate
        )
    }

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