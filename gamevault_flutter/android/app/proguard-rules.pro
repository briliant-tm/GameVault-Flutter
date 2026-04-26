# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Dart
-keep class com.google.dart.** { *; }

# AndroidX & Material
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-keep class com.google.material.** { *; }
-keep interface com.google.material.** { *; }

# Provider package
-keep class provider.** { *; }
-keepclassmembers class * {
    *** provide(...);
}

# Dio
-keep class io.flutter.plugins.pathprovider.** { *; }
-keep class com.google.common.base.Preconditions { *; }

# OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-keep class okio.** { *; }

# SQLite
-keep class org.sqlite.** { *; }
-keep class net.sqlcipher.** { *; }

# Preserve line numbers for debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Keep classes with Flutter-related annotations
-keepclasseswithmembernames class * {
    native <methods>;
}

# Optimization settings
-optimizationpasses 5
-verbose
-dontshrink

# Keep enum values/valueOf() methods
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
