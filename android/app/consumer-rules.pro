## Consumer ProGuard rules for alpha_track

## Keep all model classes - CRITICAL for JSON serialization
-keep class com.example.alpha_track.** { *; }

## Keep all data classes and their members
-keepclassmembers class * {
    <fields>;
    <methods>;
}

## Preserve annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

## Keep SharedPreferences related classes
-keep class android.content.SharedPreferences { *; }
-keep class android.content.SharedPreferences$** { *; }
