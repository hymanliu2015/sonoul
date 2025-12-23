# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
# Kotlin
-keep class kotlin.Metadata { *; }
-keepclassmembers class ** {
    @kotlin.Metadata *;
}

# Kotlin Coroutines
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**
# AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**

# Google Play services
-dontwarn com.google.android.gms.**
-keep class com.google.gson.** { *; }
-keep class com.squareup.moshi.** { *; }
