package cache

import com.funnelmink.crm.FunnelminkCache
import models.*


internal class Database(databaseDriverFactory: DatabaseDriver) {
    private val database = FunnelminkCache(databaseDriverFactory.createDriver())
    private val accountDB = database.accountQueries
    private val accountContactDB = database.accountContactQueries
    private val activityDB = database.activityQueries
    private val caseDB = database.caseRecordQueries
    private val funnelsDB = database.funnelQueries
    private val funnelStageDB = database.funnelStageQueries
    private val leadDB = database.leadQueries
    private val taskDB = database.scheduleTaskQueries
    private val userDB = database.userQueries
    private val workspaceDB = database.workspaceQueries
    private val workspaceMemberDB = database.workspaceMemberQueries

    // ------------------------------------------------------------------------
    // Accounts
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    fun insertAccount(account: Account) {
        accountDB.insertAccount(
            account.id,
            account.address,
            account.city,
            account.country,
            account.createdAt,
            account.email,
            account.latitude?.toString(),
            account.leadID,
            account.longitude?.toString(),
            account.name,
            account.notes,
            account.phone,
            account.state,
            account.type.typeName,
            account.updatedAt,
            account.zip
        )
    }

    @Throws(Exception::class)
    fun selectAccount(id: String): Account? {
        val cached = accountDB.selectAccountById(id).executeAsOneOrNull() ?: return null
        return mapAccount(
            cached.id,
            cached.address,
            cached.city,
            cached.country,
            cached.createdAt,
            cached.email,
            cached.latitude,
            cached.leadID,
            cached.longitude,
            cached.name,
            cached.notes,
            cached.phone,
            cached.state,
            cached.type,
            cached.updatedAt,
            cached.zip
        )
    }

    @Throws(Exception::class)
    fun selectAllAccounts(): List<Account> {
        return accountDB.selectAllAccountsInfo(::mapAccount).executeAsList()
    }

    @Throws(Exception::class)
    fun updateAccount(account: Account) {
        accountDB.updateAccount(
            account.address,
            account.city,
            account.country,
            account.createdAt,
            account.email,
            account.latitude?.toString(),
            account.leadID,
            account.longitude?.toString(),
            account.name,
            account.notes,
            account.phone,
            account.state,
            account.type.typeName,
            account.updatedAt,
            account.zip,
            account.id
        )
    }

    @Throws(Exception::class)
    fun deleteAccount(id: String) {
        accountDB.removeAccount(id)
    }

    @Throws(Exception::class)
    fun replaceAllAccounts(accounts: List<Account>) {
        deleteAllAccounts()
        accounts.forEach(::insertAccount)
    }

    @Throws(Exception::class)
    private fun deleteAllAccounts() {
        accountDB.removeAllAccounts()
    }

    private fun mapAccount(
        id: String,
        address: String?,
        city: String?,
        country: String?,
        createdAt: String,
        email: String?,
        latitude: String?,
        leadID: String?,
        longitude: String?,
        name: String?,
        notes: String?,
        phone: String?,
        state: String?,
        type: String,
        updatedAt: String,
        zip: String?
    ): Account {
        return Account(
            id,
            address,
            city,
            country,
            createdAt,
            email,
            latitude?.toDouble(),
            leadID,
            longitude?.toDouble(),
            name,
            notes,
            phone,
            state,
            AccountType.fromTypeName(type),
            updatedAt,
            zip
        )
    }

    // ------------------------------------------------------------------------
    // Account Contact
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    fun insertAccountContact(contact: AccountContact, accountID: String) {
        accountContactDB.insertContact(
            contact.id,
            contact.email,
            contact.name,
            contact.notes,
            contact.phone,
            accountID
        )
    }

    @Throws(Exception::class)
    fun selectAllContactsForAccount(id: String): List<AccountContact> {
        return accountContactDB.selectAllContactsForAccount(id).executeAsList().map { mapContact(it.id, it.email, it.name, it.notes, it.phone, id)}
    }

    @Throws(Exception::class)
    fun updateAccountContact(contact: AccountContact) {
        accountContactDB.updateContact(
            contact.email,
            contact.name,
            contact.notes,
            contact.phone,
            contact.id
        )
    }

