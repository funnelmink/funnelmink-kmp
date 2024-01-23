package cache

import com.funnelmink.crm.FunnelminkCache
import models.*


internal class Database(databaseDriverFactory: DatabaseDriver) {
    private val database = FunnelminkCache(databaseDriverFactory.createDriver())
    private val activityDB = database.activityQueries
    private val contactDB = database.contactQueries
    private val taskDB = database.scheduleTaskQueries
    private val userDB = database.userQueries
    private val workspaceDB = database.workspaceQueries
    private val workspaceMemberDB = database.workspaceMemberQueries

    // ------------------------------------------------------------------------
    // Activities
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    fun insertActivityForRecord(activity: ActivityRecord, recordID: String) {
        activityDB.insertActivity(
            activity.id,
            activity.createdAt,
            activity.details,
            activity.memberID,
            activity.type.typeName,
            recordID
        )
    }

    @Throws(Exception::class)
    fun selectAllActivitiesForRecord(id: String): List<ActivityRecord> {
        return activityDB.selectAllActivitiesForRecord(id, ::mapActivity).executeAsList()
    }

    @Throws(Exception::class)
    fun updateActivity(activity: ActivityRecord) {
        activityDB.updateActivityDetails(activity.details, activity.id)
    }

    @Throws(Exception::class)
    fun replaceAllActivitiesForRecord(id: String, activities: List<ActivityRecord>) {
        activityDB.transaction {
            activityDB.removeAllActivitiesForRecord(id)
            activities.forEach { insertActivityForRecord(it, id) }
        }
    }

    @Throws(Exception::class)
    fun deleteActivity(id: String) {
        activityDB.removeActivity(id)
    }

    @Throws(Exception::class)
    private fun mapActivity(id: String, createdAt: String, details: String?, memberID: String, type: String, recordID: String): ActivityRecord {
        return ActivityRecord(id, createdAt, details, memberID, ActivityRecordType.fromTypeName(type))
    }

    @Throws(Exception::class)
    private fun deleteAllActivities() {
        activityDB.removeAllActivities()
    }

    // ------------------------------------------------------------------------
    // Contacts
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    fun insertContact(contact: Contact) {
        contactDB.insertContact(
            contact.id,
            contact.firstName,
            contact.lastName,
            contact.emails.joinToString(separator = ","),
            contact.phoneNumbers.joinToString(separator = ","),
            contact.companyName,
            toLong(contact.isOrganization),
            contact.latitude?.toString(),
            contact.longitude?.toString(),
            contact.street1,
            contact.street2,
            contact.city,
            contact.state,
            contact.country,
            contact.zip
        )
    }

    @Throws(Exception::class)
    fun selectContact(id: String): Contact? {
        val cached = contactDB.selectContactById(id).executeAsOneOrNull() ?: return null
        return mapContact(
            cached.id,
            cached.firstName,
            cached.lastName,
            cached.emails,
            cached.phoneNumbers,
            cached.companyName,
            cached.isOrganization,
            cached.latitude,
            cached.longitude,
            cached.street1,
            cached.street2,
            cached.city,
            cached.state,
            cached.country,
            cached.zip
        )
    }

    @Throws(Exception::class)
    fun selectAllContacts(): List<Contact> {
        return contactDB.selectAllContactsInfo(::mapContact).executeAsList()
    }

    @Throws(Exception::class)
    fun updateContact(contact: Contact) {
        contactDB.updateContact(
            contact.firstName,
            contact.lastName,
            contact.emails.joinToString(separator = ","),
            contact.phoneNumbers.joinToString(separator = ","),
            contact.companyName,
            toLong(contact.isOrganization),
            contact.latitude?.toString(),
            contact.longitude?.toString(),
            contact.street1,
            contact.street2,
            contact.city,
            contact.state,
            contact.country,
            contact.zip,
            contact.id
        )
    }

    @Throws(Exception::class)
    fun deleteContact(id: String) {
        contactDB.removeContact(id)
    }

    @Throws(Exception::class)
    fun replaceAllContacts(contacts: List<Contact>) {
        deleteAllContacts()
        contacts.forEach(::insertContact)
    }

    @Throws(Exception::class)
    private fun deleteAllContacts() {
        contactDB.removeAllContacts()
    }

    private fun mapContact(
        id: String,
        firstName: String,
        lastName: String?,
        emails: String,
        phoneNumbers: String,
        companyName: String?,
        isOrganization: Long,
        latitude: String?,
        longitude: String?,
        street1: String?,
        street2: String?,
        city: String?,
        state: String?,
        country: String?,
        zip: String?
    ): Contact {
        return Contact(
            id,
            firstName,
            lastName,
            emails.takeIf { it.isNotBlank() }?.split(",") ?: emptyList(),
            phoneNumbers.takeIf { it.isNotBlank() }?.split(",") ?: emptyList(),
            companyName,
            toBool(isOrganization),
            latitude?.toDoubleOrNull(),
            longitude?.toDoubleOrNull(),
            street1,
            street2,
            city,
            state,
            country,
            zip
        )
    }

    // ------------------------------------------------------------------------
    // Tasks
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    fun insertTask(task: ScheduleTask) {
        taskDB.insertScheduleTask(
            task.id,
            task.title,
            task.body,
            task.priority.toLong(),
            toLong(task.isComplete),
            task.scheduledDate,
            task.updatedAt
        )
    }

