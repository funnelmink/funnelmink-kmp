package networking

import models.*

/// Endpoints are sorted by access level.
/// Each new access level builds onto the rules from all prior levels.
interface API {
    var onAuthFailure: ((message: String) -> Unit)?
    var onBadRequest: ((message: String) -> Unit)?
    var onDecodingError: ((message: String) -> Unit)?
    var onMissing: ((message: String) -> Unit)?
    var onServerError: ((message: String) -> Unit)?

    @Throws(Exception::class) fun signIn(user: User, token: String)
    @Throws(Exception::class) fun signOut()
    @Throws(Exception::class) fun signIntoWorkspace(workspace: Workspace)
    @Throws(Exception::class) fun signOutOfWorkspace()
    @Throws(Exception::class) fun refreshToken(token: String)
    @Throws(Exception::class) fun getCachedUser(id: String): User?
    @Throws(Exception::class) fun getCachedWorkspace(id: String): Workspace?

    // ------------------------------------------------------------------------
    // Auth-Only Endpoints
    // (you only need a firebase account. will fail if `token == nil`)
    // ------------------------------------------------------------------------

    // users
    @Throws(Exception::class) suspend fun createUser(body: CreateUserRequest): User
    @Throws(Exception::class) suspend fun getUserById(userId: String): User

    // workspaces
    @Throws(Exception::class) suspend fun acceptWorkspaceInvitation(id: String): Workspace
    @Throws(Exception::class) suspend fun declineWorkspaceInvitation(id: String)
    @Throws(Exception::class) suspend fun createWorkspace(body: CreateWorkspaceRequest): Workspace
    @Throws(Exception::class) suspend fun getWorkspaces(): List<Workspace>
    @Throws(Exception::class) suspend fun requestWorkspaceMembership(name: String)


    // ------------------------------------------------------------------------
    // Workspace Members-only Endpoints
    // (you need to be signed into a workspace. will fail if `workspaceID == nil`)
    // ------------------------------------------------------------------------

    // activities
    @Throws(Exception::class) suspend fun createActivity(subtype: ActivitySubtype, body: CreateActivityRequest)

    // contacts
    @Throws(Exception::class) suspend fun createContact(body: CreateContactRequest): Contact
    @Throws(Exception::class) suspend fun deleteContact(id: String)
    @Throws(Exception::class) suspend fun getContactActivities(id: String): List<ActivityRecord>
    @Throws(Exception::class) suspend fun getContactDetails(id: String): Contact
    @Throws(Exception::class) suspend fun getContacts(): List<Contact>
    @Throws(Exception::class) suspend fun updateContact(id: String, body: UpdateContactRequest): Contact

    // tasks
    @Throws(Exception::class) suspend fun createTask(body: CreateTaskRequest): ScheduleTask
    @Throws(Exception::class) suspend fun deleteTask(id: String)
    @Throws(Exception::class) suspend fun getTask(id: String): ScheduleTask?
    @Throws(Exception::class) suspend fun getTasks(): List<ScheduleTask>
    @Throws(Exception::class) suspend fun getCompletedTasks(): List<ScheduleTask>
    @Throws(Exception::class) suspend fun updateTask(id: String, body: UpdateTaskRequest): ScheduleTask
    @Throws(Exception::class) suspend fun toggleTaskCompletion(id: String, isComplete: Boolean) : ScheduleTask

    // workspaces
    @Throws(Exception::class) suspend fun getWorkspaceMembers(): List<WorkspaceMember>
    @Throws(Exception::class) suspend fun leaveWorkspace()


    // ------------------------------------------------------------------------
    // Workspace Owners-only Endpoints
    // (you need to be signed into a workspace and be an owner)
    // ------------------------------------------------------------------------

    // workspaces
    @Throws(Exception::class) suspend fun acceptWorkspaceRequest(userID: String)
    @Throws(Exception::class) suspend fun changeWorkspaceRole(userID: String, role: WorkspaceMembershipRole)
    @Throws(Exception::class) suspend fun declineWorkspaceRequest(userID: String)
    @Throws(Exception::class) suspend fun deleteWorkspace(): Workspace
    @Throws(Exception::class) suspend fun inviteUserToWorkspace(email: String)
    @Throws(Exception::class) suspend fun removeMemberFromWorkspace(userID: String)
    @Throws(Exception::class) suspend fun updateWorkspace(body: UpdateWorkspaceRequest): Workspace
}