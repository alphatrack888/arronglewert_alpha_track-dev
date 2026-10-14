import groovy.json.JsonSlurper
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") apply false
}

val firebaseConfigFile = file("google-services.json")
check(firebaseConfigFile.exists()) {
    "Place android/app/google-services.json for com.marcgelwertz.alphatrack " +
        "(Firebase project alphatrack-2026). Copy from repo cred/ or see FIREBASE_SETUP.md."
}
val firebaseConfig = JsonSlurper().parse(firebaseConfigFile) as Map<*, *>
val firebaseClients = firebaseConfig["client"] as? List<*> ?: emptyList<Any>()
check(firebaseClients.any { client ->
    val info = (client as? Map<*, *>)?.get("client_info") as? Map<*, *>
    val androidInfo = info?.get("android_client_info") as? Map<*, *>
    androidInfo?.get("package_name") == "com.marcgelwertz.alphatrack"
}) {
    "Firebase config does not include com.marcgelwertz.alphatrack. Replace google-services.json."
}
apply(plugin = "com.google.gms.google-services")

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
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
