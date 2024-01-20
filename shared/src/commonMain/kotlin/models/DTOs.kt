package models

import kotlinx.serialization.Serializable

@Serializable
data class CreateContactRequest(
    val firstName: String,
    val lastName: String? = null,
    val emails: List<String>,
    val phoneNumbers: List<String>,
    val companyName: String? = null,

)

@Serializable
data class UpdateContactRequest(
    val firstName: String,
    val lastName: String? = null,
    val emails: List<String>,
    val phoneNumbers: List<String>,
    val companyName: String? = null,
)

@Serializable
data class CreateUserRequest(
    val id: String,
    val username: String,
    val email: String,
)

@Serializable
data class CreateTaskRequest(
    val title: String,
    val priority: Int,
    val body: String? = null,
    val scheduledDate: String? = null,
)

@Serializable
data class UpdateTaskRequest(
    val title: String,
    val priority: Int,
    val body: String? = null,
    val isComplete: Boolean? = null,
    val scheduledDate: String? = null,
)

@Serializable
data class CreateWorkspaceRequest(val name: String)

@Serializable
data class UpdateWorkspaceRequest(
    val name: String? = null,
    val avatarURL: String? = null
)

@Serializable
data class APIError(
    val message: String,
    val code: Int,
)