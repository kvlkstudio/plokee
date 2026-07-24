allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Some plugins (e.g. clipboard_watcher 0.3.0) still compile against API 33
    // while pulling in androidx libraries that require compiling against 34+.
    // Force every Android library subproject up to a modern compileSdk.
    // Registered before evaluationDependsOn so the project isn't evaluated yet.
    afterEvaluate {
        extensions.findByName("android")?.let { ext ->
            val android = ext as com.android.build.gradle.BaseExtension
            val current = android.compileSdkVersion
                ?.substringAfter("android-")
                ?.toIntOrNull()
            if (current == null || current < 34) {
                android.compileSdkVersion(34)
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
