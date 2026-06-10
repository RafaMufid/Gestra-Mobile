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
subprojects {
    project.evaluationDependsOn(":app")
}
subprojects {
    afterEvaluate {
        val isAndroid = project.plugins.hasPlugin("com.android.application") || project.plugins.hasPlugin("com.android.library")
        if (isAndroid) {
            val android = project.extensions.findByName("android")
            if (android != null) {
                try {
                    val getNamespace = android.javaClass.getMethod("getNamespace")
                    val ns = getNamespace.invoke(android) as? String
                    if (ns.isNullOrEmpty()) {
                        val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                        var safeNamespace = project.group.toString()
                        if (safeNamespace.isEmpty() || safeNamespace == "unspecified") {
                            safeNamespace = "com.example.${project.name}"
                        }
                        // Ganti karakter tidak valid untuk nama package
                        safeNamespace = safeNamespace.replace("-", "_")
                        setNamespace.invoke(android, safeNamespace)
                        println("Successfully injected namespace '$safeNamespace' for subproject :${project.name}")
                    }
                } catch (e: Exception) {
                    // Abaikan jika method tidak ditemukan
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
