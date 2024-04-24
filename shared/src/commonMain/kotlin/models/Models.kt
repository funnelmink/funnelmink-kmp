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

    val name: String,
    val email: String,
    val phone: String,
    val latitude: Double? = null,
    val longitude: Double? = null,
    val address: String,
    val city: String,
    val state: String,
    val country: String,
    val zip: String,
    val notes: String,

    val createdAt: String,
    val updatedAt: String,

    val leadID: String? = null,

    val activities: List<ActivityRecord> = emptyList(),
    val contacts: List<Contact> = emptyList(),
    val cases: List<CaseRecord> = emptyList(),
    val opportunities: List<Opportunity> = emptyList(),
)

@Serializable
data class Contact(
    val id: String,

    val name: String,
    val email: String,
    val phone: String,
    val jobTitle: String,
    val notes: String,

    val accountName: String? = null,
    val accountID: String,
)


@Serializable
data class ActivityRecord(
    val id: String,

    val createdAt: String,
    val details: String,
    val memberID: String,
    val type: ActivityRecordType,
)

@Serializable
data class CaseRecord(
    val id: String,

    val name: String,
    val closedDate: String? = null,
    val createdAt: String,
    val description: String,
    val notes: String,
    val priority: Int,
    val updatedAt: String,
    val value: Double,
    val activities: List<ActivityRecord> = emptyList(),

    val stageID: String,
    val stageName: String? = null,
    val accountName: String? = null,
    val accountID: String,
    val assignedToID: String? = null,
    val assignedToName: String? = null,
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

    val name: String,
    val email: String,
    val phone: String,
    val latitude: Double? = null,
    val longitude: Double? = null,
    val address: String,
    val city: String,
    val state: String,
    val country: String,
    val zip: String,
    val notes: String,

    val createdAt: String,
    val updatedAt: String,

    val closedDate: String? = null,
    val closedResult: LeadClosedResult? = null,
    val accountID: String? = null,
    val company: String,
    val jobTitle: String,
    val priority: Int,
    val source: String,
    val activities: List<ActivityRecord> = emptyList(),

    val stageID: String,
    val stageName: String? = null,

    val assignedToID: String? = null,
    val assignedToName: String? = null,
)

@Serializable
data class Opportunity(
    val id: String,

    val closedDate: String? = null,
    val createdAt: String,
    val description: String,
    val name: String,
    val notes: String,
    val priority: Int,
    val updatedAt: String,
    val value: Double,
    val activities: List<ActivityRecord> = emptyList(),

    val stageID: String,
    val stageName: String? = null,
    val accountName: String? = null,
    val accountID: String,
    val assignedToID: String? = null,
    val assignedToName: String? = null,
)

@Serializable
data class TaskRecord(
    val id: String,

    val title: String,
    val body: String,
    val isComplete: Boolean,
    val priority: Int,
    val date: String? = null,
    val time: String? = null,
    val duration: Int? = null,
    val visibility: RecordVisibility,
    val updatedAt: String,
    val assignedToID: String? = null,
    val assignedToName: String? = null,
    val accounts: List<Account> = emptyList(),
    val contacts: List<Contact> = emptyList(),
    val cases: List<CaseRecord> = emptyList(),
    val leads: List<Lead> = emptyList(),
    val opportunities: List<Opportunity> = emptyList(),
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
    val memberID: String,
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

@Serializable(with = RecordTypeSerializer::class)
enum class RecordType(val typeName: String) {
    Account("ACCOUNT"),
    Case("CASE"),
    Contact("CONTACT"),
    Lead("LEAD"),
    Opportunity("OPPORTUNITY");

    companion object {
        fun fromTypeName(typeName: String): RecordType =
            entries.find { it.typeName == typeName }
                ?: throw IllegalArgumentException("Type not found for name: $typeName")
    }
}

@Serializable(with = RecordVisibilityRoleSerializer::class)
enum class RecordVisibility(val visibility: String) {
    OnlyMe("ONLY_ME"),
    Everyone("EVERYONE");

    companion object {
        fun fromRawValue(visibility: String): RecordVisibility =
            entries.find { it.visibility == visibility }
                ?: throw IllegalArgumentException("Visibility level not found: `$visibility`")
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

object RecordTypeSerializer : KSerializer<RecordType> {
    override val descriptor: SerialDescriptor =
        PrimitiveSerialDescriptor("RecordType", PrimitiveKind.STRING)

    override fun serialize(encoder: Encoder, value: RecordType) {
        encoder.encodeString(value.typeName)
    }

    override fun deserialize(decoder: Decoder): RecordType {
        val typeName = decoder.decodeString()
        return RecordType.fromTypeName(typeName)
    }
}

object RecordVisibilityRoleSerializer : KSerializer<RecordVisibility> {
    override val descriptor: SerialDescriptor =
        PrimitiveSerialDescriptor("RecordVisibility", PrimitiveKind.STRING)

    override fun serialize(encoder: Encoder, value: RecordVisibility) {
        encoder.encodeString(value.visibility)
    }

    override fun deserialize(decoder: Decoder): RecordVisibility {
        val visibility = decoder.decodeString()
        return RecordVisibility.fromRawValue(visibility)
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