# Ether Cinema Enterprise ProGuard / R8 Obfuscation Rules

# Flutter Wrapper Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.plugins.** { *; }

# Preserve Flutter Entry Points and Annotations
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# Firebase Authentication & Cloud Firestore Rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Supabase Storage Rules
-keep class io.supabase.** { *; }

# Ether Cinema Core Security & Models
-keep class com.example.ether_cinema.core.security.** { *; }

# Remove Debug and Verbose Logs in Production
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Line number table preservation for crash reporting stack traces
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable
