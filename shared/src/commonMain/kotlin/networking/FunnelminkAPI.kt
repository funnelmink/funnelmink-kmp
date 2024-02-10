package networking

import cache.*
import models.*
import io.ktor.client.*
import io.ktor.client.plugins.*
import io.ktor.client.plugins.cache.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json
import utilities.*

class FunnelminkAPI(
    private val baseURL: String,
    private val databaseDriver: DatabaseDriver,
    private val cacheThreshold: Long
) : API {
    private var token: String? = null
    private var workspaceID: String? = null
    override var onAuthFailure: ((message: String) -> Unit)? = null
    override var onBadRequest: ((message: String) -> Unit)? = null
    override var onDecodingError: ((message: String) -> Unit)? = null
    override var onMissing: ((message: String) -> Unit)? = null
    override var onServerError: ((message: String) -> Unit)? = null
    private val cache = Database(databaseDriver)
    private val cacheInvalidator = CacheInvalidator(cacheThreshold)

    // ------------------------------------------------------------------------
    // Auth
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    override fun signIn(user: User, token: String) {
        this.token = token
        cache.replaceUser(user)
        Utilities.logger.setIsLoggingEnabled(user.isDevAccount)
    }

    @Throws(Exception::class)
    override fun signOut() {
        signOutOfWorkspace()
        token = null
    }

    @Throws(Exception::class)
    override fun signIntoWorkspace(workspace: Workspace) {
        cache.insertWorkspace(workspace)
        workspaceID = workspace.id
    }

    @Throws(Exception::class)
    override fun signOutOfWorkspace() {
        cache.clearAllDatabases()
        cacheInvalidator.reset()
        workspaceID = null
    }

    @Throws(Exception::class)
    override fun refreshToken(token: String) {
        this.token = token
    }

    @Throws(Exception::class)
    override fun getCachedUser(id: String): User? {
        val user = cache.selectUser(id)
        if (user == null) {
            Utilities.logger.warn("User for $id not found. Dumping users:")
            val users = cache.selectAllUsersInfo()
            users.forEach { Utilities.logger.info("${it.id} - ${it.username}") }
//            Utilities.logger.info("Not signed in. Navigating to LoginView")
        } else {
            Utilities.logger.info("Signing back in as ${user.username}")
        }
        return user
    }

    @Throws(Exception::class)
    override fun getCachedWorkspace(id: String): Workspace? {
        val workspace = cache.selectWorkspaceById(id)
        if (workspace != null) {
            Utilities.logger.info("Signing in to: ${workspace.name}")
        } else {
            Utilities.logger.warn("Workspace for $id not found. Dumping workspaces:")
            val workspaces = cache.selectAllWorkspaces()
            workspaces.forEach { Utilities.logger.info("${it.id} - ${it.name}") }
        }
        return workspace
    }

    // ------------------------------------------------------------------------
    // Accounts
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    override suspend fun createAccount(body: CreateAccountRequest): Account {
        val account: Account = genericRequest("$baseURL/v1/workspace/accounts", HttpMethod.Post) {
            setBody(body)
        }
        cache.insertAccount(account)
        return account
    }

    @Throws(Exception::class)
    override suspend fun deleteAccount(id: String) {
        genericRequest<Unit>("$baseURL/v1/workspace/accounts/$id", HttpMethod.Delete)
        cache.deleteTask(id)
    }

    @Throws(Exception::class)
    override suspend fun getAccountActivities(id: String): List<ActivityRecord> {
        val cacheKey = "getAccountActivities$id"
        try {
            if (!cacheInvalidator.isStale(cacheKey)) {
                val cached = cache.selectAllActivitiesForRecord(id)
                if (cached.isNotEmpty()) {
                    Utilities.logger.info("Retrieved ${cached.size} activities for account $id from cache")
                    return cached
                }
            }
            val fetched: List<ActivityRecord> = genericRequest("$baseURL/v1/activities/account/$id", HttpMethod.Get)
            cache.replaceAllActivitiesForRecord(id, fetched)
            cacheInvalidator.updateTimestamp(cacheKey)
            Utilities.logger.info("Cached ${fetched.size} activities for account $id")
            return fetched
        } catch (e: Exception) {
            val cached = cache.selectAllActivitiesForRecord(id)
            if (cached.isNotEmpty()) {
                Utilities.logger.warn("Failed to fetch Activities. Returned ${cached.size} activities for account $id from cache")
                return cached
            } else {
                throw e
            }
        }
    }

    @Throws(Exception::class)
    override suspend fun getAccountDetails(id: String): Account {
        // this is unused right now
        return genericRequest("$baseURL/v1/workspace/accounts/$id", HttpMethod.Get)
    }

    @Throws(Exception::class)
    override suspend fun getAccounts(): List<Account> {
        val cacheKey = "getAccounts"
        try {
            if (!cacheInvalidator.isStale(cacheKey)) {
                val cached = cache.selectAllAccounts()
                if (cached.isNotEmpty()) {
                    Utilities.logger.info("Retrieved ${cached.size} accounts from cache")
                    return cached
                }
            }
            val fetched: List<Account> = genericRequest("$baseURL/v1/workspace/accounts", HttpMethod.Get)
            cache.replaceAllAccounts(fetched)
            cacheInvalidator.updateTimestamp(cacheKey)
            Utilities.logger.info("Cached ${fetched.size} accounts")
            return fetched
        } catch (e: Exception) {
            val cached = cache.selectAllAccounts()
            if (cached.isNotEmpty()) {
                Utilities.logger.warn("Failed to fetch Accounts. Returned ${cached.size} accounts from cache")
                return cached
            } else {
                throw e
            }
        }
    }

    @Throws(Exception::class)
    override suspend fun updateAccount(id: String, body: UpdateAccountRequest): Account {
        val account: Account = genericRequest("$baseURL/v1/workspace/accounts/$id", HttpMethod.Put) {
            setBody(body)
        }
        cache.updateAccount(account)
        return account
    }

    // ------------------------------------------------------------------------
    // Account Contacts
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    override suspend fun createAccountContact(accountID: String, body: CreateAccountContactRequest): AccountContact {
        val contact: AccountContact = genericRequest("$baseURL/v1/workspace/accounts/$accountID/contacts", HttpMethod.Post) {
            setBody(body)
        }
        cache.insertAccountContact(contact, accountID)
        return contact
    }

    @Throws(Exception::class)
    override suspend fun updateAccountContact(accountID: String, id: String, body: UpdateAccountContactRequest): AccountContact {
        val contact: AccountContact = genericRequest("$baseURL/v1/workspace/accounts/$accountID/contacts/$id", HttpMethod.Put) {
            setBody(body)
        }
        cache.replaceAccountContact(contact, accountID)
        return contact
    }

    @Throws(Exception::class)
    override suspend fun deleteAccountContact(accountID: String, id: String) {
        genericRequest<Unit>("$baseURL/v1/workspace/accounts/$accountID/contacts/$id", HttpMethod.Delete)
        cache.deleteContact(id)
    }

    // ------------------------------------------------------------------------
    // Activities
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    override suspend fun createActivity(subtype: ActivitySubtype, body: CreateActivityRequest) {
        genericRequest<Unit>("$baseURL/v1/activities/${subtype.typeName}", HttpMethod.Post) {
            setBody(body)
        }
    }

    @Throws(Exception::class)
    override suspend fun getActivitiesForRecord(id: String, subtype: ActivitySubtype): List<ActivityRecord> {
        return genericRequest("$baseURL/v1/activities/$subtype/$id", HttpMethod.Get)
    }

    // ------------------------------------------------------------------------
    // Cases
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    override suspend fun assignCaseToMember(id: String, memberID: String): CaseRecord {
        val case: CaseRecord = genericRequest("$baseURL/v1/workspace/cases/$id/assignMember/$memberID", HttpMethod.Put)
        cache.replaceCase(case)
        return case
    }

    @Throws(Exception::class)
    override suspend fun assignCaseToFunnelStage(id: String, stageID: String): CaseRecord {
        val case: CaseRecord = genericRequest("$baseURL/v1/workspace/cases/$id/assignStage/$stageID", HttpMethod.Put)
        cache.replaceCase(case)
        return case
    }

    @Throws(Exception::class)
    override suspend fun createCase(body: CreateCaseRequest, stageID: String, funnelID: String, accountID: String?): CaseRecord {
        val case: CaseRecord = genericRequest("$baseURL/v1/workspace/cases/$funnelID/$stageID", HttpMethod.Post) {
            setBody(body)
            accountID?.let { parameter("accountID", it) }
        }
        cache.insertCase(case, funnelID, accountID)
        return case
    }

    @Throws(Exception::class)
    override suspend fun updateCase(id: String, body: UpdateCaseRequest): CaseRecord {
        val case: CaseRecord = genericRequest("$baseURL/v1/workspace/cases/$id", HttpMethod.Put) {
            setBody(body)
        }
        cache.replaceCase(case)
        return case
    }

    @Throws(Exception::class)
    override suspend fun deleteCase(id: String) {
        genericRequest<Unit>("$baseURL/v1/workspace/cases/$id", HttpMethod.Delete)
        cache.deleteCase(id)
    }

    @Throws(Exception::class)
    override suspend fun closeCase(id: String): CaseRecord {
        val case: CaseRecord = genericRequest("$baseURL/v1/workspace/cases/$id/close", HttpMethod.Put)
        cache.replaceCase(case)
        return case
    }

    // ------------------------------------------------------------------------
    // Funnels
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    override suspend fun getFunnels(): List<Funnel> {
        val cacheKey = "getFunnels"
        try {
            if (!cacheInvalidator.isStale(cacheKey)) {
                val cached = cache.selectAllFunnels()
                if (cached.isNotEmpty()) {
                    Utilities.logger.info("Retrieved ${cached.size} funnels from cache")
                    return cached
                }
            }
            val fetched: List<Funnel> = genericRequest("$baseURL/v1/workspace/funnels", HttpMethod.Get)
            cache.replaceAllFunnels(fetched)
            cacheInvalidator.updateTimestamp(cacheKey)
            Utilities.logger.info("Cached ${fetched.size} funnels")
            return fetched
        } catch (e: Exception) {
            val cached = cache.selectAllFunnels()
            if (cached.isNotEmpty()) {
                Utilities.logger.warn("Failed to fetch Funnels. Returned ${cached.size} funnels from cache")
                return cached
            } else {
                throw e
            }
        }
    }

    @Throws(Exception::class)
    override suspend fun getFunnel(id: String): Funnel {
//        val cached = cache.selectFunnel(id)
//        if (cached != null) {
//            Utilities.logger.info("Returned funnel $id from cache")
//            return cached
//        }
        return genericRequest("$baseURL/v1/workspace/funnels/$id", HttpMethod.Get)
    }

    @Throws(Exception::class)
    override suspend fun getFunnelsForType(funnelType: FunnelType): List<Funnel> {
        return genericRequest("$baseURL/v1/workspace/funnels/${funnelType.typeName}", HttpMethod.Get)
    }

    @Throws(Exception::class)
    override suspend fun createDefaultFunnels() {
        genericRequest<Unit>("$baseURL/v1/workspace/owner/funnels/createDefaultFunnels", HttpMethod.Post) {
            setBody("{}") // POST requests can't have empty bodies
        }
        cacheInvalidator.invalidate("getFunnels")
    }

    @Throws(Exception::class)
    override suspend fun createFunnel(body: CreateFunnelRequest): Funnel {
        val funnel: Funnel = genericRequest("$baseURL/v1/workspace/owner/funnels", HttpMethod.Post) {
            setBody(body)
        }
        cache.insertFunnel(funnel)
        return funnel
    }

    @Throws(Exception::class)
    override suspend fun updateFunnel(id: String, body: UpdateFunnelRequest): Funnel {
        val funnel: Funnel = genericRequest("$baseURL/v1/workspace/owner/funnels/$id", HttpMethod.Put) {
            setBody(body)
        }
        cache.replaceFunnel(funnel)
        return funnel
    }

    @Throws(Exception::class)
    override suspend fun deleteFunnel(id: String) {
        genericRequest<Unit>("$baseURL/v1/workspace/owner/funnels/$id", HttpMethod.Delete)
        cache.deleteFunnel(id)
    }

    // ------------------------------------------------------------------------
    // Funnel Stages
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    override suspend fun createFunnelStage(funnelID: String, body: CreateFunnelStageRequest): FunnelStage {
        val stage: FunnelStage = genericRequest("$baseURL/v1/workspace/owner/funnelstages/$funnelID/", HttpMethod.Post) {
            setBody(body)
        }
        cache.insertFunnelStage(stage, funnelID)
        return stage
    }

    @Throws(Exception::class)
    override suspend fun reorderFunnelStages(funnelID: String, body: ReorderFunnelStagesRequest) {
        genericRequest<Unit>("$baseURL/v1/workspace/owner/funnelstages/$funnelID/reorder", HttpMethod.Put) {
            setBody(body)
        }

        cache.deleteAllFunnelStagesForFunnel(funnelID)
    }

    @Throws(Exception::class)
    override suspend fun updateFunnelStage(id: String, body: UpdateFunnelStageRequest): FunnelStage {
        val stage: FunnelStage = genericRequest("$baseURL/v1/workspace/owner/funnelstages/$id", HttpMethod.Put) {
            setBody(body)
        }
        cache.replaceFunnelStage(stage)
        return stage
    }

    @Throws(Exception::class)
    override suspend fun deleteFunnelStage(id: String) {
        genericRequest<Unit>("$baseURL/v1/workspace/owner/funnelstages/$id", HttpMethod.Delete)
        cache.deleteFunnelStage(id)
    }

    // ------------------------------------------------------------------------
    // Leads
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    override suspend fun assignLeadToMember(id: String, memberID: String): Lead {
        val lead: Lead = genericRequest("$baseURL/v1/workspace/leads/$id/assignMember/$memberID", HttpMethod.Put)
        cache.replaceLead(lead)
        return lead
    }

    @Throws(Exception::class)
    override suspend fun assignLeadToFunnelStage(id: String, stageID: String): Lead {
        val lead: Lead = genericRequest("$baseURL/v1/workspace/leads/$id/assignStage/$stageID", HttpMethod.Put)
        cache.replaceLead(lead)
        return lead
    }

    @Throws(Exception::class)
    override suspend fun getLeads(): List<Lead> {
        val cacheKey = "getLeads"
        try {
            if (!cacheInvalidator.isStale(cacheKey)) {
                val cached = cache.selectAllLeads()
                if (cached.isNotEmpty()) {
                    Utilities.logger.info("Retrieved ${cached.size} leads from cache")
                    return cached
                }
            }
            val fetched: List<Lead> = genericRequest("$baseURL/v1/workspace/leads", HttpMethod.Get)
            cache.replaceAllLeads(fetched)
            cacheInvalidator.updateTimestamp(cacheKey)
            Utilities.logger.info("Cached ${fetched.size} leads")
            return fetched
        } catch (e: Exception) {
            val cached = cache.selectAllLeads()
            if (cached.isNotEmpty()) {
                Utilities.logger.warn("Failed to fetch Leads. Returned ${cached.size} leads from cache")
                return cached
            } else {
                throw e
            }
        }
    }

    @Throws(Exception::class)
    override suspend fun createLead(body: CreateLeadRequest): Lead {
        val lead: Lead = genericRequest("$baseURL/v1/workspace/leads", HttpMethod.Post) {
            setBody(body)
        }
        cache.insertLead(lead)
        return lead
    }

    @Throws(Exception::class)
    override suspend fun updateLead(id: String, body: UpdateLeadRequest): Lead {
        val lead: Lead = genericRequest("$baseURL/v1/workspace/leads/$id", HttpMethod.Put) {
            setBody(body)
        }
        cache.replaceLead(lead)
        return lead
    }

    @Throws(Exception::class)
    override suspend fun convertLead(id: String, wasSuccessfulConversion: Boolean) {
        genericRequest<Unit>("$baseURL/v1/workspace/leads/$id/convert", HttpMethod.Put) {
            parameter("closedResult", if (wasSuccessfulConversion) "CONVERTED" else "NOT_CONVERTED")
        }
        cache.deleteLead(id)
    }

    @Throws(Exception::class)
    override suspend fun deleteLead(id: String) {
        genericRequest<Unit>("$baseURL/v1/workspace/leads/$id", HttpMethod.Delete)
        cache.deleteLead(id)
    }

    // ------------------------------------------------------------------------
    // Opportunities
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    override suspend fun assignOpportunityToMember(id: String, memberID: String): Opportunity {
        val opportunity: Opportunity = genericRequest("$baseURL/v1/workspace/opportunities/$id/assignMember/$memberID", HttpMethod.Put)
        cache.replaceOpportunity(opportunity)
        return opportunity
    }

    @Throws(Exception::class)
    override suspend fun assignOpportunityToFunnelStage(id: String, stageID: String): Opportunity {
        val opportunity: Opportunity = genericRequest("$baseURL/v1/workspace/opportunities/$id/assignStage/$stageID", HttpMethod.Put)
        cache.replaceOpportunity(opportunity)
        return opportunity
    }

    @Throws(Exception::class)
    override suspend fun createOpportunity(body: CreateOpportunityRequest, funnelID: String, accountID: String?): Opportunity {
        val opportunity: Opportunity = genericRequest("$baseURL/v1/workspace/opportunities", HttpMethod.Post) {
            setBody(body)
        }
        cache.insertOpportunity(opportunity, funnelID, accountID)
        return opportunity
    }

    @Throws(Exception::class)
    override suspend fun updateOpportunity(id: String, body: UpdateOpportunityRequest): Opportunity {
        val opportunity: Opportunity = genericRequest("$baseURL/v1/workspace/opportunities/$id", HttpMethod.Put) {
            setBody(body)
        }
        cache.replaceOpportunity(opportunity)
        return opportunity
    }

    @Throws(Exception::class)
    override suspend fun deleteOpportunity(id: String) {
        genericRequest<Unit>("$baseURL/v1/workspace/opportunities/$id", HttpMethod.Delete)
        cache.deleteOpportunity(id)
    }

    // ------------------------------------------------------------------------
    // Tasks
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    override suspend fun createTask(body: CreateTaskRequest): TaskRecord {
        val task: TaskRecord = genericRequest("$baseURL/v1/workspace/tasks", HttpMethod.Post) {
            setBody(body)
        }
        cache.insertTask(task)
        return task
    }

    @Throws(Exception::class)
    override suspend fun getTasks(): List<TaskRecord> {
        val cacheKey = "getTasks"
        try {
            if (!cacheInvalidator.isStale(cacheKey)) {
                val cached = cache.selectAllIncompleteTasks()
                if (cached.isNotEmpty()) {
                    Utilities.logger.info("Retrieved ${cached.size} tasks from cache")
                    return cached
                }
            }
            val fetched: List<TaskRecord> = genericRequest("$baseURL/v1/workspace/tasks", HttpMethod.Get)
            cache.replaceAllIncompleteTasks(fetched)
            Utilities.logger.info("Cached ${fetched.size} tasks")
            cacheInvalidator.updateTimestamp(cacheKey)
            return fetched
        } catch (e: Exception) {
            // Fallback to cached data if a network request fails
            val cached = cache.selectAllIncompleteTasks()
            if (cached.isNotEmpty()) {
                Utilities.logger.warn("Failed to fetch Tasks. Returned ${cached.size} tasks from cache")
                return cached
            } else {
                throw e // Re-throw the exception if there's no cached data
            }
        }
    }

    @Throws(Exception::class)
    override suspend fun getCompletedTasks(): List<TaskRecord> {
        val cacheKey = "getCompletedTasks"
        try {
            if (!cacheInvalidator.isStale(cacheKey)) {
                val cached = cache.selectAllCompleteTasks()
                if (cached.isNotEmpty()) {
                    Utilities.logger.info("Retrieved ${cached.size} completed tasks from cache")
                    return cached
                }
            }
            val fetched: List<TaskRecord> = genericRequest("$baseURL/v1/workspace/tasks/complete", HttpMethod.Get)
            cache.replaceAllCompleteTasks(fetched)
            Utilities.logger.info("Cached ${fetched.size} completed tasks")
            cacheInvalidator.updateTimestamp(cacheKey)
            return fetched
        } catch (e: Exception) {
            // Fallback to cached data if a network request fails
            val cached = cache.selectAllCompleteTasks()
            if (cached.isNotEmpty()) {
                Utilities.logger.warn("Failed to fetch completed Tasks. Returned ${cached.size} completed tasks from cache")
                return cached
            } else {
                throw e // Re-throw the exception if there's no cached data
            }
        }
    }

    @Throws(Exception::class)
    override suspend fun updateTask(id: String, body: UpdateTaskRequest): TaskRecord {
        val task: TaskRecord = genericRequest("$baseURL/v1/workspace/tasks/$id", HttpMethod.Put) {
            setBody(body)
        }
        cache.replaceTask(task)
        return task
    }

    @Throws(Exception::class)
    override suspend fun toggleTaskCompletion(id: String, isComplete: Boolean): TaskRecord {
        val task: TaskRecord = genericRequest("$baseURL/v1/workspace/tasks/$id/toggle/$isComplete", HttpMethod.Put)
        cache.replaceTask(task)
        return task
    }

    @Throws(Exception::class)
    override suspend fun deleteTask(id: String) {
        genericRequest<Unit>("$baseURL/v1/workspace/tasks/$id", HttpMethod.Delete)
        cache.deleteTask(id)
    }

    @Throws(Exception::class)
    override suspend fun getTask(id: String): TaskRecord? {
        val cached = cache.selectTask(id)
        if (cached != null) {
            Utilities.logger.info("Returned task $id from cache")
            return cached
        }
        return genericRequest("$baseURL/v1/workspace/tasks/$id", HttpMethod.Get)
    }

    // ------------------------------------------------------------------------
    // Users
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    override suspend fun createUser(body: CreateUserRequest): User {
        return genericRequest("$baseURL/v1/user", HttpMethod.Post) {
            setBody(body)
        }
    }

    @Throws(Exception::class)
    override suspend fun getUserById(userId: String): User {
        return genericRequest("$baseURL/v1/user/$userId", HttpMethod.Get)
    }

    // ------------------------------------------------------------------------
    // Workspaces
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    override suspend fun getWorkspaces(): List<Workspace> {
        return genericRequest("$baseURL/v1/workspaces", HttpMethod.Get)
    }

    @Throws(Exception::class)
    override suspend fun deleteWorkspace(): Workspace {
        return genericRequest("$baseURL/v1/workspace/owner/deleteWorkspace", HttpMethod.Delete)
    }

    @Throws(Exception::class)
    override suspend fun acceptWorkspaceRequest(userID: String) {
        return genericRequest("$baseURL/v1/workspace/owner/acceptRequest/$userID", HttpMethod.Post)
    }

    @Throws(Exception::class)
    override suspend fun declineWorkspaceRequest(userID: String) {
        return genericRequest("$baseURL/v1/workspace/owner/declineRequest/$userID", HttpMethod.Post)
    }

    @Throws(Exception::class)
    override suspend fun updateWorkspace(body: UpdateWorkspaceRequest): Workspace {
        return genericRequest("$baseURL/v1/workspace", HttpMethod.Put) {
            setBody(body)
        }
    }

    @Throws(Exception::class)
    override suspend fun inviteUserToWorkspace(email: String) {
        return genericRequest("$baseURL/v1/workspace/owner/invite/$email", HttpMethod.Post)
    }

    @Throws(Exception::class)
    override suspend fun declineWorkspaceInvitation(id: String) {
        return genericRequest("$baseURL/v1/workspace/owner/$id/declineInvite", HttpMethod.Post)
    }

    @Throws(Exception::class)
    override suspend fun acceptWorkspaceInvitation(id: String): Workspace {
        return genericRequest("$baseURL/v1/workspace/owner/$id/acceptInvite", HttpMethod.Post)
    }

    @Throws(Exception::class)
    override suspend fun requestWorkspaceMembership(name: String) {
        return genericRequest("$baseURL/v1/workspaces/$name/requestMembership", HttpMethod.Post)
    }

    @Throws(Exception::class)
    override suspend fun leaveWorkspace() {
        return genericRequest("$baseURL/v1/workspace/leave", HttpMethod.Post)
    }

    @Throws(Exception::class)
    override suspend fun createWorkspace(body: CreateWorkspaceRequest): Workspace {
        return genericRequest("$baseURL/v1/workspaces", HttpMethod.Post) {
            setBody(body)
        }
    }

    // ------------------------------------------------------------------------
    // Workspace Members
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    override suspend fun getWorkspaceMembers(): List<WorkspaceMember> {
        val cacheKey = "getWorkspaceMembers"
        try {
            if (!cacheInvalidator.isStale(cacheKey)) {
                val cached = cache.selectAllWorkspaceMembers()
                if (cached.isNotEmpty()) {
                    Utilities.logger.info("Retrieved ${cached.size} workspace members from cache")
                    return cached
                }
            }
            val fetched: List<WorkspaceMember> = genericRequest("$baseURL/v1/workspace/members", HttpMethod.Get)
            cache.replaceAllWorkspaceMembers(fetched)
            Utilities.logger.info("Cached ${fetched.size} workspace members")
            cacheInvalidator.updateTimestamp(cacheKey)
            return fetched
        } catch (e: Exception) {
            val cached = cache.selectAllWorkspaceMembers()
            if (cached.isNotEmpty()) {
                Utilities.logger.warn("Failed to fetch workspace members. Returned ${cached.size} members from cache")
                return cached
            } else {
                throw e
            }
        }
    }

    @Throws(Exception::class)
    override suspend fun changeWorkspaceRole(userID: String, role: WorkspaceMembershipRole) {
        genericRequest<Unit>("$baseURL/v1/workspace/owner/roles/$userID?role=$role", HttpMethod.Post)
        cache.changeWorkspaceMemberRole(userID, role)
    }

    @Throws(Exception::class)
    override suspend fun removeMemberFromWorkspace(userID: String) {
        genericRequest<Unit>("$baseURL/v1/workspace/owner/removeMember/$userID", HttpMethod.Delete)
        cache.deleteWorkspaceMember(userID)
    }

    // ------------------------------------------------------------------------
    // Utility Methods
    // ------------------------------------------------------------------------

    private val httpClient = HttpClient {
        install(HttpCache)
        install(ContentNegotiation) {
            json(Json {
                prettyPrint = true
                isLenient = true
                ignoreUnknownKeys = true
            })
        }

        // Default request configuration
        defaultRequest {
            header(HttpHeaders.Accept, ContentType.Application.Json)
            header(HttpHeaders.ContentType, ContentType.Application.Json)
            token?.let {
                header("Authorization", "Bearer $it")
            }
            workspaceID?.let {
                header("Workspace-ID", it)
            }
        }

        // Generic request handling
        expectSuccess = false // Disable automatic throwing on HTTP error status codes
        HttpResponseValidator {
            handleResponseExceptionWithRequest { exception, request ->
                val exceptionString = "${request.method.value} ${request.url}"
                when (exception) {
                    is ClientRequestException -> {
                        Utilities.logger.log(LogLevel.ERROR, "Request Failure: $exceptionString\n${exception.response}")
                    }

                    is ServerResponseException -> {
                        Utilities.logger.log(LogLevel.ERROR, "Server Error: $exceptionString\n${exception.response}")
                    }

                    is ResponseException -> {
                        Utilities.logger.log(LogLevel.WARN, "Response Error: $exceptionString\n${exception.response}")
                    }
                }
            }
        }
    }

    private suspend inline fun <reified T> genericRequest(
        url: String,
        method: HttpMethod,
        crossinline block: HttpRequestBuilder.() -> Unit = {}
    ): T {
        var requestBody = ""
        val response: HttpResponse = httpClient.request(url) {
            this.method = method
            this.apply(block)
            requestBody = this.body.toString()
        }
        val responseBody = response.bodyAsText()
        Utilities.logger.log(LogLevel.INFO, "⬆️ ${method.value} $url")
        if (requestBody != "EmptyContent") {
            Utilities.logger.log(LogLevel.INFO, "✴️ $requestBody")
        }

        if (T::class == Unit::class) {
            return Unit as T
        }

        if (response.status.isSuccess()) {
            Utilities.logger.log(LogLevel.INFO, "✅ $responseBody")
            try {
                return jsonDecoder.decodeFromString<T>(responseBody)
            } catch (e: SerializationException) {
                Utilities.logger.warn(e.message.orEmpty())
                onDecodingError?.invoke(e.message.orEmpty())
                throw e
            }
        } else {
            Utilities.logger.log(LogLevel.WARN, "🆘 $responseBody")
            try {
                val message = jsonDecoder.decodeFromString<APIError>(responseBody).message
                when (response.status) {
                    HttpStatusCode.Unauthorized -> {
                        onAuthFailure?.invoke(message)
                        // TODO: retry after refreshing the token? Maybe the closure should return a bool (if success)
                    }
                    HttpStatusCode.BadRequest -> onBadRequest?.invoke(message)
                    HttpStatusCode.NotFound -> onMissing?.invoke(message)
                    HttpStatusCode.InternalServerError -> onServerError?.invoke(message)
                }
                throw RuntimeException("Unexpected server response: $responseBody")
            } catch (e: SerializationException) {
                onServerError?.invoke(e.message.orEmpty())
                throw e
            }
        }
    }


    private val jsonDecoder = Json {
        prettyPrint = true
        isLenient = true
        ignoreUnknownKeys = true
    }
}
