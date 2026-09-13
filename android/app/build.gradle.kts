import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val signingFile = rootProject.file("key.properties")
val signingProperties = Properties()
if (signingFile.isFile) {
    signingFile.inputStream().use { signingProperties.load(it) }
}
val allowDebugSigning = providers.gradleProperty("allowDebugSigning").orNull == "true"

gradle.taskGraph.whenReady {
    if (allTasks.any { it.name.contains("Release") } && !signingFile.isFile && !allowDebugSigning) {
        throw GradleException(
            "Release signing is not configured. Copy android/key.properties.example " +
            "to android/key.properties and configure your own keystore. " +
            "For internal testing ONLY, invoke Gradle with -PallowDebugSigning=true."
        )
    }
}

android {
    namespace = "com.learningbird.learning_bird"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.learningbird.learning_bird"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (signingFile.isFile) {
            create("release") {
                for (property in listOf("storeFile", "storePassword", "keyAlias", "keyPassword")) {
                    require(!signingProperties.getProperty(property).isNullOrBlank()) {
                        "Missing signing property: $property"
                    }
                }
                storeFile = rootProject.file(signingProperties.getProperty("storeFile"))
                storePassword = signingProperties.getProperty("storePassword")
                keyAlias = signingProperties.getProperty("keyAlias")
                keyPassword = signingProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (signingFile.isFile) {
                signingConfigs.getByName("release")
            } else if (allowDebugSigning) {
                signingConfigs.getByName("debug")
            } else {
                null
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
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
flutter {
    source = "../.."
}
