plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.todolistapp"
    
    // UPDATE: Naikkan compileSdk dan targetSdk
    compileSdk = 34  // atau flutter.compileSdkVersion.toInt()
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // UPDATE: Naikkan ke Java 17 untuk compatibility
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.todolistapp"
        
        // UPDATE: Google Maps butuh minSdk 21+
        minSdk = flutter.minSdkVersion  // Minimal untuk Google Maps Flutter
        targetSdk = 34
        
        versionCode = flutter.versionCode?.toInt() ?: 1
        versionName = flutter.versionName ?: "1.0"
        
        // ADD: MultiDex untuk menghindari 64k method limit
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Ganti dengan signing config production
            signingConfig = signingConfigs.getByName("debug")
            
            // ADD: Optimasi release build
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    
    // ADD: Build features
    buildFeatures {
        viewBinding = true  // Untuk view binding
        buildConfig = true  // Untuk build config
    }
    
    // ADD: Packaging options (untuk menghindari duplicate files)
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
            excludes += "META-INF/DEPENDENCIES"
        }
    }
}

flutter {
    source = "../.."
}

// ADD: Dependencies untuk multiDex
dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
