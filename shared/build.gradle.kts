
plugins {
    alias(libs.plugins.androidLibrary)
    alias(libs.plugins.kotlinMultiplatform)
    alias(libs.plugins.kotlinSerialization)
    alias(libs.plugins.skie)
    alias(libs.plugins.sqldelight)
    alias(libs.plugins.versionChecker)
}

kotlin {
    androidTarget {
        compilations.all {
            kotlinOptions {
                jvmTarget = "1.8"
            }
        }
    }
    
    jvm()
    
    listOf(
        iosX64(),
        iosArm64(),
        iosSimulatorArm64()
    ).forEach { iosTarget ->
        iosTarget.binaries.framework {
            baseName = "Shared"
            isStatic = false
            freeCompilerArgs += "-Xbinary=bundleId=com.funnelmink.crm.shared"
            freeCompilerArgs += "-Xexpect-actual-classes"
        }
    }
    
    sourceSets {
        commonMain.dependencies {
            implementation(libs.ktor.client.core)
            implementation(libs.ktor.client.content.negotiation)
            implementation(libs.ktor.serialization.kotlinx.json)
            implementation(libs.kotlinx.coroutines.core)
            implementation(libs.kotlinx.datetime)
            implementation(libs.sqldelight)
        }
        androidMain.dependencies {
            implementation(libs.ktor.client.okhttp)
            implementation(libs.sqldelight.android)
        }
        iosMain.dependencies {
            implementation(libs.ktor.client.darwin)
            implementation(libs.sqldelight.darwin)
        }
    }
}

android {
    namespace = "com.funnelmink.crm.shared"
    compileSdk = libs.versions.android.compileSdk.get().toInt()
    defaultConfig {
        minSdk = libs.versions.android.minSdk.get().toInt()
    }
}

sqldelight {
    databases {
        create("FunnelminkCache") {
            packageName.set("com.funnelmink.crm")
        }
    }
}

// makes it so iOS devs don't have to launch Fleet to get the latest KMP updates
tasks.register("prepareXcode") {
    dependsOn(
        "compileKotlinIosArm64",
        "compileKotlinIosSimulatorArm64",
        "compileKotlinIosX64",
        "linkDebugFrameworkIosArm64",
        "linkDebugFrameworkIosSimulatorArm64",
        "linkDebugFrameworkIosX64",
        "compileAppleMainKotlinMetadata",
        "compileIosMainKotlinMetadata",
        // SKIE tasks
        "skieCreateConfigurationDebugFrameworkIosArm64",
        "skieCreateConfigurationDebugFrameworkIosSimulatorArm64",
        "skieCreateConfigurationDebugFrameworkIosX64",
        "skieMergeCustomSwiftDebugFrameworkIosArm64",
        "skieMergeCustomSwiftDebugFrameworkIosSimulatorArm64",
        "skieMergeCustomSwiftDebugFrameworkIosX64",
        "skiePackageCustomSwiftDebugFrameworkIosArm64",
        "skiePackageCustomSwiftDebugFrameworkIosSimulatorArm64",
        "skiePackageCustomSwiftDebugFrameworkIosX64"
    )
    doLast {
        println("Kotlin Multiplatform frameworks are ready for Xcode.")
    }
}