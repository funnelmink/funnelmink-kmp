package models

import kotlinx.serialization.Serializable

@Serializable
data class CreateAccountRequest(
    val name: String,
    val email: String? = null,
    val phone: String? = null,
    val latitude: Double? = null,
    val longitude: Double? = null,
    val address: String? = null,
    val city: String? = null,
    val state: String? = null,
    val country: String? = null,
    val zip: String? = null,
    val notes: String? = null,
    val type: AccountType,
    val leadID: String? = null
)

@Serializable
data class UpdateAccountRequest(
    val name: String? = null,
    val email: String? = null,
    val phone: String? = null,
    val latitude: Double? = null,
    val longitude: Double? = null,
    val address: String? = null,
    val city: String? = null,
    val state: String? = null,
    val country: String? = null,
    val zip: String? = null,
    val notes: String? = null,
    val type: String? = null
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

enum class ActivitySubtype(val typeName: String) {
    Contact("contact")
}

@Serializable
data class CreateActivityRequest(
    val type: ActivityRecordType,
    val details: String?,
    val parentID: String
)