    @Throws(Exception::class)
    fun replaceAllContactsForAccount(id: String, contacts: List<AccountContact>) {
        accountContactDB.transaction {
            accountContactDB.removeAllContactsForAccount(id)
            contacts.forEach { insertAccountContact(it, id) }
        }
    }

    @Throws(Exception::class)
    fun deleteContact(id: String) {
        accountContactDB.removeContact(id)
    }

    @Throws(Exception::class)
    private fun deleteAllContacts() {
        accountContactDB.removeAllContacts()
    }

    private fun mapContact(id: String, email: String?, name: String?, notes: String?, phone: String?, accountID: String): AccountContact {
        return AccountContact(id, email, name, notes, phone)
    }

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
    // Cases
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    fun insertCase(case: CaseRecord, funnelID: String?, accountID: String?) {
        caseDB.insertCase(
            case.id,
            case.assignedTo,
            case.closedDate,
            case.createdAt,
            case.description,
            case.name,
            case.notes,
            case.priority.toLong(),
            case.stage,
            case.updatedAt,
            case.value.toString(),
            funnelID,
            accountID
        )
    }

    @Throws(Exception::class)
    fun replaceCase(case: CaseRecord) {
        caseDB.transaction {
            val cached = caseDB.selectCaseById(case.id).executeAsOneOrNull()
            caseDB.removeCase(case.id)
            insertCase(case, cached?.funnelId, cached?.accountId)
        }
    }

    @Throws(Exception::class)
    fun selectAllCasesForAccount(id: String): List<CaseRecord> {
        return caseDB.selectAllCasesForAccount(id).executeAsList().map {
            mapCase(
                it.id,
                it.assignedTo,
                it.closedDate,
                it.createdAt,
                it.description,
                it.name,
                it.notes,
                it.priority.toInt(),
                it.stage,
                it.updatedAt,
                it.value_?.toDouble() ?: 0.0
            )

        }
    }

    @Throws(Exception::class)
    fun selectAllCasesForFunnel(id: String): List<CaseRecord> {
        return caseDB.selectAllCasesForFunnel(id).executeAsList().map {
            mapCase(
                it.id,
                it.assignedTo,
                it.closedDate,
                it.createdAt,
                it.description,
                it.name,
                it.notes,
                it.priority.toInt(),
                it.stage,
                it.updatedAt,
                it.value_?.toDouble() ?: 0.0
            )
        }
    }

    @Throws(Exception::class)
    fun updateCase(case: CaseRecord) {
        caseDB.updateCase(
            case.assignedTo,
            case.closedDate,
            case.createdAt,
            case.description,
            case.name,
            case.notes,
            case.priority.toLong(),
            case.stage,
            case.updatedAt,
            case.value.toString(),
            case.id
        )
    }

    @Throws(Exception::class)
    fun replaceAllCasesForAccount(id: String, cases: List<CaseRecord>) {
        caseDB.transaction {
            caseDB.removeAllCasesForAccount(id)
            cases.forEach { insertCase(it, null, id) }
        }
    }

    @Throws(Exception::class)
    fun replaceAllCasesForFunnel(id: String, cases: List<CaseRecord>) {
        caseDB.transaction {
            caseDB.removeAllCasesForFunnel(id)
            cases.forEach { insertCase(it, id, null) }
        }
    }

    @Throws(Exception::class)
    fun deleteCase(id: String) {
        caseDB.removeCase(id)
    }

    @Throws(Exception::class)
    private fun deleteAllCases() {
        caseDB.removeAllCases()
    }

    private fun mapCase(
        id: String,
        assignedTo: String?,
        closedDate: String?,
        createdAt: String,
        description: String?,
        name: String,
        notes: String?,
        priority: Int,
        stage: String?,
        updatedAt: String,
        value: Double
    ): CaseRecord {
        return CaseRecord(
            id,
            assignedTo,
            closedDate,
            createdAt,
            description,
            name,
            notes,
            priority,
            stage,
            updatedAt,
            value
        )
    }

    // ------------------------------------------------------------------------
    // Funnels
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    fun insertFunnel(funnel: Funnel) {
        funnelsDB.insertFunnel(
            funnel.id,
            funnel.name,
            funnel.type.typeName
        )
    }

