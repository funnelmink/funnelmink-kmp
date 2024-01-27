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
data class ActivityRecord(
    val id: String,
    val createdAt: String,
    val details: String? = null,
    val memberID: String,
    val type: ActivityRecordType,
)

@Serializable
data class Case(
    val id: String,
)

@Serializable
data class Contact(
    val id: String,
    val firstName: String,
    val lastName: String? = null,
    val emails: List<String>,
    val phoneNumbers: List<String>,
    val companyName: String? = null,
    val isOrganization: Boolean,
    val latitude: Double? = null,
    val longitude: Double? = null,
    val street1: String? = null,
    val street2: String? = null,
    val city: String? = null,
    val state: String? = null,
    val country: String? = null,
    val zip: String? = null,
)

@Serializable
data class Funnel(
    val id: String,
    val name: String,
    val type: FunnelType,
    val stages: List<FunnelStage>
)

@Serializable
data class FunnelStage(
    val id: String,
    val name: String,
)

@Serializable
data class Lead(
    val id: String,
    )

@Serializable
data class Opportunity(
    val id: String,
)

// Can't name it `Task` because it's taken by Swift concurrency
@Serializable
data class ScheduleTask(
    val id: String,
    val title: String,
    val body: String? = null,
    val priority: Int,
    val isComplete: Boolean,
    val scheduledDate: String? = null,
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
    var role: WorkspaceMembershipRole? = null,
    val avatarURL: String? = null
)

@Serializable
data class WorkspaceMember(
    val id: String,
    val userID: String,
    val username: String,
    //    @SerialName("avatar_url") val avatarURL: String? = null,
    var role: WorkspaceMembershipRole,
    //    val email: String, I don't think we want to share emails?
)

// ------------------------------------------------------------------------
// MARK: - Enums
// ------------------------------------------------------------------------

@Serializable(with = ActivityRecordTypeSerializer::class)
enum class ActivityRecordType(val typeName: String) {
    Email("email"),
    Meeting("meeting"),
    Note("note"),
    PhoneCall("phoneCall"),
    Update("update"),
    TextMessage("textMessage");

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

@Serializable(with = WorkspaceMembershipRoleSerializer::class)
enum class WorkspaceMembershipRole(val roleName: String) {
    Owner("OWNER"),
    Member("MEMBER"),
    Requested("REQUESTED"),
    Invited("INVITED");

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

object FunnelTypeSerializer : KSerializer<ActivityRecordType> {
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