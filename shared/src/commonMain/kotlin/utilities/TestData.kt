package utilities

import models.*


class TestData {
    val testAccount = Account(
        "cb321b92-47bd-4121-80b8-f97e9ecc1be0",
        "Sleve McDichael",
        "wrrn24@gmail.com",
        "801-555-5555",
        111.6946,
        40.2974,
        "891 N 800 E",
        "Orem",
        "Utah",
        "United States",
        "84097",
        lorem,
        timestamp,
        timestamp,
        "6cb3005b-1ecc-4101-b0ed-e11e5eae567c",
        activities,
        listOf(contact,contact,contact),
        listOf(caseRecord,caseRecord,caseRecord),
        listOf(opportunity,opportunity,opportunity)
    )

    val testContact = contact
    val testActivityRecord = activityRecord
    val testCaseRecord = caseRecord

    val testFunnelStage0 = FunnelStage(
        "149e809b-2f27-4b39-899f-b091e0fe711e",
        "Test Stage Zero",
        0,
    )

    val testFunnelStage1 = FunnelStage(
        "5258d0f5-4783-41ca-a36e-9e64ec751595",
        "Test Stage One",
        1,
    )

    val testLead = lead

    val testOpportunity = opportunity

    val testTask = TaskRecord(
        "fc681408-30f1-4771-9c17-8261f8440b3c",
        "Meeting with Willie Dustice",
        lorem,
        false,
        0,
        timestamp,
        timestamp,
        15,
        RecordVisibility.Everyone,
        timestamp,
        "cb321b92-47bd-4121-80b8-f97e9ecc1be0",
    )

    val testUser = User(
        "c32d4984-1b89-48a3-a0f4-6c1d1239cc99",
        "Onson Sweemy",
        "on.son@example.com",
        false,
    )

    val testWorkspace = Workspace(
        "b2de1142-c10e-4343-b93d-7c11503955ad",
        "3c13e3d5-7d7f-4b62-bcec-cc527f7b4bcc",
        "Godzilla Minus One",
        listOf(WorkspaceMembershipRole.Admin),
        avatarURL,
    )

    val testWorkspaceMember = WorkspaceMember(
        "3c13e3d5-7d7f-4b62-bcec-cc527f7b4bcc",
        "c32d4984-1b89-48a3-a0f4-6c1d1239cc99",
        "Onson Sweemy",
        listOf(WorkspaceMembershipRole.Admin),
    )

    private val avatarURL get() = "https://i.kym-cdn.com/photos/images/newsfeed/001/207/210/b22.jpg"
    private val lorem get() = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    private val timestamp get() = "2024-02-12 04:54:13.208917+00"
    private val contact get() = Contact(
        "8d2116f9-3862-4706-beb2-1b5fe7768f3f",
        "Darryl Archideld",
        "email@example.com",
        "801-555-5555",
        "VP of Sales",
        lorem,
        "Sleve McDichael",
        "cb321b92-47bd-4121-80b8-f97e9ecc1be0",
    )
    private val activityRecord get() = ActivityRecord(
        "f3e3e3e3-3e3e-3e3e-3e3e-3e3e3e3e3e3e",
        timestamp,
        "Details",
        "c32d4984-1b89-48a3-a0f4-6c1d1239cc99",
        ActivityRecordType.Update,
    )
    private val activities get() = listOf(activityRecord, activityRecord, activityRecord)
    private val caseRecord get() = CaseRecord(
        "87556786-f1d2-4165-825d-9397e6a9e5c8",
        "Bobson Dugnutt's dumpster fire",
        timestamp,
        timestamp,
        lorem,
        lorem,
        0,
        timestamp,
        200.0,
        activities,
        "149e809b-2f27-4b39-899f-b091e0fe711e",
        "Test Stage Zero",
        "Sleve McDichael",
        "cb321b92-47bd-4121-80b8-f97e9ecc1be0",
        "3c13e3d5-7d7f-4b62-bcec-cc527f7b4bcc",
        "Onson Sweemy",
    )
    private val lead get() = Lead(
        "a4d83e06-b94f-45f7-a67d-8b36381f4322",
        "Raul Chamgerlain",
        "email@example.com",
        "801-555-5555",
        40.2974,
        111.6946,
        "891 N 800 E",
        "Orem",
        "Utah",
        "United States",
        "84097",
        lorem,
        timestamp,
        timestamp,
        timestamp,
        LeadClosedResult.AccountAndOpportunity,
        "cb321b92-47bd-4121-80b8-f97e9ecc1be0",
        "funnelmink",
        "Block Head",
        0,
        "funnelmink Lead Generator (maybe one day)",
        activities,
        "149e809b-2f27-4b39-899f-b091e0fe711e",
        "Test Stage Zero",
        "3c13e3d5-7d7f-4b62-bcec-cc527f7b4bcc",
        "Onson Sweemy",
    )
    private val opportunity get() = Opportunity(
        "07d0b258-bfb4-48cf-83ad-43fa7c68c4d1",
        timestamp,
        timestamp,
        lorem,
        "Todd Bonzalez paper supply",
        lorem,
        0,
        timestamp,
        1_000_000.0,
        activities,
        "149e809b-2f27-4b39-899f-b091e0fe711e",
        "Test Stage Zero",
        "Sleve McDichael",
        "cb321b92-47bd-4121-80b8-f97e9ecc1be0",
        "3c13e3d5-7d7f-4b62-bcec-cc527f7b4bcc",
        "Onson Sweemy",
    )
}