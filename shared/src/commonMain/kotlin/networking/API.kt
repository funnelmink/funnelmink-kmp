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

    // workspaces
    @Throws(Exception::class) suspend fun acceptWorkspaceInvitation(id: String): Workspace
    @Throws(Exception::class) suspend fun declineWorkspaceInvitation(id: String)
    @Throws(Exception::class) suspend fun createWorkspace(body: CreateWorkspaceRequest): Workspace
    @Throws(Exception::class) suspend fun getWorkspaces(): List<Workspace>
    @Throws(Exception::class) suspend fun requestWorkspaceMembership(name: String)


    // ------------------------------------------------------------------------
    // MARK: - Workspace Members-only Endpoints
    // (you need to be signed into a workspace. will fail if `workspaceID == nil`)
    // ------------------------------------------------------------------------

    // accounts
    @Throws(Exception::class) suspend fun getAccounts(): List<Account>
    @Throws(Exception::class) suspend fun createAccount(body: CreateAccountRequest): Account
    @Throws(Exception::class) suspend fun deleteAccount(id: String)
    @Throws(Exception::class) suspend fun getAccountActivities(id: String): List<ActivityRecord>
    @Throws(Exception::class) suspend fun getAccountDetails(id: String): AccountDetailsResponse
    @Throws(Exception::class) suspend fun updateAccount(id: String, body: UpdateAccountRequest): Account

    // activities
    @Throws(Exception::class) suspend fun createActivity(subtype: ActivitySubtype, body: CreateActivityRequest)
    @Throws(Exception::class) suspend fun getActivitiesForRecord(id: String, subtype: ActivitySubtype): List<ActivityRecord>

    // account contacts
    @Throws(Exception::class) suspend fun createAccountContact(accountID: String, body: CreateAccountContactRequest): AccountContact
    @Throws(Exception::class) suspend fun updateAccountContact(accountID: String, id: String, body: UpdateAccountContactRequest): AccountContact
    @Throws(Exception::class) suspend fun deleteAccountContact(accountID: String, id: String)

    // cases
    @Throws(Exception::class) suspend fun assignCaseToMember(id: String, memberID: String): CaseRecord
    @Throws(Exception::class) suspend fun assignCaseToFunnelStage(id: String, stageID: String): CaseRecord
    @Throws(Exception::class) suspend fun createCase(body: CreateCaseRequest): CaseRecord
    @Throws(Exception::class) suspend fun getCase(id: String): CaseRecord
    @Throws(Exception::class) suspend fun updateCase(id: String, body: UpdateCaseRequest): CaseRecord
    @Throws(Exception::class) suspend fun deleteCase(id: String)
    @Throws(Exception::class) suspend fun closeCase(id: String): CaseRecord

    // funnels
    @Throws(Exception::class) suspend fun createDefaultFunnels()
    @Throws(Exception::class) suspend fun getFunnels(): List<Funnel>
    @Throws(Exception::class) suspend fun getFunnelsForType(funnelType: FunnelType): List<Funnel>
    @Throws(Exception::class) suspend fun getFunnel(id: String): Funnel

    // leads
    @Throws(Exception::class) suspend fun assignLeadToMember(id: String, memberID: String): Lead
    @Throws(Exception::class) suspend fun assignLeadToFunnelStage(id: String, stageID: String): Lead
    @Throws(Exception::class) suspend fun getLeads(): List<Lead>
    @Throws(Exception::class) suspend fun getLead(id: String): Lead
    @Throws(Exception::class) suspend fun createLead(body: CreateLeadRequest): Lead
    @Throws(Exception::class) suspend fun updateLead(id: String, body: UpdateLeadRequest): Lead
    @Throws(Exception::class) suspend fun convertLead(id: String, result: LeadClosedResult)
    @Throws(Exception::class) suspend fun deleteLead(id: String)

    // opportunities
    @Throws(Exception::class) suspend fun assignOpportunityToMember(id: String, memberID: String): Opportunity
    @Throws(Exception::class) suspend fun assignOpportunityToFunnelStage(id: String, stageID: String): Opportunity
    @Throws(Exception::class) suspend fun createOpportunity(body: CreateOpportunityRequest): Opportunity
    @Throws(Exception::class) suspend fun getOpportunity(id: String): Opportunity
    @Throws(Exception::class) suspend fun updateOpportunity(id: String, body: UpdateOpportunityRequest): Opportunity
    @Throws(Exception::class) suspend fun deleteOpportunity(id: String)

    // tasks
    @Throws(Exception::class) suspend fun createTask(body: CreateTaskRequest): TaskRecord
    @Throws(Exception::class) suspend fun deleteTask(id: String)
    @Throws(Exception::class) suspend fun getTask(id: String): TaskRecord?
    @Throws(Exception::class) suspend fun getTasks(): List<TaskRecord>
    @Throws(Exception::class) suspend fun getCompletedTasks(): List<TaskRecord>
    @Throws(Exception::class) suspend fun updateTask(id: String, body: UpdateTaskRequest): TaskRecord
    @Throws(Exception::class) suspend fun toggleTaskCompletion(id: String, isComplete: Boolean) : TaskRecord

    // workspaces
    @Throws(Exception::class) suspend fun getWorkspaceMembers(): List<WorkspaceMember>
    @Throws(Exception::class) suspend fun leaveWorkspace()


    // ------------------------------------------------------------------------
    // MARK: - Workspace Owners-only Endpoints
    // (you need to be signed into a workspace and be an owner)
    // ------------------------------------------------------------------------

    // funnels
    @Throws(Exception::class) suspend fun createFunnel(body: CreateFunnelRequest): Funnel
    @Throws(Exception::class) suspend fun updateFunnel(id: String, body: UpdateFunnelRequest): Funnel
    @Throws(Exception::class) suspend fun deleteFunnel(id: String)

    // funnel stages
    @Throws(Exception::class) suspend fun createFunnelStage(funnelID: String, body: CreateFunnelStageRequest): FunnelStage
    @Throws(Exception::class) suspend fun reorderFunnelStages(funnelID: String, body: ReorderFunnelStagesRequest)
    @Throws(Exception::class) suspend fun updateFunnelStage(id: String, body: UpdateFunnelStageRequest): FunnelStage
    @Throws(Exception::class) suspend fun deleteFunnelStage(id: String)

    // workspaces
    @Throws(Exception::class) suspend fun acceptWorkspaceRequest(userID: String)
    @Throws(Exception::class) suspend fun changeWorkspaceRole(userID: String, role: WorkspaceMembershipRole)
    @Throws(Exception::class) suspend fun declineWorkspaceRequest(userID: String)
    @Throws(Exception::class) suspend fun deleteWorkspace(): Workspace
    @Throws(Exception::class) suspend fun inviteUserToWorkspace(email: String)
    @Throws(Exception::class) suspend fun removeMemberFromWorkspace(userID: String)
    @Throws(Exception::class) suspend fun updateWorkspace(body: UpdateWorkspaceRequest): Workspace
}