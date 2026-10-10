import groovy.json.JsonSlurper
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") apply false
}

// Firebase config must belong to the production application.
val firebaseConfigFile = file("google-services.json")
check(firebaseConfigFile.exists()) {
    "Download android/app/google-services.json for com.marcgelwertz.alphatrack from Firebase project alphatrack-2026."
}
val firebaseConfig = JsonSlurper().parse(firebaseConfigFile) as Map<*, *>
val firebaseClients = firebaseConfig["client"] as? List<*> ?: emptyList<Any>()
check(firebaseClients.any { client ->
    val info = (client as? Map<*, *>)?.get("client_info") as? Map<*, *>
    val androidInfo = info?.get("android_client_info") as? Map<*, *>
    androidInfo?.get("package_name") == "com.marcgelwertz.alphatrack"
}) {
    "Firebase config does not match com.marcgelwertz.alphatrack. Replace android/app/google-services.json " +
        "with the production download; do not edit the test config's package_name."
}
apply(plugin = "com.google.gms.google-services")

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val validateReleaseSigning by tasks.registering {
    group = "verification"
    description = "Require local production signing inputs before a release build."
    doLast {
        check(keystorePropertiesFile.exists()) {
            "Missing android/key.properties. Configure the verified production upload key."
        }
        val required = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
        val missing = required.filter { keystoreProperties.getProperty(it).isNullOrBlank() }
        check(missing.isEmpty()) {
            "Fill the missing signing properties in android/key.properties: " + missing.joinToString()
        }
        check(file(keystoreProperties.getProperty("storeFile")).isFile) {
            "The keystore referenced by android/key.properties does not exist."
        }
    }
}

tasks.configureEach {
    if (name == "preReleaseBuild" || name == "validateSigningRelease") {
        dependsOn(validateReleaseSigning)
    }
}

android {
    namespace = "com.marcgelwertz.alphatrack"
    compileSdk = 36
    ndkVersion = "27.0.12077973"
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
    
    defaultConfig {
        applicationId = "com.marcgelwertz.alphatrack"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    
    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }
    
    buildTypes {
        release {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
                "consumer-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}