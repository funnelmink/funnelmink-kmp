package models

import kotlinx.serialization.KSerializer
import kotlinx.serialization.Serializable
import kotlinx.serialization.descriptors.PrimitiveKind
import kotlinx.serialization.descriptors.PrimitiveSerialDescriptor
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder

// ------------------------------------------------------------------------
// MARK: - Models
// ------------------------------------------------------------------------

@Serializable
data class Account(
    val id: String,

    val address: String? = null,
    val city: String? = null,
    val country: String? = null,
    val createdAt: String,
    val email: String? = null,
    val latitude: Double? = null,
    val leadID: String? = null,
    val longitude: Double? = null,
    val name: String,
    val notes: String? = null,
    val phone: String? = null,
    val state: String? = null,
    val updatedAt: String,
    val zip: String? = null,

    val activities: List<ActivityRecord> = emptyList(),
    val contacts: List<AccountContact> = emptyList(),
    val leads: List<Lead> = emptyList(),
    val cases: List<CaseRecord> = emptyList(),
    val opportunities: List<Opportunity> = emptyList(),
)

@Serializable
data class AccountContact(
    val id: String,

    val email: String? = null,
    val jobTitle: String? = null,
    val name: String? = null,
    val notes: String? = null,
    val phone: String? = null,

    val accountName: String? = null,
    val accountID: String? = null,
)


@Serializable
data class ActivityRecord(
    val id: String,

    val createdAt: String,
    val details: String? = null,
    val memberID: String,
    val type: ActivityRecordType,
)

@Serializable
data class CaseRecord(
    val id: String,

    val assignedTo: String? = null,
    val closedDate: String? = null,
    val createdAt: String,
    val description: String? = null,
    val name: String,
    val notes: String? = null,
    val priority: Int,
    val stageID: String? = null,
    val updatedAt: String,
    val value: Double,

    val activities: List<ActivityRecord> = emptyList(),
    val accountName: String? = null,
    val accountID: String? = null,
)

@Serializable
data class Funnel(
    val id: String,

    val name: String,
    val type: FunnelType,
    var stages: List<FunnelStage> = emptyList(),
    var cases: List<CaseRecord> = emptyList(),
    var leads: List<Lead> = emptyList(),
    var opportunities: List<Opportunity> = emptyList(),
)

@Serializable
data class FunnelStage(
    val id: String,

    val name: String,
    val order: Int,
)

@Serializable
data class Lead(
    val id: String,

    val address: String? = null,
    val assignedTo: String? = null,
    val city: String? = null,
    val closedDate: String? = null,
    val closedResult: LeadClosedResult? = null,
    val company: String? = null,
    val country: String? = null,
    val createdAt: String,
    val email: String? = null,
    val jobTitle: String? = null,
    val latitude: Double? = null,
    val longitude: Double? = null,
    val name: String,
    val notes: String? = null,
    val phone: String? = null,
    val priority: Int,
    val source: String? = null,
    val stageID: String? = null,
    val state: String? = null,
    val updatedAt: String,
    val zip: String? = null,

    val activities: List<ActivityRecord> = emptyList(),
    val accountName: String? = null,
    val accountID: String? = null,
)

@Serializable
data class Opportunity(
    val id: String,

    val assignedTo: String? = null,
    val closedDate: String? = null,
    val createdAt: String,
    val description: String? = null,
    val name: String,
    val notes: String? = null,
    val priority: Int,
    val stageID: String? = null,
    val updatedAt: String,
    val value: Double,

    val activities: List<ActivityRecord> = emptyList(),
    val accountName: String? = null,
    val accountID: String? = null,
)

@Serializable
data class TaskRecord(
    val id: String,

    val body: String? = null,
    val isComplete: Boolean,
    val priority: Int,
    val scheduledDate: String? = null,
    val title: String,
    val updatedAt: String,
)

@Serializable
data class User(
    val id: String,
    val username: String,
    val email: String,
    val isDevAccount: Boolean
)

@Serializable
data class Workspace(
    val id: String,
    val name: String,
    var roles: List<WorkspaceMembershipRole>,
    val avatarURL: String? = null
)

@Serializable
data class WorkspaceMember(
    val id: String,
    val userID: String,
    val username: String,
    //    @SerialName("avatar_url") val avatarURL: String? = null,
    var roles: List<WorkspaceMembershipRole>,
    //    val email: String, I don't think we want to share emails?
)

