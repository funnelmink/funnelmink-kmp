package utilities

import models.*


class TestData {
    val account = Account(
        "cb321b92-47bd-4121-80b8-f97e9ecc1be0",
        "891 N 800 E",
        "Orem",
        "United States",
        timestamp,
        "wrrn24@gmail.com",
        40.2974,
        "6cb3005b-1ecc-4101-b0ed-e11e5eae567c",
        111.6946,
        "Sleve McDichael",
        lorem,
        "801-555-5555",
        "Utah",
        timestamp,
        "84097",
    )

    val accountContact = AccountContact(
        "8d2116f9-3862-4706-beb2-1b5fe7768f3f",
        "",
        "Darryl Archideld",
        lorem,
        "801-555-5555",
    )

    val activityRecord = ActivityRecord(
        "f3e3e3e3-3e3e-3e3e-3e3e-3e3e3e3e3e3e",
        timestamp,
        "Details",
        "c32d4984-1b89-48a3-a0f4-6c1d1239cc99",
        ActivityRecordType.Update,
    )

    val caseRecord = CaseRecord(
        "87556786-f1d2-4165-825d-9397e6a9e5c8",
        "c32d4984-1b89-48a3-a0f4-6c1d1239cc99",
        timestamp,
        timestamp,
        lorem,
        "Bobson Dugnutt's dumpster fire",
        lorem,
        0,
        "149e809b-2f27-4b39-899f-b091e0fe711e",
        timestamp,
        200.0,
    )

    val caseFunnel by lazy {
        Funnel(
            "b6b0c57f-55a8-4659-a28b-54ed96928858",
            "Test Case Funnel",
            FunnelType.Case,
            listOf(funnelStage0, funnelStage1),
            listOf(caseRecord),
            emptyList(),
            emptyList(),
        )
    }

    val leadFunnel by lazy {
        Funnel(
            "78edf942-ac94-44d0-b4f8-d770aa26d8e5",
            "Test Lead Funnel",
            FunnelType.Lead,
            listOf(funnelStage0, funnelStage1),
            emptyList(),
            emptyList(),
            emptyList(),
        )
    }

    val opportunityFunnel by lazy {
        Funnel(
            "0f507d7c-3856-483f-9f58-be05bb7d596d",
            "Test Opportunity Funnel",
            FunnelType.Opportunity,
            listOf(funnelStage0, funnelStage1),
            emptyList(),
            emptyList(),
            emptyList(),
        )
    }

    val funnelStage0 = FunnelStage(
        "149e809b-2f27-4b39-899f-b091e0fe711e",
        "Test Stage Zero",
        0,
    )

    val funnelStage1 = FunnelStage(
        "5258d0f5-4783-41ca-a36e-9e64ec751595",
        "Test Stage One",
        1,
    )

    val lead = Lead(
        "a4d83e06-b94f-45f7-a67d-8b36381f4322",
        "891 N 800 E",
        "c32d4984-1b89-48a3-a0f4-6c1d1239cc99",
        "Orem",
        timestamp,
        LeadClosedResult.Converted,
        "funnelmink",
        "United States",
        timestamp,
        "email@example.com",
        "Block Head",
        40.2974,
        111.6946,
        "Raul Chamgerlain",
        lorem,
        "801-555-5555",
        0,
        "funnelmink Lead Generator (maybe one day)",
        "149e809b-2f27-4b39-899f-b091e0fe711e",
        "Utah",
        timestamp,
        "84097",
    )

    val opportunity = Opportunity(
        "07d0b258-bfb4-48cf-83ad-43fa7c68c4d1",
        "c32d4984-1b89-48a3-a0f4-6c1d1239cc99",
        timestamp,
        timestamp,
        lorem,
        "Todd Bonzalez paper supply",
        lorem,
        0,
        "149e809b-2f27-4b39-899f-b091e0fe711e",
        timestamp,
        1_000_000.0,
    )

    val task = TaskRecord(
        "fc681408-30f1-4771-9c17-8261f8440b3c",
        lorem,
        false,
        0,
        timestamp,
        "Meeting with Willie Dustice",
        timestamp,
    )

    val user = User(
        "c32d4984-1b89-48a3-a0f4-6c1d1239cc99",
        "Onson Sweemy",
        "on.son@example.com",
        false,
    )

    val workspace = Workspace(
        "b2de1142-c10e-4343-b93d-7c11503955ad",
        "Godzilla Minus One",
        WorkspaceMembershipRole.Owner,
        avatarURL,
    )

    val workspaceMember = WorkspaceMember(
        "3c13e3d5-7d7f-4b62-bcec-cc527f7b4bcc",
        "c32d4984-1b89-48a3-a0f4-6c1d1239cc99",
        "Onson Sweemy",
        WorkspaceMembershipRole.Owner,
    )

    private val avatarURL get() = "https://i.kym-cdn.com/photos/images/newsfeed/001/207/210/b22.jpg"
    private val lorem get() = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    private val timestamp get() = "2024-02-12 04:54:13.208917+00"
}