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
}

// SDK Override: This MUST happen before evaluationDependsOn(":app")
// to avoid the "It is too late to set compileSdk" error.
subprojects {
    if (project.name != "app") {
        project.pluginManager.withPlugin("com.android.library") {
            project.extensions.findByType<com.android.build.gradle.LibraryExtension>()?.apply {
                compileSdk = 36
                defaultConfig.targetSdk = 36
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
