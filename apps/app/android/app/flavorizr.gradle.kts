import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "dev.invoketech.flutter_bloc_template.dev"
            resValue(type = "string", name = "app_name", value = "Template Dev")
        }
        create("staging") {
            dimension = "flavor-type"
            applicationId = "dev.invoketech.flutter_bloc_template.staging"
            resValue(type = "string", name = "app_name", value = "Template Staging")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "dev.invoketech.flutter_bloc_template"
            resValue(type = "string", name = "app_name", value = "Template")
        }
    }

    buildFeatures.resValues = true
}