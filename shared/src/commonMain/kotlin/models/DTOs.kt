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
)

@Serializable
data class AccountDetailsResponse(
    val id: String,
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
    val createdAt: String,
    val updatedAt: String,
    val leadID: String? = null,
    val activities: List<ActivityRecord>,
    val contacts: List<AccountContact>,
    val leads: List<Lead>,
    val cases: List<CaseRecord>,
    val opportunities: List<Opportunity>
)

@Serializable
data class CreateAccountContactRequest(
    val name: String,
    val email: String? = null,
    val phone: String? = null,
    val jobTitle: String? = null,
    val notes: String? = null,
)

@Serializable
data class UpdateAccountContactRequest(
    val name: String? = null,
    val email: String? = null,
    val phone: String? = null,
    val jobTitle: String? = null,
    val notes: String? = null,
)

@Serializable
data class CreateCaseRequest(
    val name: String,
    val description: String? = null,
    val notes: String? = null,
    val priority: Int? = null,
    val value: Double? = null
)

@Serializable
data class UpdateCaseRequest(
    val name: String? = null,
    val description: String? = null,
    val notes: String? = null,
    val priority: Int? = null,
    val value: Double? = null
)

@Serializable
data class CreateLeadRequest(
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
    val company: String? = null,
    val jobTitle: String? = null,
    val priority: Int? = null,
    val source: String? = null,
    val accountID: String? = null,
    val assignedTo: String? = null,
    val funnelID: String? = null,
    val stageID: String? = null
)

@Serializable
data class UpdateLeadRequest(
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
    val company: String? = null,
    val jobTitle: String? = null,
    val priority: Int? = null,
    val source: String? = null,
    val accountID: String? = null,
    val assignedTo: String? = null,
    val funnelID: String? = null,
    val stageID: String? = null
)

@Serializable
data class CreateOpportunityRequest(
    val name: String,
    val description: String? = null,
    val value: Double? = null,
    val priority: Int? = null,
    val notes: String? = null,
    val accountID: String? = null,
    val assignedToID: String? = null,
    val funnelID: String,
    val stageID: String,
)

@Serializable
data class UpdateOpportunityRequest(
    val name: String,
    val description: String? = null,
    val value: Double? = null,
    val priority: Int? = null,
    val notes: String? = null,
    val assignedTo: String? = null,
    val stageID: String? = null,
    val funnelID: String? = null,
)

@Serializable
data class CreateFunnelRequest(
    val name: String,
    val type: String,
    val stages: List<String>
)

@Serializable
data class UpdateFunnelRequest(
    val name: String,
)

@Serializable
data class CreateFunnelStageRequest(
    val name: String,
)

@Serializable
data class ReorderFunnelStagesRequest(
    val stageIDs: List<String>,
)

@Serializable
data class UpdateFunnelStageRequest(
    val name: String,
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
    Account("account"),
    Case("case"),
    Lead("lead"),
    Opportunity("opportunity"),
}

@Serializable
data class CreateActivityRequest(
    val type: ActivityRecordType,
    val details: String?,
    val parentID: String
)
