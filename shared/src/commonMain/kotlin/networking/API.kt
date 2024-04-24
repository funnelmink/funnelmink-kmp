package networking

import models.*

/// Endpoints are sorted by access level.
/// Each new access level builds onto the rules from all prior levels.
interface API {
    var onAuthFailure: ((message: String) -> Unit)?
    var onBadRequest: ((message: String) -> Unit)?
    var onDecodingError: ((message: String) -> Unit)?
    var onMissing: ((message: String) -> Unit)?
    var onServerError: ((message: String) -> Unit)?

    @Throws(Exception::class) fun signIn(user: User, token: String)
    @Throws(Exception::class) fun signOut()
    @Throws(Exception::class) fun signIntoWorkspace(workspace: Workspace)
    @Throws(Exception::class) fun signOutOfWorkspace()
    @Throws(Exception::class) fun refreshToken(token: String)
    @Throws(Exception::class) fun getCachedUser(id: String): User?
    @Throws(Exception::class) fun getCachedWorkspace(id: String): Workspace?

    // ------------------------------------------------------------------------
    // MARK: - Auth-Only Endpoints
    // (you only need a firebase account. will fail if `token == nil`)
    // ------------------------------------------------------------------------

    // users
    @Throws(Exception::class) suspend fun createUser(body: CreateUserRequest): User
    @Throws(Exception::class) suspend fun getUserById(userId: String): User
    @Throws(Exception::class) suspend fun getFunnelStages(type: FunnelType): List<FunnelStage>

    // workspaces
    @Throws(Exception::class) suspend fun acceptWorkspaceInvitation(id: String): Workspace
    @Throws(Exception::class) suspend fun declineWorkspaceInvitation(id: String)
    @Throws(Exception::class) suspend fun createWorkspace(body: CreateWorkspaceRequest): Workspace
    @Throws(Exception::class) suspend fun getWorkspaces(): List<Workspace>


    // ------------------------------------------------------------------------
    // MARK: - Workspace Members-only Endpoints
    // (you need to be signed into a workspace. will fail if `workspaceID == nil`)
    // ------------------------------------------------------------------------

    // search
    @Throws(Exception::class) suspend fun search(body: SearchRequest): SearchResult
    @Throws(Exception::class) suspend fun getAssignments(memberID: String): MemberAssignments

    // accounts
    @Throws(Exception::class) suspend fun getAccounts(): List<Account>
    @Throws(Exception::class) suspend fun createAccount(body: CreateAccountRequest): Account
    @Throws(Exception::class) suspend fun getAccountDetails(id: String): Account
    @Throws(Exception::class) suspend fun updateAccount(id: String, body: UpdateAccountRequest): Account
    @Throws(Exception::class) suspend fun deleteAccount(id: String)
    @Throws(Exception::class) suspend fun getAccountActivities(id: String): List<ActivityRecord>

    // activities
    @Throws(Exception::class) suspend fun createActivity(subtype: ActivitySubtype, body: CreateActivityRequest)
    @Throws(Exception::class) suspend fun getActivitiesForRecord(id: String, subtype: ActivitySubtype): List<ActivityRecord>
    @Throws(Exception::class) suspend fun deleteActivity(subtype: ActivitySubtype, id: String)

    // contacts
    @Throws(Exception::class) suspend fun createContact(body: CreateContactRequest): Contact
    @Throws(Exception::class) suspend fun updateContact(id: String, body: UpdateContactRequest): Contact
    @Throws(Exception::class) suspend fun deleteContact(id: String)
    @Throws(Exception::class) suspend fun getContact(id: String): Contact

