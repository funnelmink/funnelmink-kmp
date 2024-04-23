package cache

import com.funnelmink.crm.FunnelminkCache
import models.*


class Database(databaseDriverFactory: DatabaseDriver) {
    private val database = FunnelminkCache(databaseDriverFactory.createDriver())
    private val accountDB = database.accountQueries
    private val contactDB = database.contactQueries
    private val activityDB = database.activityQueries
    private val caseDB = database.caseRecordQueries
    private val funnelStageDB = database.funnelStageQueries
    private val leadDB = database.leadQueries
    private val opportunityDB = database.opportunityQueries
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
            account.name,
            account.email,
            account.phone,
            account.latitude?.toString(),
            account.longitude?.toString(),
            account.address,
            account.city,
            account.state,
            account.country,
            account.zip,
            account.notes,
            account.createdAt,
            account.updatedAt,
            account.leadID
        )
    }

    @Throws(Exception::class)
    fun selectAccount(id: String): Account? {
        val cached = accountDB.selectAccountById(id).executeAsOneOrNull() ?: return null
        return mapAccount(
            cached.id,
            cached.name,
            cached.email,
            cached.phone,
            cached.latitude,
            cached.longitude,
            cached.address,
            cached.city,
            cached.state,
            cached.country,
            cached.zip,
            cached.notes,
            cached.createdAt,
            cached.updatedAt,
            cached.leadID
        )
    }

    @Throws(Exception::class)
    fun selectAllAccounts(): List<Account> {
        return accountDB.selectAllAccountsInfo(::mapAccount).executeAsList()
    }

    @Throws(Exception::class)
    fun updateAccount(account: Account) {
        accountDB.updateAccount(
            account.name,
            account.email,
            account.phone,
            account.latitude?.toString(),
            account.longitude?.toString(),
            account.address,
            account.city,
            account.state,
            account.country,
            account.zip,
            account.notes,
            account.createdAt,
            account.updatedAt,
            account.leadID,
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
        name: String,
        email: String,
        phone: String,
        latitude: String?,
        longitude: String?,
        address: String,
        city: String,
        state: String,
        country: String,
        zip: String,
        notes: String,
        createdAt: String,
        updatedAt: String,
        leadID: String?
    ): Account {
        return Account(
            id,
            name,
            email,
            phone,
            latitude?.toDoubleOrNull(),
            longitude?.toDoubleOrNull(),
            address,
            city,
            state,
            country,
            zip,
            notes,
            createdAt,
            updatedAt,
            leadID,
            emptyList(),
            emptyList(),
            emptyList(),
            emptyList()
        )
    }

    // ------------------------------------------------------------------------
    // Contact
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    fun insertContact(contact: Contact) {
        contactDB.insertContact(
            contact.id,
            contact.name,
            contact.email,
            contact.phone,
            contact.jobTitle,
            contact.notes,
            contact.accountName,
            contact.accountID

        )
    }

    @Throws(Exception::class)
    fun selectAllContactsForAccount(id: String): List<Contact> {
        return contactDB.selectAllContactsForAccount(id).executeAsList().map { mapContact(it.id, it.name, it.email, it.phone, it.jobTitle, it.notes, it.accountName, it.accountID) }
    }

    @Throws(Exception::class)
    fun updateContact(contact: Contact) {
        contactDB.updateContact(
            contact.name,
            contact.email,
            contact.phone,
            contact.jobTitle,
            contact.notes,
            contact.accountName,
            contact.id
        )
    }

    @Throws(Exception::class)
    fun replaceAllContactsForAccount(id: String, contacts: List<Contact>) {
        contactDB.transaction {
            contactDB.removeAllContactsForAccount(id)
            contacts.forEach(::insertContact)
        }
    }

    @Throws(Exception::class)
    fun replaceContact(contact: Contact) {
        contactDB.transaction {
            contactDB.removeContact(contact.id)
            insertContact(contact)
        }
    }

    @Throws(Exception::class)
    fun deleteContact(id: String) {
        contactDB.removeContact(id)
    }

    @Throws(Exception::class)
    private fun deleteAllContacts() {
        contactDB.removeAllContacts()
    }

    private fun mapContact(
        id: String,
        name: String,
        email: String,
        phone: String,
        jobTitle: String,
        notes: String,
        accountName: String?,
        accountID: String
    ): Contact {
        return Contact(id, name, email, phone, jobTitle, notes, accountName, accountID)
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
    private fun mapActivity(id: String, createdAt: String, details: String, memberID: String, type: String, recordID: String): ActivityRecord {
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
    fun insertCase(case: CaseRecord) {
        caseDB.insertCase(
            case.id,
            case.name,
            case.closedDate,
            case.createdAt,
            case.description,
            case.notes,
            case.priority.toLong(),
            case.updatedAt,
            case.value.toString(),
            case.stageID,
            case.stageName,
            case.accountName,
            case.accountID,
            case.assignedToID,
            case.assignedToName
        )
    }

    @Throws(Exception::class)
    fun replaceCase(case: CaseRecord) {
        caseDB.transaction {
            caseDB.removeCase(case.id)
            insertCase(case)
        }
    }

    @Throws(Exception::class)
    fun selectCase(id: String): CaseRecord? {
        val cached = caseDB.selectCaseById(id).executeAsOneOrNull() ?: return null
        return mapCase(
            cached.id,
            cached.name,
            cached.closedDate,
            cached.createdAt,
            cached.description,
            cached.notes,
            cached.priority.toInt(),
            cached.updatedAt,
            cached.value_.toDouble(),
            cached.stageID,
            cached.stageName,
            cached.accountName,
            cached.accountID,
            cached.assignedToID,
            cached.assignedToName
        )
    }

    @Throws(Exception::class)
    fun selectAllCasesForAccount(id: String): List<CaseRecord> {
        return caseDB.selectAllCasesForAccount(id).executeAsList().map {
            mapCase(
                it.id,
                it.name,
                it.closedDate,
                it.createdAt,
                it.description,
                it.notes,
                it.priority.toInt(),
                it.updatedAt,
                it.value_.toDouble(),
                it.stageID,
                it.stageName,
                it.accountName,
                it.accountID,
                it.assignedToID,
                it.assignedToName
            )

        }
    }

    @Throws(Exception::class)
    fun updateCase(case: CaseRecord) {
        caseDB.updateCase(
            case.name,
            case.closedDate,
            case.description,
            case.notes,
            case.priority.toLong(),
            case.updatedAt,
            case.value.toString(),
            case.stageID,
            case.stageName,
            case.accountName,
            case.accountID,
            case.assignedToID,
            case.assignedToName,
            case.id
        )
    }

    @Throws(Exception::class)
    fun replaceAllCasesForAccount(id: String, cases: List<CaseRecord>) {
        caseDB.transaction {
            caseDB.removeAllCasesForAccount(id)
            cases.forEach { insertCase(it) }
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
        name: String,
        closedDate: String?,
        createdAt: String,
        description: String,
        notes: String,
        priority: Int,
        updatedAt: String,
        value: Double,
        stageID: String,
        stageName: String?,
        accountName: String?,
        accountID: String,
        assignedToID: String?,
        assignedToName: String?
    ): CaseRecord {
        return CaseRecord(
            id,
            name,
            closedDate,
            createdAt,
            description,
            notes,
            priority,
            updatedAt,
            value,
            emptyList(),
            stageID,
            stageName,
            accountName,
            accountID,
            assignedToID,
            assignedToName
        )
    }


    // ------------------------------------------------------------------------
    // Funnel Stages
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    fun insertFunnelStage(stage: FunnelStage) {
        funnelStageDB.insertFunnelStage(
            stage.id,
            stage.name,
            stage.order.toLong(),
        )
    }

    @Throws(Exception::class)
    fun replaceFunnelStage(stage: FunnelStage) {
        funnelStageDB.transaction {
            val cached = funnelStageDB.selectStage(stage.id).executeAsOneOrNull()
            funnelStageDB.deleteFunnelStage(stage.id)
        }
    }

    @Throws(Exception::class)
    fun deleteFunnelStage(id: String) {
        funnelStageDB.deleteFunnelStage(id)
    }

    @Throws(Exception::class)
    fun deleteAllFunnelStages() {
        funnelStageDB.deleteAllStages()
    }

    private fun mapFunnelStage(id: String, name: String, order: Int): FunnelStage {
        return FunnelStage(id, name, order)
    }

    // ------------------------------------------------------------------------
    // Opportunities
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    fun insertOpportunity(opportunity: Opportunity) {
        opportunityDB.insertOpportunity(
            opportunity.id,
            opportunity.closedDate,
            opportunity.createdAt,
            opportunity.description,
            opportunity.name,
            opportunity.notes,
            opportunity.priority.toLong(),
            opportunity.updatedAt,
            opportunity.value.toString(),
            opportunity.stageID,
            opportunity.stageName,
            opportunity.accountName,
            opportunity.accountID,
            opportunity.assignedToID,
            opportunity.assignedToName
        )
    }

    @Throws(Exception::class)
    fun replaceOpportunity(opportunity: Opportunity) {
        opportunityDB.transaction {
            opportunityDB.deleteOpportunity(opportunity.id)
            insertOpportunity(opportunity)
        }
    }

    @Throws(Exception::class)
    fun selectAllOpportunitiesForAccount(id: String): List<Opportunity> {
        return opportunityDB.getAllOpportunitiesForAccount(id).executeAsList().map {
            mapOpportunity(
                it.id,
                it.closedDate,
                it.createdAt,
                it.description,
                it.name,
                it.notes,
                it.priority,
                it.updatedAt,
                it.value_,
                it.stageID,
                it.stageName,
                it.accountName,
                it.accountID,
                it.assignedToID,
                it.assignedToName
            )
        }
    }

    @Throws(Exception::class)
    fun selectOpportunity(id: String): Opportunity? {
        val cached = opportunityDB.getOpportunity(id).executeAsOneOrNull() ?: return null
        return mapOpportunity(
            cached.id,
            cached.closedDate,
            cached.createdAt,
            cached.description,
            cached.name,
            cached.notes,
            cached.priority,
            cached.updatedAt,
            cached.value_,
            cached.stageID,
            cached.stageName,
            cached.accountName,
            cached.accountID,
            cached.assignedToID,
            cached.assignedToName
        )
    }

    private fun mapOpportunity(
        id: String,
        closedDate: String?,
        createdAt: String,
        description: String,
        name: String,
        notes: String,
        priority: Long,
        updatedAt: String,
        value: String?,
        stageID: String,
        stageName: String?,
        accountName: String?,
        accountID: String,
        assignedToID: String?,
        assignedToName: String?
    ): Opportunity {
        return Opportunity(
            id,
            closedDate,
            createdAt,
            description,
            name,
            notes,
            priority.toInt(),
            updatedAt,
            value?.toDouble() ?: 0.0,
            emptyList(),
            stageID,
            stageName,
            accountName,
            accountID,
            assignedToID,
            assignedToName
        )
    }

    @Throws(Exception::class)
    fun updateOpportunity(opportunity: Opportunity) {
        opportunityDB.updateOpportunity(
            opportunity.closedDate,
            opportunity.description,
            opportunity.name,
            opportunity.notes,
            opportunity.priority.toLong(),
            opportunity.updatedAt,
            opportunity.value.toString(),
            opportunity.stageID,
            opportunity.stageName,
            opportunity.accountName,
            opportunity.accountID,
            opportunity.assignedToID,
            opportunity.assignedToName,
            opportunity.id
        )
    }

    @Throws(Exception::class)
    fun deleteOpportunity(id: String) {
        opportunityDB.deleteOpportunity(id)
    }

    @Throws(Exception::class)
    private fun deleteAllOpportunities() {
        opportunityDB.removeAllOpportunities()
    }

    // ------------------------------------------------------------------------
    // Tasks
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    fun insertTask(task: TaskRecord) {
        taskDB.insertTask(
            task.id,
            task.title,
            task.body,
            toLong(task.isComplete),
            task.priority.toLong(),
            task.date,
            task.time,
            task.duration?.toLong(),
            task.visibility.name,
            task.updatedAt,
            task.assignedToID
        )
    }

    @Throws(Exception::class)
    fun selectTask(id: String): TaskRecord? {
        val cached = taskDB.selectTaskById(id).executeAsOneOrNull() ?: return null

        return mapTask(
            cached.id,
            cached.title,
            cached.body,
            cached.isComplete,
            cached.priority,
            cached.date,
            cached.time,
            cached.duration,
            cached.visibility,
            cached.updatedAt,
            cached.assignedToID
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
        title: String,
        body: String,
        isComplete: Long,
        priority: Long,
        date: String?,
        time: String?,
        duration: Long?,
        visibility: String,
        updatedAt: String,
        assignedToID: String?
    ): TaskRecord {
        return TaskRecord(
            id,
            title,
            body,
            toBool(isComplete),
            priority.toInt(),
            date,
            time,
            duration?.toInt(),
            RecordVisibility.valueOf(visibility),
            updatedAt,
            assignedToID
        )
    }

    // ------------------------------------------------------------------------
    // Leads
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    fun insertLead(lead: Lead) {
        leadDB.insertLead(
            lead.id,
            lead.name,
            lead.email,
            lead.phone,
            lead.latitude,
            lead.longitude,
            lead.address,
            lead.city,
            lead.state,
            lead.country,
            lead.zip,
            lead.notes,
            lead.createdAt,
            lead.updatedAt,
            lead.closedDate,
            lead.closedResult?.resultName,
            lead.accountID,
            lead.company,
            lead.jobTitle,
            lead.priority.toLong(),
            lead.source,
            lead.stageID,
            lead.stageName,
            lead.assignedToID,
            lead.assignedToName
        )
    }

    @Throws(Exception::class)
    fun selectLead(id: String): Lead? {
        val cached = leadDB.getLead(id).executeAsOneOrNull() ?: return null
        return mapLead(
            cached.id,
            cached.name,
            cached.email,
            cached.phone,
            cached.latitude,
            cached.longitude,
            cached.address,
            cached.city,
            cached.state,
            cached.country,
            cached.zip,
            cached.notes,
            cached.createdAt,
            cached.updatedAt,
            cached.closedDate,
            cached.closedResult,
            cached.accountID,
            cached.company,
            cached.jobTitle,
            cached.priority,
            cached.source,
            cached.stageID,
            cached.stageName,
            cached.assignedToID,
            cached.assignedToName
        )
    }

    @Throws(Exception::class)
    fun selectAllLeads(): List<Lead> {
        return leadDB.getAllLeads(::mapLead).executeAsList()
    }

    @Throws(Exception::class)
    fun updateLead(lead: Lead) {
        leadDB.updateLead(
            lead.name,
            lead.email,
            lead.phone,
            lead.latitude,
            lead.longitude,
            lead.address,
            lead.city,
            lead.state,
            lead.country,
            lead.zip,
            lead.notes,
            lead.createdAt,
            lead.updatedAt,
            lead.closedDate,
            lead.closedResult?.resultName,
            lead.accountID,
            lead.company,
            lead.jobTitle,
            lead.priority.toLong(),
            lead.source,
            lead.stageID,
            lead.stageName,
            lead.assignedToID,
            lead.assignedToName,
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
        name: String,
        email: String,
        phone: String,
        latitude: Double?,
        longitude: Double?,
        address: String,
        city: String,
        state: String,
        country: String,
        zip: String,
        notes: String,
        createdAt: String,
        updatedAt: String,
        closedDate: String?,
        closedResult: String?,
        accountID: String?,
        company: String,
        jobTitle: String,
        priority: Long,
        source: String,
        stageID: String,
        stageName: String?,
        assignedToID: String?,
        assignedToName: String?
    ): Lead {
        return Lead(
            id,
            name,
            email,
            phone,
            latitude,
            longitude,
            address,
            city,
            state,
            country,
            zip,
            notes,
            createdAt,
            updatedAt,
            closedDate,
            closedResult?.let { LeadClosedResult.valueOf(it) },
            accountID,
            company,
            jobTitle,
            priority.toInt(),
            source,
            emptyList(),
            stageID,
            stageName,
            assignedToID,
            assignedToName
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
            workspace.memberID,
            workspace.name,
            workspace.roles.joinToString { it.name },
            workspace.avatarURL
        )
    }

    @Throws(Exception::class)
    fun selectWorkspaceById(id: String): Workspace? {
        val cached = workspaceDB.selectWorkspaceById(id).executeAsOneOrNull() ?: return null
        return mapWorkspace(cached.id, cached.memberID, cached.name, cached.roles, cached.avatarURL)
    }

    @Throws(Exception::class)
    fun selectAllWorkspaces(): List<Workspace> {
        return workspaceDB.selectAllWorkspacesInfo(::mapWorkspace).executeAsList()
    }

    @Throws(Exception::class)
    fun updateWorkspace(workspace: Workspace) {
        workspaceDB.updateWorkspace(
            workspace.name,
            workspace.memberID,
            workspace.roles.joinToString { it.name },
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

    private fun mapWorkspace(id: String, memberID: String, name: String, roles: String, avatarURL: String?): Workspace {
        return Workspace(
            id,
            memberID,
            name,
            roles.split(",").map { WorkspaceMembershipRole.valueOf(it.trim()) },
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
            member.roles.joinToString { it.name },
        )
    }

    @Throws(Exception::class)
    fun selectAllWorkspaceMembers(): List<WorkspaceMember> {
        return workspaceMemberDB.selectAllWorkspaceMembersInfo(::mapWorkspaceMember).executeAsList()
    }

    @Throws(Exception::class)
    fun changeWorkspaceMemberRoles(userID: String, roles: List<WorkspaceMembershipRole>) {
        workspaceMemberDB.changeWorkspaceMemberRoles(
            roles.joinToString { it.name },
            userID
        )
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

    private fun mapWorkspaceMember(id: String, userID: String, username: String, roles: String): WorkspaceMember {
        return WorkspaceMember(
            id,
            userID,
            username,
            roles.split(",").map { WorkspaceMembershipRole.valueOf(it.trim()) }
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
        deleteAllFunnelStages()
        deleteAllLeads()
        deleteAllOpportunities()
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