plugins {
    id("com.android.library")
}

group = "com.example.flutter_location_button"
version = "1.0-SNAPSHOT"

allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://storage.googleapis.com/download.flutter.io")
        }
    }
}

android {
    namespace = "com.example.flutter_location_button"

    // androidx.core.locationbutton requires compileSdk >= 37 (Android 17).
    compileSdk = 37

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            all {
                it.useJUnitPlatform()

                it.outputs.upToDateWhen { false }

                it.testLogging {
                    events("passed", "skipped", "failed", "standardOut", "standardError")
                    showStandardStreams = true
                }
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    compileOnly("io.flutter:flutter_embedding_debug:1.0.0-5d531788691ec3404cac0cee66ead4007b177363")
    implementation("androidx.core.locationbutton:locationbutton:1.0.0-alpha01")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.core:core:1.13.1")
    testImplementation("io.flutter:flutter_embedding_debug:1.0.0-5d531788691ec3404cac0cee66ead4007b177363")
    testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")
    testImplementation("org.mockito:mockito-core:5.0.0")
}