    @Throws(Exception::class)
    fun replaceFunnel(funnel: Funnel) {
        funnelsDB.transaction {
            funnelsDB.removeFunnel(funnel.id)
            insertFunnel(funnel)
        }
    }

    @Throws(Exception::class)
    fun selectFunnel(id: String): Funnel? {
        val cached = funnelsDB.selectFunnel(id).executeAsOneOrNull() ?: return null
        return mapFunnel(cached.id, cached.name, cached.type)
    }

    @Throws(Exception::class)
    fun selectAllFunnels(): List<Funnel> {
        return funnelsDB.selectAllFunnels(::mapFunnel).executeAsList()
    }

    @Throws(Exception::class)
    fun updateFunnel(funnel: Funnel) {
        funnelsDB.updateFunnel(
            funnel.name,
            funnel.type.typeName,
            funnel.id
        )
    }

    @Throws(Exception::class)
    fun deleteFunnel(id: String) {
        funnelsDB.removeFunnel(id)
    }

    @Throws(Exception::class)
    fun replaceAllFunnels(funnels: List<Funnel>) {
        funnelsDB.transaction {
            funnelsDB.removeAllFunnels()
            funnels.forEach(::insertFunnel)
        }
    }

    @Throws(Exception::class)
    private fun deleteAllFunnels() {
        funnelsDB.removeAllFunnels()
    }

    private fun mapFunnel(id: String, name: String, type: String): Funnel {
        return Funnel(
            id,
            name,
            FunnelType.fromTypeName(type)
        )
    }

    // ------------------------------------------------------------------------
    // Funnel Stages
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    fun insertFunnelStage(stage: FunnelStage, funnelID: String) {
        funnelStageDB.insertFunnelStage(
            stage.id,
            funnelID,
            stage.name,
            stage.order.toLong(),
        )
    }

    @Throws(Exception::class)
    fun replaceFunnelStage(stage: FunnelStage) {
        funnelStageDB.transaction {
            val cached = funnelStageDB.selectStage(stage.id).executeAsOneOrNull()
            funnelStageDB.deleteFunnelStage(stage.id)
            cached?.funnelId?.let { insertFunnelStage(stage, it) }
        }
    }

    @Throws(Exception::class)
    fun deleteAllFunnelStagesForFunnel(id: String) {
        funnelStageDB.deleteAllStagesForFunnel(id)
    }

    @Throws(Exception::class)
    fun deleteFunnelStage(id: String) {
        funnelStageDB.deleteFunnelStage(id)
    }

    @Throws(Exception::class)
    fun deleteAllFunnelStages() {
        funnelStageDB.deleteAllStages()
    }

    // ------------------------------------------------------------------------
    // Tasks
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    fun insertTask(task: TaskRecord) {
        taskDB.insertTask(
            task.id,
            task.body,
            toLong(task.isComplete),
            task.priority.toLong(),
            task.scheduledDate,
            task.title,
            task.updatedAt
        )
    }

    @Throws(Exception::class)
    fun selectTask(id: String): TaskRecord? {
        val cached = taskDB.selectTaskById(id).executeAsOneOrNull() ?: return null

        return mapTask(
            cached.id,
            cached.body,
            cached.isComplete,
            cached.priority,
            cached.scheduledDate,
            cached.title,
            cached.updatedAt
        )
    }

    @Throws(Exception::class)
    fun selectAllCompleteTasks(): List<TaskRecord> {
        return taskDB.selectAllCompleteTasks(::mapTask).executeAsList()
    }

    @Throws(Exception::class)
    fun selectAllIncompleteTasks(): List<TaskRecord> {
        return taskDB.selectAllIncompleteTasks(::mapTask).executeAsList()
    }

    @Throws(Exception::class)
    fun replaceAllCompleteTasks(tasks: List<TaskRecord>) {
        taskDB.transaction {
            taskDB.deleteAllCompleteTasks()
            tasks.forEach(::insertTask)
        }
    }

    @Throws(Exception::class)
    fun replaceAllIncompleteTasks(tasks: List<TaskRecord>) {
        taskDB.transaction {
            taskDB.deleteAllIncompleteTasks()
            tasks.forEach(::insertTask)
        }
    }

    @Throws(Exception::class)
    fun replaceTask(task: TaskRecord) {
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
        taskDB.removeAllTasks()
    }