    @Throws(Exception::class)
    fun selectTask(id: String): ScheduleTask? {
        val cached = taskDB.selectScheduleTaskById(id).executeAsOneOrNull() ?: return null

        return mapTask(
            cached.id,
            cached.title,
            cached.body,
            cached.priority,
            cached.isComplete,
            cached.scheduledDate,
            cached.updatedAt
        )
    }

    @Throws(Exception::class)
    fun selectAllCompleteTasks(): List<ScheduleTask> {
        return taskDB.selectAllCompleteTasks(::mapTask).executeAsList()
    }

    @Throws(Exception::class)
    fun selectAllIncompleteTasks(): List<ScheduleTask> {
        return taskDB.selectAllIncompleteTasks(::mapTask).executeAsList()
    }

    @Throws(Exception::class)
    fun replaceAllCompleteTasks(tasks: List<ScheduleTask>) {
        taskDB.transaction {
            taskDB.deleteAllCompleteTasks()
            tasks.forEach(::insertTask)
        }
    }

    @Throws(Exception::class)
    fun replaceAllIncompleteTasks(tasks: List<ScheduleTask>) {
        taskDB.transaction {
            taskDB.deleteAllIncompleteTasks()
            tasks.forEach(::insertTask)
        }
    }

    @Throws(Exception::class)
    fun replaceTask(task: ScheduleTask) {
        taskDB.transaction {
            taskDB.removeTask(task.id)
            insertTask(task)
        }
    }

    @Throws(Exception::class)
    fun deleteTask(id: String) {
        taskDB.removeTask(id)
    }

    @Throws(Exception::class)
    private fun deleteAllTasks() {
        taskDB.removeAllScheduleTasks()
    }

    private fun mapTask(
        id: String,
        title: String,
        body: String?,
        priority: Long,
        isComplete: Long,
        scheduledDate: String?,
        updatedAt: String
    ): ScheduleTask {
        return ScheduleTask(
            id,
            title,
            body,
            priority.toInt(),
            toBool(isComplete),
            scheduledDate,
            updatedAt
        )
    }

    // ------------------------------------------------------------------------
    // Users
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
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

    @Throws(Exception::class)
    fun selectUser(id: String): User? {
        val cached = userDB.selectUserById(id).executeAsOneOrNull() ?: return null
        return mapUser(
            cached.id,
            cached.email,
            cached.username,
            cached.isDevAccount
        )
    }

    @Throws(Exception::class)
    fun selectAllUsersInfo(): List<User> {
        return userDB.selectAllUsersInfo(::mapUser).executeAsList()
    }

    @Throws(Exception::class)
    fun updateUser(user: User) {
        userDB.updateUser(
            user.email,
            user.username,
            toLong(user.isDevAccount),
            user.id
        )
    }

    @Throws(Exception::class)
    private fun deleteAllUsers() {
        userDB.removeAllUsers()
    }

    private fun mapUser(id: String, email: String, username: String, isDevAccount: Long): User {
        return User(id, username, email, toBool(isDevAccount))
    }

    // ------------------------------------------------------------------------
    // Workspaces
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    fun insertWorkspace(workspace: Workspace) {
        workspaceDB.insertWorkspace(
            workspace.id,
            workspace.name,
            workspace.role?.roleName,
            workspace.avatarURL
        )
    }

    @Throws(Exception::class)
    fun selectWorkspaceById(id: String): Workspace? {
        val cached = workspaceDB.selectWorkspaceById(id).executeAsOneOrNull() ?: return null
        return mapWorkspace(cached.id, cached.name, cached.role, cached.avatarURL)
    }

    @Throws(Exception::class)
    fun selectAllWorkspaces(): List<Workspace> {
        return workspaceDB.selectAllWorkspacesInfo(::mapWorkspace).executeAsList()
    }

    @Throws(Exception::class)
    fun updateWorkspace(workspace: Workspace) {
        workspaceDB.updateWorkspace(
            workspace.name,
            workspace.role?.roleName,
            workspace.avatarURL,
            workspace.id
        )
    }

    @Throws(Exception::class)
    fun deleteWorkspace(id: String) {
        workspaceDB.removeWorkspace(id)
    }

    @Throws(Exception::class)
    fun deleteAllWorkspaces() {
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

    @Throws(Exception::class)
    private fun insertWorkspaceMember(member: WorkspaceMember) {
        workspaceMemberDB.insertWorkspaceMember(
            member.id,
            member.userID,
            member.username,
            member.role.roleName
        )
    }

    @Throws(Exception::class)
    fun selectAllWorkspaceMembers(): List<WorkspaceMember> {
        return workspaceMemberDB.selectAllWorkspaceMembersInfo(::mapWorkspaceMember).executeAsList()
    }

    @Throws(Exception::class)
    fun changeWorkspaceMemberRole(userID: String, role: WorkspaceMembershipRole) {
        workspaceMemberDB.changeWorkspaceMemberRole(role.roleName, userID)
    }

    @Throws(Exception::class)
    fun replaceAllWorkspaceMembers(members: List<WorkspaceMember>) {
        deleteAllWorkspaceMembers()
        members.forEach(::insertWorkspaceMember)
    }

    @Throws(Exception::class)
    fun deleteWorkspaceMember(userID: String) {
        workspaceMemberDB.removeWorkspaceMember(userID)
    }

    @Throws(Exception::class)
    private fun deleteAllWorkspaceMembers() {
        workspaceMemberDB.removeAllWorkspaceMembers()
    }

    private fun mapWorkspaceMember(id: String, userID: String, username: String, role: String?): WorkspaceMember {
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

    @Throws(Exception::class)
    fun clearAllDatabases() {
        deleteAllActivities()
        deleteAllContacts()
        deleteAllTasks()
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