// ------------------------------------------------------------------------
// MARK: - Enums
// ------------------------------------------------------------------------

@Serializable(with = ActivityRecordTypeSerializer::class)
enum class ActivityRecordType(val typeName: String) {
    Email("EMAIL"),
    Meeting("MEETING"),
    Note("NOTE"),
    PhoneCall("PHONE_CALL"),
    Update("UPDATE"),
    TextMessage("TEXT_MESSAGE");

    companion object {
        fun fromTypeName(typeName: String): ActivityRecordType =
            entries.find { it.typeName == typeName }
                ?: throw IllegalArgumentException("Type not found for name: $typeName")
    }
}

@Serializable(with = FunnelTypeSerializer::class)
enum class FunnelType(val typeName: String) {
    Case("CASE"),
    Lead("LEAD"),
    Opportunity("OPPORTUNITY");

    companion object {
        fun fromTypeName(typeName: String): FunnelType =
            entries.find { it.typeName == typeName }
                    ?: throw IllegalArgumentException("Type not found for name: $typeName")
    }
}

@Serializable(with = LeadClosedResultSerializer::class)
enum class LeadClosedResult(val resultName: String) {
    AccountAndOpportunity("CONVERT_TO_ACCOUNT_AND_OPPORTUNITY"),
    Account("CONVERT_TO_ACCOUNT"),
    Lost("CLOSE_AS_LOST");

    companion object {
        fun fromResultName(resultName: String): LeadClosedResult =
            entries.find { it.resultName == resultName }
                ?: throw IllegalArgumentException("Result not found for name: $resultName")
    }
}

@Serializable(with = WorkspaceMembershipRoleSerializer::class)
enum class WorkspaceMembershipRole(val roleName: String) {
    Admin("Admin"),
    Invited("Invited"),
    Labor("Labor"),
    Sales("Sales");

    companion object {
        fun fromRoleName(roleName: String): WorkspaceMembershipRole =
            entries.find { it.roleName == roleName }
                ?: throw IllegalArgumentException("Role not found for name: $roleName")
    }
}

// ------------------------------------------------------------------------
// MARK: - Enum Serializers
// ------------------------------------------------------------------------

object ActivityRecordTypeSerializer : KSerializer<ActivityRecordType> {
    override val descriptor: SerialDescriptor =
        PrimitiveSerialDescriptor("ActivityRecordType", PrimitiveKind.STRING)

    override fun serialize(encoder: Encoder, value: ActivityRecordType) {
        encoder.encodeString(value.typeName)
    }

    override fun deserialize(decoder: Decoder): ActivityRecordType {
        val typeName = decoder.decodeString()
        return ActivityRecordType.fromTypeName(typeName)
    }
}

object FunnelTypeSerializer : KSerializer<FunnelType> {
    override val descriptor: SerialDescriptor =
        PrimitiveSerialDescriptor("FunnelType", PrimitiveKind.STRING)

    override fun serialize(encoder: Encoder, value: FunnelType) {
        encoder.encodeString(value.typeName)
    }

    override fun deserialize(decoder: Decoder): FunnelType {
        val typeName = decoder.decodeString()
        return FunnelType.fromTypeName(typeName)
    }
}

object LeadClosedResultSerializer : KSerializer<LeadClosedResult> {
    override val descriptor: SerialDescriptor =
        PrimitiveSerialDescriptor("LeadClosedResult", PrimitiveKind.STRING)

    override fun serialize(encoder: Encoder, value: LeadClosedResult) {
        encoder.encodeString(value.resultName)
    }

    override fun deserialize(decoder: Decoder): LeadClosedResult {
        val resultName = decoder.decodeString()
        return LeadClosedResult.fromResultName(resultName)
    }
}

object WorkspaceMembershipRoleSerializer : KSerializer<WorkspaceMembershipRole> {
    override val descriptor: SerialDescriptor =
        PrimitiveSerialDescriptor("WorkspaceMembershipRole", PrimitiveKind.STRING)

    override fun serialize(encoder: Encoder, value: WorkspaceMembershipRole) {
        encoder.encodeString(value.roleName)
    }

    override fun deserialize(decoder: Decoder): WorkspaceMembershipRole {
        val roleName = decoder.decodeString()
        return WorkspaceMembershipRole.fromRoleName(roleName)
    }
}