    private fun mapTask(
        id: String,
        body: String?,
        isComplete: Long,
        priority: Long,
        scheduledDate: String?,
        title: String,
        updatedAt: String
    ): TaskRecord {
        return TaskRecord(
            id,
            body,
            toBool(isComplete),
            priority.toInt(),
            scheduledDate,
            title,
            updatedAt
        )
    }

    // ------------------------------------------------------------------------
    // Leads
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    fun insertLead(lead: Lead) {
        leadDB.insertLead(
            lead.id,
            lead.address,
            lead.assignedTo,
            lead.city,
            lead.closedDate,
            lead.closedResult?.resultName,
            lead.company,
            lead.country,
            lead.createdAt,
            lead.email,
            lead.jobTitle,
            lead.latitude,
            lead.longitude,
            lead.name,
            lead.notes,
            lead.phone,
            lead.priority.toLong(),
            lead.source,
            lead.stage,
            lead.state,
            lead.type.typeName,
            lead.updatedAt,
            lead.zip
        )
    }

    @Throws(Exception::class)
    fun selectLead(id: String): Lead? {
        val cached = leadDB.getLead(id).executeAsOneOrNull() ?: return null
        return mapLead(
            cached.id,
            cached.address,
            cached.assignedTo,
            cached.city,
            cached.closedDate,
            cached.closedResult,
            cached.company,
            cached.country,
            cached.createdAt,
            cached.email,
            cached.jobTitle,
            cached.latitude,
            cached.longitude,
            cached.name.orEmpty(),
            cached.notes,
            cached.phone,
            cached.priority,
            cached.source,
            cached.stage,
            cached.state,
            cached.type,
            cached.updatedAt,
            cached.zip
        )
    }

    @Throws(Exception::class)
    fun selectAllLeads(): List<Lead> {
        return leadDB.getAllLeads(::mapLead).executeAsList()
    }

    @Throws(Exception::class)
    fun updateLead(lead: Lead) {
        leadDB.updateLead(
            lead.address,
            lead.assignedTo,
            lead.city,
            lead.closedDate,
            lead.closedResult?.resultName,
            lead.company,
            lead.country,
            lead.createdAt,
            lead.email,
            lead.jobTitle,
            lead.latitude,
            lead.longitude,
            lead.name,
            lead.notes,
            lead.phone,
            lead.priority.toLong(),
            lead.source,
            lead.stage,
            lead.state,
            lead.type.typeName,
            lead.updatedAt,
            lead.zip,
            lead.id
        )
    }

    @Throws(Exception::class)
    fun deleteLead(id: String) {
        leadDB.deleteLead(id)
    }

    @Throws(Exception::class)
    private fun deleteAllLeads() {
        leadDB.removeAllLeads()
    }

    private fun mapLead(
        id: String,
        address: String?,
        assignedTo: String?,
        city: String?,
        closedDate: String?,
        closedResult: String?,
        company: String?,
        country: String?,
        createdAt: String,
        email: String?,
        jobTitle: String?,
        latitude: Double?,
        longitude: Double?,
        name: String?,
        notes: String?,
        phone: String?,
        priority: Long,
        source: String?,
        stage: String?,
        state: String?,
        type: String,
        updatedAt: String,
        zip: String?
    ): Lead {
        return Lead(
            id,
            address,
            assignedTo,
            city,
            closedDate,
            closedResult?.let { LeadClosedResult.fromResultName(it) },
            company,
            country,
            createdAt,
            email,
            jobTitle,
            latitude,
            longitude,
            name,
            notes,
            phone,
            priority.toInt(),
            source,
            stage,
            state,
            AccountType.fromTypeName(type),
            updatedAt,
            zip
        )
    }

    @Throws(Exception::class)
    fun replaceLead(lead: Lead) {
        leadDB.transaction {
            leadDB.deleteLead(lead.id)
            insertLead(lead)
        }
    }

    @Throws(Exception::class)
    fun replaceAllLeads(leads: List<Lead>) {
        leadDB.transaction {
            leadDB.removeAllLeads()
            leads.forEach(::insertLead)
        }
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
        deleteAllAccounts()
        deleteAllActivities()
        deleteAllCases()
        deleteAllContacts()
        deleteAllFunnels()
        deleteAllFunnelStages()
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