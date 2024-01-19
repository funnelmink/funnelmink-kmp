package models

import kotlinx.serialization.KSerializer
import kotlinx.serialization.Serializable
import kotlinx.serialization.descriptors.PrimitiveKind
import kotlinx.serialization.descriptors.PrimitiveSerialDescriptor
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder

@Serializable
data class Contact(
    val id: String,
    val firstName: String,
    val lastName: String? = null,
    val emails: List<String>,
    val phoneNumbers: List<String>,
    val companyName: String? = null,
)

@Serializable
data class User(
    val id: String,
    val username: String,
    val email: String,
    val isDevAccount: Boolean
)

@Serializable
data class ScheduleTask(
    // Can't name it `Task` because it's taken by Swift concurrency
    val id: String,
    val title: String,
    val body: String? = null,
    val priority: Int,
    val isComplete: Boolean,
    val scheduledDate: String? = null,
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
    val userID: String? = null,
    val username: String,
    //    @SerialName("avatar_url") val avatarURL: String? = null,
    var role: WorkspaceMembershipRole,
    //    val email: String, I don't think we want to share emails?
)

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