package models

import kotlinx.serialization.Serializable

@Serializable
data class CreateContactRequest(
    val name: String,
    val emails: List<String>,
    val phoneNumbers: List<String>,
    val jobTitle: String? = null,
)

@Serializable
data class UpdateContactRequest(
    val name: String?,
    val emails: List<String>?,
    val phoneNumbers: List<String>?,
    val jobTitle: String?,
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
data class User(
    val id: String,
    val username: String,
    val email: String,
)

@Serializable
data class CreateWorkspaceRequest(val name: String)

@Serializable
data class APIError(
    val message: String,
    val code: Int,
)