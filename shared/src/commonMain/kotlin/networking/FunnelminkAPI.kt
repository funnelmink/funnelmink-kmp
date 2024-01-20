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
import io.ktor.util.reflect.*
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
        cache.insertUser(user)
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
    // Contacts
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    override suspend fun createContact(body: CreateContactRequest): Contact {
        val contact: Contact = genericRequest("$baseURL/v1/workspace/contacts", HttpMethod.Post) {
            setBody(body)
        }
        cache.insertContact(contact)
        return contact
    }

    @Throws(Exception::class)
    override suspend fun deleteContact(id: String) {
        genericRequest<Unit>("$baseURL/v1/workspace/contacts/$id", HttpMethod.Delete)
        cache.deleteTask(id)
    }

    @Throws(Exception::class)
    override suspend fun getContactDetails(id: String): Contact {
        // TODO: maybe cache this? I think one day it might return Activities and Location data though. Could be complex
        return genericRequest("$baseURL/v1/workspace/contacts/$id", HttpMethod.Get)
    }

    @Throws(Exception::class)
    override suspend fun getContacts(): List<Contact> {
        val cacheKey = "getContacts"
        try {
            if (!cacheInvalidator.isStale(cacheKey)) {
                val cached = cache.selectAllContacts()
                if (cached.isNotEmpty()) {
                    Utilities.logger.info("Retrieved ${cached.size} contacts from cache")
                    return cached
                }
            }
            val fetched: List<Contact> = genericRequest("$baseURL/v1/workspace/contacts", HttpMethod.Get)
            cache.replaceAllContacts(fetched)
            cacheInvalidator.updateTimestamp(cacheKey)
            Utilities.logger.info("Cached ${fetched.size} contacts")
            return fetched
        } catch (e: Exception) {
            val cached = cache.selectAllContacts()
            if (cached.isNotEmpty()) {
                Utilities.logger.warn("Failed to fetch Contacts. Returned ${cached.size} contacts from cache")
                return cached
            } else {
                throw e
            }
        }
    }

    @Throws(Exception::class)
    override suspend fun updateContact(id: String, body: UpdateContactRequest): Contact {
        val contact: Contact = genericRequest("$baseURL/v1/workspace/contacts/$id", HttpMethod.Put) {
            setBody(body)
        }
        cache.updateContact(contact)
        return contact
    }

    // ------------------------------------------------------------------------
    // Tasks
    // ------------------------------------------------------------------------

    @Throws(Exception::class)
    override suspend fun createTask(body: CreateTaskRequest): ScheduleTask {
        val task: ScheduleTask = genericRequest("$baseURL/v1/workspace/tasks", HttpMethod.Post) {
            setBody(body)
        }
        cache.insertTask(task)
        return task
    }

    @Throws(Exception::class)
    override suspend fun getTasks(
        date: String?,
        priority: Int?,
        limit: Int?,
        offset: Int?,
        isComplete: Boolean
    ): List<ScheduleTask> {
        val cacheKey = "getTasks"
        try {
            if (!cacheInvalidator.isStale(cacheKey)) {
                val cached = cache.selectAllTasks()
                if (cached.isNotEmpty()) {
                    Utilities.logger.info("Retrieved ${cached.size} tasks from cache")
                    return cached
                }
            }
            val fetched: List<ScheduleTask> = genericRequest("$baseURL/v1/workspace/tasks", HttpMethod.Get) {
                date?.let { parameter("date", it) }
                priority?.let { parameter("priority", it) }
                limit?.let { parameter("limit", it) }
                offset?.let { parameter("offset", it) }
                parameter("isComplete", isComplete)
            }
            cache.replaceAllTasks(fetched)
            Utilities.logger.info("Cached ${fetched.size} tasks")
            cacheInvalidator.updateTimestamp(cacheKey)
            return fetched
        } catch (e: Exception) {
            // Fallback to cached data if a network request fails
            val cached = cache.selectAllTasks()
            if (cached.isNotEmpty()) {
                Utilities.logger.warn("Failed to fetch Tasks. Returned ${cached.size} tasks from cache")
                return cached
            } else {
                throw e // Re-throw the exception if there's no cached data
            }
        }
    }

    @Throws(Exception::class)
    override suspend fun updateTask(id: String, body: UpdateTaskRequest): ScheduleTask {
        val task: ScheduleTask = genericRequest("$baseURL/v1/workspace/tasks/$id", HttpMethod.Put) {
            setBody(body)
        }
        cache.updateTask(task)
        return task
    }

    @Throws(Exception::class)
    override suspend fun toggleTaskCompletion(id: String, isComplete: Boolean): ScheduleTask {
        val task: ScheduleTask = genericRequest("$baseURL/v1/workspace/tasks/$id/toggle/$isComplete", HttpMethod.Put)
        cache.updateTask(task)
        return task
    }

    @Throws(Exception::class)
    override suspend fun deleteTask(id: String) {
        genericRequest<Unit>("$baseURL/v1/workspace/tasks/$id", HttpMethod.Delete)
        cache.deleteTask(id)
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
                val body = jsonDecoder.decodeFromString<T>(responseBody)
                return body
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
                    HttpStatusCode.Unauthorized -> onAuthFailure?.invoke(message)
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
