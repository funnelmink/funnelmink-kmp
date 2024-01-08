package networking

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

class FunnelminkAPI(private val baseURL: String) : API {
    override var token: String? = null
    override var workspaceID: String? = null
    override var onAuthFailure: ((message: String) -> Unit)? = null
    override var onBadRequest: ((message: String) -> Unit)? = null
    override var onDecodingError: ((message: String) -> Unit)? = null
    override var onMissing: ((message: String) -> Unit)? = null
    override var onServerError: ((message: String) -> Unit)? = null

    @Throws(Exception::class)
    override suspend fun createContact(body: CreateContactRequest): Contact {
        return genericRequest("$baseURL/v1/contacts", HttpMethod.Post) {
            setBody(body)
        }
    }

    @Throws(Exception::class)
    override suspend fun deleteContact(id: String) {
        return genericRequest("$baseURL/v1/contacts/$id", HttpMethod.Delete)
    }

    @Throws(Exception::class)
    override suspend fun getContactDetails(id: String): Contact {
        return genericRequest("$baseURL/v1/contacts/$id", HttpMethod.Get)
    }

    @Throws(Exception::class)
    override suspend fun getContacts(): List<Contact> {
        return genericRequest("$baseURL/v1/contacts", HttpMethod.Get)
    }

    @Throws(Exception::class)
    override suspend fun updateContact(id: String, body: UpdateContactRequest): Contact {
        return genericRequest("$baseURL/v1/contacts/$id", HttpMethod.Put) {
            setBody(body)
        }
    }

    @Throws(Exception::class)
    override suspend fun getWorkspaces(): List<Workspace> {
        return genericRequest("$baseURL/v1/workspaces", HttpMethod.Get)
    }

    @Throws(Exception::class)
    override suspend fun getWorkspaceMembers(): List<WorkspaceMember> {
        return genericRequest("$baseURL/v1/workspaces/members", HttpMethod.Get)
    }

    @Throws(Exception::class)
    override suspend fun deleteWorkspace(): Workspace {
        return genericRequest("$baseURL/v1/workspaces/delete", HttpMethod.Delete)
    }

    @Throws(Exception::class)
    override suspend fun acceptWorkspaceRequest(userID: String) {
        return genericRequest("$baseURL/v1/workspaces/acceptRequest/$userID", HttpMethod.Post)
    }

    @Throws(Exception::class)
    override suspend fun declineWorkspaceRequest(userID: String) {
        return genericRequest("$baseURL/v1/workspaces/declineRequest/$userID", HttpMethod.Post)
    }

    @Throws(Exception::class)
    override suspend fun updateWorkspace(body: UpdateWorkspaceRequest): Workspace {
        return genericRequest("$baseURL/v1/workspaces/update", HttpMethod.Put) {
            setBody(body)
        }
    }

    @Throws(Exception::class)
    override suspend fun inviteUserToWorkspace(email: String) {
        return genericRequest("$baseURL/v1/workspaces/invite/$email", HttpMethod.Post)
    }

    @Throws(Exception::class)
    override suspend fun changeWorkspaceRole(userID: String, role: WorkspaceMembershipRole) {
        return genericRequest("$baseURL/v1/workspaces/roles/$userID?role=$role", HttpMethod.Post)
    }

    @Throws(Exception::class)
    override suspend fun declineWorkspaceInvitation(id: String) {
        return genericRequest("$baseURL/v1/workspaces/$id/declineInvite", HttpMethod.Post)
    }

    @Throws(Exception::class)
    override suspend fun acceptWorkspaceInvitation(id: String): Workspace {
        return genericRequest("$baseURL/v1/workspaces/$id/acceptInvite", HttpMethod.Post)
    }

    @Throws(Exception::class)
    override suspend fun requestWorkspaceMembership(name: String) {
        return genericRequest("$baseURL/v1/workspaces/$name/requestMembership", HttpMethod.Post)
    }

    @Throws(Exception::class)
    override suspend fun leaveWorkspace() {
        return genericRequest("$baseURL/v1/workspaces/leave", HttpMethod.Post)
    }

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

    @Throws(Exception::class)
    override suspend fun createTask(body: CreateTaskRequest): ScheduleTask {
        return genericRequest("$baseURL/v1/tasks", HttpMethod.Post) {
            setBody(body)
        }
    }

    @Throws(Exception::class)
    override suspend fun getTasks(date: String?, priority: Int?, limit: Int?, offset: Int?): Array<ScheduleTask> {
        return genericRequest("$baseURL/v1/tasks", HttpMethod.Get) {
            date?.let { parameter("date", it) }
            priority?.let { parameter("priority", it) }
            limit?.let { parameter("limit", it) }
            offset?.let { parameter("offset", it) }
        }
    }

    @Throws(Exception::class)
    override suspend fun updateTask(id: String, body: UpdateTaskRequest): ScheduleTask {
        return genericRequest("$baseURL/v1/tasks/$id", HttpMethod.Put) {
            setBody(body)
        }
    }

    @Throws(Exception::class)
    override suspend fun deleteTask(id: String) {
        return genericRequest("$baseURL/v1/tasks", HttpMethod.Delete)
    }

    @Throws(Exception::class)
    override suspend fun createWorkspace(body: CreateWorkspaceRequest): Workspace {
        return genericRequest("$baseURL/v1/workspaces", HttpMethod.Post) {
            setBody(body)
        }
    }

    @Throws(Exception::class)
    override suspend fun removeMemberFromWorkspace(userID: String) {
        return genericRequest("$baseURL/v1/workspaces/removeMember/$userID", HttpMethod.Delete)
    }

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
                        println("Request Failure: $exceptionString\n${exception.response}")
                    }

                    is ServerResponseException -> {
                        println("Server Error: $exceptionString\n${exception.response}")
                    }

                    is ResponseException -> {
                        println("Response Error: $exceptionString\n${exception.response}")
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
        val response: HttpResponse = httpClient.request(url) {
            this.method = method
            this.apply(block)
        }
        val responseBody = response.bodyAsText()
        println("⬆️ ${method.value} $url")

        if (T::class == Unit::class) {
            return Unit as T
        }

        if (response.status.isSuccess()) {
            println("✅ $responseBody")
            try {
                val body = jsonDecoder.decodeFromString<T>(responseBody)
                return body
            } catch (e: SerializationException) {
                onDecodingError?.invoke(e.message.orEmpty())
                throw e
            }
        } else {
            println("🆘 $responseBody")
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