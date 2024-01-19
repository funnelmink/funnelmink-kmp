package cache

import com.funnelmink.crm.FunnelminkCache
import models.*


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

    private fun deleteAllContacts() {
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
            toLong(task.isComplete),
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
            toLong(task.isComplete),
            task.scheduledDate,
            task.id
        )
    }

    fun deleteTask(id: String) {
        taskDB.removeTask(id)
    }

    private fun deleteAllTasks() {
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
            toBool(isComplete),
            scheduledDate
        )
    }

    // ------------------------------------------------------------------------
    // Users
    // ------------------------------------------------------------------------

    fun replaceUser(user: User) {
        userDB.transaction {
            userDB.removeAllUsers()
            userDB.insertUser(
                user.id,
                user.email,
                user.username,
                toLong(user.isDevAccount)
            )
        }
    }

    fun selectUser(id: String): User? {
        val cached = userDB.selectUserById(id).executeAsOneOrNull() ?: return null
        return mapUser(
            cached.id,
            cached.email,
            cached.username,
            toBool(cached.isDevAccount)
        )
    }

    fun updateUser(user: User) {
        userDB.updateUser(
            user.email,
            user.username,
            toLong(user.isDevAccount),
            user.id
        )
    }

    private fun deleteAllUsers() {
        userDB.removeAllUsers()
    }

    private fun mapUser(id: String, email: String, username: String, isDevAccount: Boolean): User {
        return User(id, username, email, isDevAccount)
    }

    // ------------------------------------------------------------------------
    // Workspaces
    // ------------------------------------------------------------------------

    fun insertWorkspace(workspace: Workspace) {
        workspaceDB.insertWorkspace(
            workspace.id,
            workspace.name,
            workspace.role?.toString(),
            workspace.avatarURL
        )
    }

    fun selectWorkspaceById(id: String): Workspace? {
        val cached = workspaceDB.selectWorkspaceById(id).executeAsOneOrNull() ?: return null
        return mapWorkspace(cached.id, cached.name, cached.role, cached.avatarURL)
    }

    fun selectAllWorkspaces(): List<Workspace> {
        return workspaceDB.selectAllWorkspacesInfo(::mapWorkspace).executeAsList()
    }

    fun updateWorkspace(workspace: Workspace) {
        workspaceDB.updateWorkspace(
            workspace.name,
            workspace.role?.toString(),
            workspace.avatarURL,
            workspace.id
        )
    }

    fun deleteWorkspace(id: String) {
        workspaceDB.removeWorkspace(id)
    }

    private fun deleteAllWorkspaces() {
        workspaceDB.removeAllWorkspaces()
    }

    private fun mapWorkspace(id: String, name: String, role: String?, avatarURL: String?): Workspace {
        return Workspace(
            id,
            name,
            role?.let { WorkspaceMembershipRole.fromRoleName(it) },
            avatarURL
        )
    }

    // ------------------------------------------------------------------------
    // Workspace Members
    // ------------------------------------------------------------------------

    private fun insertWorkspaceMember(member: WorkspaceMember) {
        workspaceMemberDB.insertWorkspaceMember(
            member.id,
            member.userID,
            member.username,
            member.role.toString()
        )
    }

    fun selectAllWorkspaceMembers(): List<WorkspaceMember> {
        return workspaceMemberDB.selectAllWorkspaceMembersInfo(::mapWorkspaceMember).executeAsList()
    }

    fun replaceAllWorkspaceMembers(members: List<WorkspaceMember>) {
        deleteAllWorkspaceMembers()
        members.forEach(::insertWorkspaceMember)
    }

    private fun deleteAllWorkspaceMembers() {
        workspaceMemberDB.removeAllWorkspaceMembers()
    }

    private fun mapWorkspaceMember(id: String, userID: String?, username: String, role: String?): WorkspaceMember {
        return WorkspaceMember(
            id,
            userID,
            username,
            WorkspaceMembershipRole.fromRoleName(role!!)
        )
    }

    // ------------------------------------------------------------------------
    // Utilities
    // ------------------------------------------------------------------------

    fun clearAllDatabases() {
        deleteAllContacts()
        deleteAllTasks()
        deleteAllUsers()
        deleteAllWorkspaces()
        deleteAllWorkspaceMembers()
    }

    /// Retrieve `Long` value from SQLite and turn it back into a `Boolean`
    private fun toBool(long: Long): Boolean {
        return long != 0L
    }

    /// `Boolean` must be stored as `Long` in SQLite
    private fun toLong(bool: Boolean): Long {
        return if (bool) 1 else 0
    }
}