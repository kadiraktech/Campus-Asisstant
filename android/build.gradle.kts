buildscript {
    val kotlinVersionBuildscript by extra("1.9.23") // Renamed for clarity
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.0") // Use a recent AGP version
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:${kotlinVersionBuildscript}")
        classpath("com.google.gms:google-services:4.4.1") // For Firebase
    }
}

allprojects {
    // Make kotlin_version available to all projects (including app/build.gradle)
    ext["kotlin_version"] = "1.9.23"
    
    repositories {
        google()
        mavenCentral()
    }

    tasks.withType(JavaCompile::class.java) {
        sourceCompatibility = JavaVersion.VERSION_17.toString()
        targetCompatibility = JavaVersion.VERSION_17.toString()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
