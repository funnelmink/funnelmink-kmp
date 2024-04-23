package models

import kotlinx.serialization.Serializable

@Serializable
data class RecordClosureRequest(
    val reason: String? = null,
)

@Serializable
data class LinkRecordRequest(
    val recordID: String,
    val type: RecordType,
)

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
)

@Serializable
data class CreateActivityRequest(
    val type: ActivityRecordType,
    val details: String,
    val parentID: String
)

@Serializable
data class CreateCaseRequest(
    val name: String,
    val description: String? = null,
    val value: Double,
    val priority: Int,
    val notes: String? = null,
    val accountID: String,
    val assignedTo: String? = null,
    val stageID: String,
)

@Serializable
data class UpdateCaseRequest(
    val name: String,
    val description: String? = null,
    val value: Double,
    val priority: Int,
    val notes: String? = null,
    val assignedTo: String? = null,
    val stageID: String,
)

@Serializable
data class CreateContactRequest(
    val name: String,
    val email: String? = null,
    val phone: String? = null,
    val jobTitle: String? = null,
    val notes: String? = null,
    val accountID: String,
)

@Serializable
data class UpdateContactRequest(
    val name: String,
    val email: String? = null,
    val phone: String? = null,
    val jobTitle: String? = null,
    val notes: String? = null,
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
    val assignedTo: String? = null,
    val stageID: String,
)

@Serializable
data class UpdateLeadRequest(
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
    val assignedTo: String? = null,
    val stageID: String,
)

@Serializable
data class CreateOpportunityRequest(
    val name: String,
    val description: String? = null,
    val value: Double,
    val priority: Int,
    val notes: String? = null,
    val accountID: String,
    val assignedTo: String? = null,
    val stageID: String,
)

@Serializable
data class UpdateOpportunityRequest(
    val name: String,
    val description: String? = null,
    val value: Double,
    val priority: Int,
    val notes: String? = null,
    val assignedTo: String? = null,
    val stageID: String,
)

@Serializable
data class CreateTaskRequest(
    val title: String,
    val body: String,
    val priority: Int,
    val date: String? = null,
    val time: String? = null,
    val duration: Int? = null,
    val visibility: RecordVisibility,
    val assignedTo: String
)

@Serializable
data class UpdateTaskRequest(
    val title: String,
    val body: String,
    val priority: Int,
    val isComplete: Boolean,
    val date: String? = null,
    val time: String? = null,
    val duration: Int? = null,
    val visibility: RecordVisibility,
    val assignedTo: String
)

@Serializable
data class CreateUserRequest(
    val id: String,
    val email: String,
    val username: String,
)
@Serializable
data class CreateWorkspaceRequest(val name: String)

@Serializable
data class UpdateWorkspaceRequest(
    val name: String,
    val avatarURL: String? = null
)

@Serializable
data class SearchRequest(
    val searchText: String,
)

@Serializable
data class SearchResult(
    val accounts: List<Account>,
    val contacts: List<Contact>,
    val cases: List<CaseRecord>,
    val leads: List<Lead>,
    val opportunities: List<Opportunity>,
    val tasks: List<TaskRecord>,
)

@Serializable
data class MemberAssignments(
    val cases: List<CaseRecord>,
    val leads: List<Lead>,
    val opportunities: List<Opportunity>,
    val tasks: List<TaskRecord>,
)

@Serializable
data class WorkspaceMembershipRolesRequest(
    val roles: List<WorkspaceMembershipRole>,
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