    // cases
    @Throws(Exception::class) suspend fun assignCaseToMember(id: String, memberID: String): CaseRecord
    @Throws(Exception::class) suspend fun assignCaseToFunnelStage(id: String, stageID: String): CaseRecord
    @Throws(Exception::class) suspend fun getCase(id: String): CaseRecord
    @Throws(Exception::class) suspend fun getCases(): List<CaseRecord>
    @Throws(Exception::class) suspend fun createCase(body: CreateCaseRequest): CaseRecord
    @Throws(Exception::class) suspend fun updateCase(id: String, body: UpdateCaseRequest): CaseRecord
    @Throws(Exception::class) suspend fun deleteCase(id: String)
    @Throws(Exception::class) suspend fun closeCase(id: String, body: RecordClosureRequest): CaseRecord

    // leads
    @Throws(Exception::class) suspend fun assignLeadToMember(id: String, memberID: String): Lead
    @Throws(Exception::class) suspend fun assignLeadToFunnelStage(id: String, stageID: String): Lead
    @Throws(Exception::class) suspend fun getLeads(): List<Lead>
    @Throws(Exception::class) suspend fun getLead(id: String): Lead
    @Throws(Exception::class) suspend fun createLead(body: CreateLeadRequest): Lead
    @Throws(Exception::class) suspend fun updateLead(id: String, body: UpdateLeadRequest): Lead
    @Throws(Exception::class) suspend fun convertLead(id: String, result: LeadClosedResult, body: RecordClosureRequest)
    @Throws(Exception::class) suspend fun deleteLead(id: String)

    // opportunities
    @Throws(Exception::class) suspend fun assignOpportunityToMember(id: String, memberID: String): Opportunity
    @Throws(Exception::class) suspend fun assignOpportunityToFunnelStage(id: String, stageID: String): Opportunity
    @Throws(Exception::class) suspend fun getOpportunity(id: String): Opportunity
    @Throws(Exception::class) suspend fun getOpportunities(): List<Opportunity>
    @Throws(Exception::class) suspend fun createOpportunity(body: CreateOpportunityRequest): Opportunity
    @Throws(Exception::class) suspend fun updateOpportunity(id: String, body: UpdateOpportunityRequest): Opportunity
    @Throws(Exception::class) suspend fun deleteOpportunity(id: String)
    @Throws(Exception::class) suspend fun closeOpportunity(id: String, body: RecordClosureRequest): Opportunity

   // tasks
    @Throws(Exception::class) suspend fun deleteTask(id: String)
    @Throws(Exception::class) suspend fun unlinkRecordFromTask(taskID: String, body: UnlinkRecordRequest)
    @Throws(Exception::class) suspend fun getTasks(): List<TaskRecord>
    @Throws(Exception::class) suspend fun getTask(id: String): TaskRecord
    @Throws(Exception::class) suspend fun getCompletedTasks(): List<TaskRecord>
    @Throws(Exception::class) suspend fun createTask(body: CreateTaskRequest): TaskRecord
    @Throws(Exception::class) suspend fun linkRecordToTask(taskID: String, body: LinkRecordRequest): TaskRecord
    @Throws(Exception::class) suspend fun updateTask(id: String, body: UpdateTaskRequest): TaskRecord
    @Throws(Exception::class) suspend fun toggleTaskCompletion(id: String, isComplete: Boolean) : TaskRecord

    // workspaces
    @Throws(Exception::class) suspend fun getWorkspaceMembers(): List<WorkspaceMember>
    @Throws(Exception::class) suspend fun leaveWorkspace()


    // ------------------------------------------------------------------------
    // MARK: - Workspace Owners-only Endpoints
    // (you need to be signed into a workspace and be an owner)
    // ------------------------------------------------------------------------

    // workspaces
    @Throws(Exception::class) suspend fun changeWorkspaceRoles(userID: String, body: WorkspaceMembershipRolesRequest)
    @Throws(Exception::class) suspend fun deleteWorkspace()
    @Throws(Exception::class) suspend fun inviteUserToWorkspace(email: String, body: WorkspaceMembershipRolesRequest)
    @Throws(Exception::class) suspend fun removeMemberFromWorkspace(userID: String)
    @Throws(Exception::class) suspend fun updateWorkspace(body: UpdateWorkspaceRequest): Workspace
}